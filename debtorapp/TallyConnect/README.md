# Tally Combined Sales Register — Standalone App

Ye ek standalone Python GUI app hai jo **seedha Tally Prime se connect** hota hai
(uska built-in XML/HTTP interface use karke) — Claude ki koi zaroorat nahi
isko chalane ke liye.

## Setup (ek baar)

1. **Tally Prime** khula rahe, jin companies ka data chahiye wo open/loaded ho.
2. Tally ka XML server on karo:
   `Tally > F1 (Help) > Settings > Connectivity`
   - "Tally Prime is Action as" → **Server**
   - Port → **9000** (default)
3. Python 3.8+ install ho. Fir terminal/cmd me:
   ```
   pip install requests openpyxl
   ```
   (tkinter Python ke saath already aata hai Windows/Mac par)

## Chalane ka tareeka

```
python tally_sales_register_app.py
```

Ek window khulegi:
1. **"Refresh companies"** dabao — Tally me jo bhi companies open hain, unki list aa jayegi checkboxes ke saath.
2. Jin companies ka report chahiye unhe tick karo (ya "Select all").
3. **From / To date** set karo (format: YYYY-MM-DD).
4. **"Generate combined sales register (Excel)"** dabao — Save As dialog aayega, jaha chaho save karo.

Output ek single Excel sheet hoga:
- Har row = ek sales voucher
- Column: **Company**, Date, Voucher Type, Voucher No., Party Name, fir har
  income/sales ledger ka apna column, aur last me **Total** (formula se).
- Neeche column-wise grand totals bhi honge.

## Kaise kaam karta hai (technical)

- Tally `http://localhost:9000` par XML requests accept karta hai.
- App ek chhota TDL (Tally Definition Language) "Collection" request bhejta
  hai company list ke liye, aur har selected company ke liye ek voucher
  collection request (voucher type me "Sale" wale sab vouchers, unki
  ledger entries samet) diye gaye date range me.
- Party ledger (jo voucher header me already milta hai) ko chhodkar, baaki
  saari ledger entries "income ledger" columns ban jaati hain.

## Common issues

- **"Could not connect to Tally"** → Tally band hai, ya XML server "Server"
  mode me nahi hai, ya port 9000 kisi aur cheez ne le rakha hai.
- **Company list khaali aa rahi hai** → Us company ko Tally me actually
  open/load karo (sirf list me hona kaafi nahi, load hona chahiye).
- **Kuch companies me koi data nahi mil raha** → Us company me us date
  range me "Sale" type ka koi voucher nahi hai, ya voucher type ka naam
  alag hai (jaise "Sales" ke bajaye kuch aur naam use ho raha hai).
