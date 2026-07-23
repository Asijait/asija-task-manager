const $ = (s) => document.querySelector(s);
const $$ = (s) => [...document.querySelectorAll(s)];
let scope = 'all';
let items = [];
let allottees = [];
let loggedInUser = null;
let todaysReportData = null;
let lastNotificationCount = 0;
let debounce;
let activeColumnFilters = {};
let openFilterKey = null;
const titles = {all:'All work',pending:'Pending work',overdue:'Overdue work',today:"Today's work",start_today:'Work start today',upcoming:'Next 7 days',new_requests:'New task requests'};
const DATE_FILTER_KEYS = new Set(['work_inflow','next_scheduled','reschedule_scheduled','target_date','actual_completion_date']);
const APP_ROOT = window.location.pathname.startsWith('/work-report') ? '/work-report' : '';
const appUrl = (path) => `${APP_ROOT}${path}`;

const api = async (url, options={}) => {
  const response = await fetch(appUrl(url), {headers:{'Content-Type':'application/json'}, ...options});
  if (!response.ok) { const e = await response.json().catch(()=>({error:'Something went wrong'})); throw new Error(e.error); }
  return response.status === 204 ? null : response.json();
};
const esc = (v='') => String(v ?? '').replace(/[&<>'"]/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
const fmt = (d) => d ? new Intl.DateTimeFormat('en-IN',{day:'2-digit',month:'short',year:'numeric'}).format(new Date(d+'T00:00:00')) : 'No date';
const initials = (name) => name ? name.split(/\s+/).map(x=>x[0]).join('').slice(0,2).toUpperCase() : '—';
const slug = (v) => v.toLowerCase().replaceAll(' ','-');
function notify(message){ const t=$('#toast'); t.textContent=message;t.classList.add('show');setTimeout(()=>t.classList.remove('show'),2200); }
function showError(message=''){ $('#error').textContent=message; $('#error').classList.toggle('hidden',!message); }

async function loadSummary(){
  const params=new URLSearchParams({team:$('#team-filter').value||''});
  const s=await api('/api/summary?'+params);
  $('#nav-overdue').textContent=s.overdue;
  $('#summary-line').textContent=`• Pending ${s.pending} • Today ${s.today} • Done ${s.done}`;
}
async function loadAllottees(){
  allottees=await api('/api/allottees');
  $('#allottee-options').innerHTML=allottees.map(user=>`<option value="${esc(user.name)}">${esc(user.email)} - WIP / Not Started: ${user.active_count||0}</option>`).join('');
  updateAllotteeLoad();
}
function updateAllotteeLoad(){
  const value=$('#allotted-to')?.value.trim().toLowerCase();
  const user=allottees.find(item=>item.name.toLowerCase()===value);
  $('#allottee-load').textContent=user?`Current workload: ${user.active_count||0} WIP / Not Started work${Number(user.active_count)===1?'':'s'}`:'';
}
async function loadCurrentUser(){
  const user=await api('/api/current-user');
  loggedInUser=user;
  $('#logged-in-user').textContent=user.name?`User: ${user.name}`:'User';
  const visible=user.visible_names||[];
  $('#team-filter').innerHTML=`<option value="${esc(user.name||'')}">My Work - ${esc(user.name||'')}</option>`+
    (visible.length>1?'<option value="all">All Visible Team</option>':'')+
    visible.filter(name=>name!==user.name).map(name=>`<option value="${esc(name)}">${esc(name)}</option>`).join('');
  $('#team-filter').value=user.name||'';
}
async function loadNotificationCount(){
  const notification=await api('/api/notifications');
  const count=Number(notification.unread||0);
  $('#nav-new-requests').textContent=count;
  const increased=count>lastNotificationCount;
  lastNotificationCount=count;
  if(increased)shakeRequestButton();
}
function shakeRequestButton(){
  const button=$('.top-nav-request');
  if(!button||lastNotificationCount<=0)return;
  button.classList.remove('request-shake');
  void button.offsetWidth;
  button.classList.add('request-shake');
  setTimeout(()=>button.classList.remove('request-shake'),700);
}
function reportSection(title,items,detail){
  const body=items.length?`<ol>${items.map(item=>`<li><strong>${esc(item.work_name)}</strong>${detail(item)}</li>`).join('')}</ol>`:'<p class="today-report-empty">No work</p>';
  return `<section class="today-report-section"><h3>${esc(title)} (${items.length})</h3>${body}</section>`;
}
window.openTodaysReport=async()=>{
  const dialog=$('#today-report-dialog');
  $('#today-report-content').innerHTML='<p class="today-report-empty">Loading report...</p>';
  dialog.showModal();
  try{
    todaysReportData=await api('/api/todays-report');
    $('#today-report-title').textContent=`Today's Work Report - ${todaysReportData.user.name}`;
    $('#today-report-content').innerHTML=
      reportSection('Old Work Completed Today',todaysReportData.old_completed,item=>item.remark?` - ${esc(item.remark)}`:'')+
      reportSection('New Work Added Today',todaysReportData.new_added,item=>` - Allotted to: ${esc(item.allotted_to||todaysReportData.user.name)}`)+
      reportSection("Tomorrow's Work Plan",todaysReportData.tomorrow_plan,item=>item.remark?` - ${esc(item.remark)}`:'');
  }catch(error){
    $('#today-report-content').innerHTML=`<p class="today-report-empty">${esc(error.message)}</p>`;
  }
};
window.closeTodaysReport=()=>$('#today-report-dialog').close();
window.copyTodaysReport=async()=>{
  if(!todaysReportData)return;
  const block=(title,items,detail)=>[`${title}: ${items.length}`,...items.map((item,index)=>`${index+1}. ${item.work_name}${detail(item)}`)].join('\n');
  const text=[
    `Today's Work Report - ${todaysReportData.user.name}`,
    `Date: ${todaysReportData.report_date}`,
    '',
    block('Old Work Completed Today',todaysReportData.old_completed,item=>item.remark?` - ${item.remark}`:''),
    '',
    block('New Work Added Today',todaysReportData.new_added,item=>` - Allotted to: ${item.allotted_to||todaysReportData.user.name}`),
    '',
    block("Tomorrow's Work Plan",todaysReportData.tomorrow_plan,item=>item.remark?` - ${item.remark}`:'')
  ].join('\n');
  await navigator.clipboard.writeText(text);
  notify('Report copied');
};
async function loadWork(){
  $('#work-list').innerHTML='<tr><td colspan="12" class="loading">Loading work…</td></tr>'; showError();
  const params=new URLSearchParams({scope,status:$('#status-filter').value,search:$('#search').value.trim(),team:$('#team-filter').value||''});
  try { items=await api('/api/work?'+params); render(); } catch(e){ showError('Database connection error: '+e.message); $('#work-list').innerHTML=''; }
}
function render(){
  $('#list-title').textContent=titles[scope]; $('#result-count').textContent=items.length;
  if(!items.length){$('#work-list').innerHTML='<tr><td colspan="12" class="empty"><strong>No work found</strong>Try another filter or add a new work item.</td></tr>';return;}
  const today=new Date(); today.setHours(0,0,0,0);
  $('#work-list').innerHTML=items.map(item=>{
    const due=item.target_date?new Date(item.target_date+'T00:00:00'):null;
    const overdue=item.status!=='Done'&&due&&due<today;
    return `<tr class="${overdue?'overdue-row':''}" data-item-index="${items.indexOf(item)}">
      <td class="sl-cell">${esc(item.excel_sl||item.id)}</td>
      <td class="work-name-cell"><strong>${esc(item.work_name)}</strong></td>
      <td class="person-cell">${esc(item.allotted_to||'')}</td>
      <td>${esc(item.status)}</td>
      <td class="date-cell">${fmt(item.work_inflow)}</td>
      <td class="date-cell">${fmt(item.next_scheduled)}</td>
      <td class="date-cell">${fmt(item.reschedule_scheduled)}</td>
      <td class="date-cell ${overdue?'overdue':''}">${fmt(item.target_date)}</td>
      <td class="date-cell">${fmt(item.actual_completion_date)}</td>
      <td class="remark-cell" onclick="showRemark(event,${item.id})" onmouseleave="hideRemark()">${esc(item.remark||'')}</td>
      <td class="section-cell">${esc(item.section||'')}</td>
      <td><span class="row-actions">${item.status!=='Done'?`<button class="icon-btn complete-btn" title="Mark complete" onclick="completeItem(${item.id})">✓</button>`:''}<button class="icon-btn" title="Edit" onclick="editItem(${item.id})">✎</button><button class="icon-btn delete-btn" title="Delete" onclick="deleteItem(${item.id})">⌫</button></span></td>
    </tr>`;
  }).join('');
  applyColumnFilters();
}
async function chooseScope(next){
  scope=next;activeColumnFilters={};updateFilterButtons();
  $$('.nav-item').forEach(b=>b.classList.toggle('active',b.dataset.scope===scope));
  if(next==='new_requests'&&loggedInUser?.name)$('#team-filter').value=loggedInUser.name;
  await loadWork();
  if(next==='new_requests'){
    await api('/api/notifications/read',{method:'PATCH'});
    await loadNotificationCount();
  }
}

function filterValue(item,key){
  const value=key==='excel_sl'?(item.excel_sl||item.id):item[key];
  return value===null||value===undefined||value===''?'__blank__':String(value);
}
function filterLabel(value,key){
  if(value==='__blank__')return '(Blank)';
  return key.includes('date')||key.includes('scheduled')||key==='work_inflow'?fmt(value):value;
}
function applyColumnFilters(){
  let visible=0;
  $$('#work-list tr[data-item-index]').forEach(row=>{
    const item=items[Number(row.dataset.itemIndex)];
    const show=Object.entries(activeColumnFilters).every(([key,selected])=>selected.has(filterValue(item,key)));
    row.style.display=show?'':'none'; if(show)visible++;
  });
  $('#result-count').textContent=visible;
  updateFilterButtons();
}
function updateFilterButtons(){
  $$('.column-filter-toggle').forEach(button=>button.classList.toggle('is-filtered',Boolean(activeColumnFilters[button.dataset.key])));
}
function renderFilterOptions(query=''){
  if(!openFilterKey)return;
  const values=[...new Set(items.map(item=>filterValue(item,openFilterKey)))].sort((a,b)=>filterLabel(a,openFilterKey).localeCompare(filterLabel(b,openFilterKey),undefined,{numeric:true}));
  const selected=activeColumnFilters[openFilterKey]||new Set(values);
  const needle=query.trim().toLowerCase();
  const options=$('#column-filter-options');
  if(!DATE_FILTER_KEYS.has(openFilterKey)){
    options.innerHTML=values.filter(value=>filterLabel(value,openFilterKey).toLowerCase().includes(needle)).map(value=>
      `<label class="column-filter-option"><input type="checkbox" data-filter-value value="${esc(value)}" ${selected.has(value)?'checked':''}><span title="${esc(filterLabel(value,openFilterKey))}">${esc(filterLabel(value,openFilterKey))}</span></label>`
    ).join('')||'<div class="empty-filter">No values found</div>';
    return;
  }
  const matching=values.filter(value=>value==='__blank__'||/^\d{4}-\d{2}-\d{2}$/.test(value)).filter(value=>{
    if(!needle)return true;
    if(value==='__blank__')return '(blank)'.includes(needle);
    const [year,month]=value.split('-');
    const monthName=new Date(Number(year),Number(month)-1,1).toLocaleString('en-IN',{month:'long'});
    return `${filterLabel(value,openFilterKey)} ${monthName} ${year}`.toLowerCase().includes(needle);
  });
  const groups={};
  matching.filter(v=>v!=='__blank__').forEach(value=>{const [year,month]=value.split('-');(groups[year]??={})[month]??=[];groups[year][month].push(value)});
  let html=Object.keys(groups).sort((a,b)=>b-a).map(year=>`<details class="date-year" ${needle?'open':''}><summary><input type="checkbox" class="date-parent"> ${year}</summary>${Object.keys(groups[year]).sort((a,b)=>a-b).map(month=>{const dates=groups[year][month];const monthName=new Date(Number(year),Number(month)-1,1).toLocaleString('en-IN',{month:'long'});return `<details class="date-month"><summary><input type="checkbox" class="date-parent"> ${esc(monthName)}</summary>${dates.map(value=>`<label class="column-filter-option date-leaf"><input type="checkbox" data-filter-value value="${value}" ${selected.has(value)?'checked':''}><span>${esc(filterLabel(value,openFilterKey))}</span></label>`).join('')}</details>`}).join('')}</details>`).join('');
  if(matching.includes('__blank__'))html+=`<label class="column-filter-option"><input type="checkbox" data-filter-value value="__blank__" ${selected.has('__blank__')?'checked':''}><span>(Blank)</span></label>`;
  options.innerHTML=html||'<div class="empty-filter">No dates found</div>';
  options.querySelectorAll('.date-parent').forEach(parent=>{
    const details=parent.closest('details'); const leaves=[...details.querySelectorAll('input[data-filter-value]')];
    parent.checked=leaves.length>0&&leaves.every(input=>input.checked);parent.indeterminate=leaves.some(input=>input.checked)&&!parent.checked;
    parent.addEventListener('click',event=>event.stopPropagation());
    parent.addEventListener('change',()=>{leaves.forEach(input=>input.checked=parent.checked)});
  });
}
function openColumnFilter(event,key){
  event.stopPropagation(); openFilterKey=key;
  const menu=$('#column-filter-menu'); const button=event.currentTarget; const rect=button.getBoundingClientRect();
  $('#column-filter-search').value=''; renderFilterOptions(); menu.classList.add('show');
  const left=Math.min(rect.left,window.innerWidth-menu.offsetWidth-8);
  menu.style.left=`${Math.max(8,left)}px`; menu.style.top=`${Math.min(rect.bottom+4,window.innerHeight-menu.offsetHeight-8)}px`;
  $('#column-filter-search').focus();
}
function closeColumnFilter(){ $('#column-filter-menu').classList.remove('show'); openFilterKey=null; }
function initColumnFilters(){
  $$('#work-table th[data-key]').forEach(th=>{
    const button=document.createElement('button');button.type='button';button.className='column-filter-toggle';button.textContent='▼';button.title='Filter';button.dataset.key=th.dataset.key;
    button.addEventListener('click',event=>openColumnFilter(event,th.dataset.key));th.appendChild(button);
  });
  $('#column-filter-search').addEventListener('input',e=>renderFilterOptions(e.target.value));
  $('#filter-select-all').addEventListener('click',()=>$$('#column-filter-options input').forEach(input=>{input.checked=true;input.indeterminate=false}));
  $('#filter-clear').addEventListener('click',()=>$$('#column-filter-options input').forEach(input=>{input.checked=false;input.indeterminate=false}));
  $('#filter-cancel').addEventListener('click',closeColumnFilter);
  $('#filter-apply').addEventListener('click',()=>{
    const allValues=new Set(items.map(item=>filterValue(item,openFilterKey)));
    const selected=new Set($$('#column-filter-options input[data-filter-value]:checked').map(input=>input.value));
    if(selected.size===allValues.size&&[...allValues].every(value=>selected.has(value)))delete activeColumnFilters[openFilterKey];
    else activeColumnFilters[openFilterKey]=selected;
    closeColumnFilter();applyColumnFilters();
  });
  $('#column-filter-menu').addEventListener('click',event=>event.stopPropagation());
  document.addEventListener('click',closeColumnFilter);
}
function openForm(item={}){
  $('#work-form').reset(); $('#item-id').value=item.id||''; $('#dialog-title').textContent=item.id?'Edit work':'Add new work';
  const map={'work-name':'work_name','item-status':'status','allotted-to':'allotted_to','section':'section','work-inflow':'work_inflow','next-scheduled':'next_scheduled','reschedule-scheduled':'reschedule_scheduled','target-date':'target_date','actual-completion-date':'actual_completion_date','remark':'remark'};
  Object.entries(map).forEach(([id,key])=>{if(item[key]) $(`#${id}`).value=item[key]});
  if(!item.id){
    const current=new Date(); current.setMinutes(current.getMinutes()-current.getTimezoneOffset());
    const today=current.toISOString().slice(0,10);
    ['#work-inflow','#next-scheduled','#reschedule-scheduled','#target-date'].forEach(id=>$(id).value=today);
    $('#section').value=loggedInUser?.name||'';
  }
  $('#work-dialog').showModal();
  updateAllotteeLoad();
}
window.editItem=async id=>{await loadAllottees();openForm(items.find(x=>x.id===id));};
window.showRemark=(event,id)=>{
  const item=items.find(x=>x.id===id); if(!item?.remark)return;
  const popup=$('#remark-popup'); const rect=event.currentTarget.getBoundingClientRect();
  popup.textContent=item.remark; popup.classList.add('show');
  const popupWidth=popup.offsetWidth; const left=rect.left-popupWidth-9;
  popup.style.left=`${Math.max(8,left)}px`;
  popup.style.top=`${Math.min(rect.top,window.innerHeight-popup.offsetHeight-8)}px`;
};
window.hideRemark=()=>$('#remark-popup').classList.remove('show');
window.completeItem=async id=>{try{await api(`/api/work/${id}/complete`,{method:'PATCH'});notify('Work completed');await Promise.all([loadWork(),loadSummary()]);}catch(e){showError(e.message)}};
window.deleteItem=async id=>{if(!confirm('Is work item ko Deleted Records me move karna hai?'))return;try{await api(`/api/work/${id}`,{method:'DELETE'});notify('Work moved to Deleted Records');await Promise.all([loadWork(),loadSummary()]);}catch(e){showError(e.message)}};

$('#work-form').addEventListener('submit',async e=>{e.preventDefault();const id=$('#item-id').value;
  const data={work_name:$('#work-name').value,status:$('#item-status').value,allotted_to:$('#allotted-to').value,section:$('#section').value,work_inflow:$('#work-inflow').value,next_scheduled:$('#next-scheduled').value,reschedule_scheduled:$('#reschedule-scheduled').value,target_date:$('#target-date').value,actual_completion_date:$('#actual-completion-date').value,remark:$('#remark').value};
  try{await api(id?`/api/work/${id}`:'/api/work',{method:id?'PUT':'POST',body:JSON.stringify(data)});$('#work-dialog').close();notify(id?'Work updated':'Work added');await Promise.all([loadWork(),loadSummary(),loadNotificationCount(),loadAllottees()]);}catch(err){alert(err.message)}
});
$$('[data-scope]').forEach(b=>b.addEventListener('click',()=>chooseScope(b.dataset.scope)));
$('#allotted-to').addEventListener('input',updateAllotteeLoad);$('#allotted-to').addEventListener('change',updateAllotteeLoad);
$('#status-filter').addEventListener('change',loadWork);$('#team-filter').addEventListener('change',()=>Promise.all([loadWork(),loadSummary()]));$('#search').addEventListener('input',()=>{clearTimeout(debounce);debounce=setTimeout(loadWork,300)});
$('#clear-filters-btn').addEventListener('click',()=>{activeColumnFilters={};applyColumnFilters();});
$('#export-btn').addEventListener('click',()=>{
  const params=new URLSearchParams({scope,status:$('#status-filter').value,search:$('#search').value.trim(),team:$('#team-filter').value||''});
  window.location.href=appUrl('/api/export?'+params);
});
$('#add-btn').addEventListener('click',async()=>{await loadAllottees();openForm();});['#close-dialog','#cancel-dialog'].forEach(s=>$(s).addEventListener('click',()=>$('#work-dialog').close()));
initColumnFilters();
Promise.all([loadWork(),loadSummary(),loadAllottees(),loadCurrentUser(),loadNotificationCount()]).catch(e=>showError(e.message));
setInterval(()=>loadNotificationCount().catch(()=>{}),60000);
setInterval(()=>{if(lastNotificationCount>0)shakeRequestButton();},30000);
