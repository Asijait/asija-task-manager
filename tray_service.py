import ctypes
import os
import socket
import subprocess
import sys
import threading
import time
import webbrowser
from ctypes import wintypes


APP_NAME = "Asija TaskFlow"
PUBLIC_DOMAIN = "asijatask.asijaapp.fun"
PORT = 5001
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
APP_URL = f"http://127.0.0.1:{PORT}"
APP_SCRIPT = os.path.join(BASE_DIR, "app.py")
LOG_FILE = os.path.join(BASE_DIR, "asija_taskflow_tray.log")
ICON_FILE = os.path.join(BASE_DIR, "asija_taskflow.ico")
START_LOCK_FILE = os.path.join(BASE_DIR, "asija_taskflow_start.lock")

WM_CLOSE = 0x0010
WM_DESTROY = 0x0002
WM_COMMAND = 0x0111
WM_USER = 0x0400
WM_TRAY = WM_USER + 20
WM_LBUTTONDBLCLK = 0x0203
WM_RBUTTONUP = 0x0205
NIM_ADD = 0x00000000
NIM_MODIFY = 0x00000001
NIM_DELETE = 0x00000002
NIF_MESSAGE = 0x00000001
NIF_ICON = 0x00000002
NIF_TIP = 0x00000004
IDI_APPLICATION = 32512
IMAGE_ICON = 1
LR_DEFAULTSIZE = 0x00000040
LR_LOADFROMFILE = 0x00000010
MF_STRING = 0x00000000
MF_SEPARATOR = 0x00000800
TPM_RIGHTBUTTON = 0x0002
TPM_RETURNCMD = 0x0100
MF_GRAYED = 0x00000001
MB_OK = 0x00000000
MB_ICONINFORMATION = 0x00000040

MENU_OPEN_LOCAL = 1001
MENU_OPEN_LAN = 1002
MENU_SHOW_URLS = 1003
MENU_START = 1004
MENU_STOP = 1005
MENU_RESTART = 1006
MENU_EXIT = 1007
CONTROL_MENU = os.path.join(BASE_DIR, "asija_tray_menu.py")


class NOTIFYICONDATA(ctypes.Structure):
    _fields_ = [
        ("cbSize", wintypes.DWORD),
        ("hWnd", wintypes.HWND),
        ("uID", wintypes.UINT),
        ("uFlags", wintypes.UINT),
        ("uCallbackMessage", wintypes.UINT),
        ("hIcon", wintypes.HICON),
        ("szTip", wintypes.WCHAR * 128),
    ]


class POINT(ctypes.Structure):
    _fields_ = [("x", ctypes.c_long), ("y", ctypes.c_long)]


WNDPROC = ctypes.WINFUNCTYPE(
    ctypes.c_long,
    wintypes.HWND,
    wintypes.UINT,
    wintypes.WPARAM,
    wintypes.LPARAM,
)


class WNDCLASS(ctypes.Structure):
    _fields_ = [
        ("style", wintypes.UINT),
        ("lpfnWndProc", WNDPROC),
        ("cbClsExtra", ctypes.c_int),
        ("cbWndExtra", ctypes.c_int),
        ("hInstance", wintypes.HINSTANCE),
        ("hIcon", wintypes.HICON),
        ("hCursor", wintypes.HCURSOR),
        ("hbrBackground", wintypes.HBRUSH),
        ("lpszMenuName", wintypes.LPCWSTR),
        ("lpszClassName", wintypes.LPCWSTR),
    ]


user32 = ctypes.windll.user32
shell32 = ctypes.windll.shell32
kernel32 = ctypes.windll.kernel32

user32.AppendMenuW.argtypes = [
    wintypes.HMENU,
    wintypes.UINT,
    wintypes.WPARAM,
    wintypes.LPCWSTR,
]
user32.CreatePopupMenu.restype = wintypes.HMENU
user32.TrackPopupMenu.argtypes = [
    wintypes.HMENU,
    wintypes.UINT,
    ctypes.c_int,
    ctypes.c_int,
    ctypes.c_int,
    wintypes.HWND,
    ctypes.c_void_p,
]
user32.TrackPopupMenu.restype = wintypes.UINT
user32.DestroyMenu.argtypes = [wintypes.HMENU]
user32.MessageBoxW.argtypes = [
    wintypes.HWND,
    wintypes.LPCWSTR,
    wintypes.LPCWSTR,
    wintypes.UINT,
]
shell32.Shell_NotifyIconW.argtypes = [wintypes.DWORD, ctypes.POINTER(NOTIFYICONDATA)]


def log(message):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a", encoding="utf-8") as handle:
        handle.write(f"[{timestamp}] {message}\n")


def ensure_icon_file():
    if os.path.exists(ICON_FILE):
        return

    width = 32
    height = 32
    pixels = []
    for y in range(height):
        for x in range(width):
            dx = x - 15.5
            dy = y - 15.5
            if dx * dx + dy * dy <= 14 * 14:
                if x < 16 and y < 16:
                    pixels.append((255, 102, 51, 255))
                elif x >= 16 and y < 16:
                    pixels.append((53, 121, 246, 255))
                elif x < 16:
                    pixels.append((38, 166, 91, 255))
                else:
                    pixels.append((255, 196, 0, 255))
            else:
                pixels.append((0, 0, 0, 0))

    xor_rows = []
    for y in range(height - 1, -1, -1):
        row = bytearray()
        for x in range(width):
            r, g, b, a = pixels[y * width + x]
            row.extend([b, g, r, a])
        xor_rows.append(row)

    mask_stride = ((width + 31) // 32) * 4
    and_mask = b"\x00" * (mask_stride * height)
    bitmap_header = (
        (40).to_bytes(4, "little")
        + width.to_bytes(4, "little")
        + (height * 2).to_bytes(4, "little")
        + (1).to_bytes(2, "little")
        + (32).to_bytes(2, "little")
        + (0).to_bytes(4, "little")
        + (width * height * 4).to_bytes(4, "little")
        + (0).to_bytes(4, "little")
        + (0).to_bytes(4, "little")
        + (0).to_bytes(4, "little")
        + (0).to_bytes(4, "little")
    )
    image_data = bitmap_header + b"".join(xor_rows) + and_mask
    icon_dir = (0).to_bytes(2, "little") + (1).to_bytes(2, "little") + (1).to_bytes(2, "little")
    icon_entry = (
        bytes([width, height, 0, 0])
        + (1).to_bytes(2, "little")
        + (32).to_bytes(2, "little")
        + len(image_data).to_bytes(4, "little")
        + (6 + 16).to_bytes(4, "little")
    )
    with open(ICON_FILE, "wb") as handle:
        handle.write(icon_dir + icon_entry + image_data)


def is_server_running():
    try:
        with socket.create_connection(("127.0.0.1", PORT), timeout=0.5):
            return True
    except OSError:
        return False


def lan_url():
    try:
        udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        udp_socket.connect(("8.8.8.8", 80))
        ip_address = udp_socket.getsockname()[0]
        udp_socket.close()
    except OSError:
        ip_address = socket.gethostbyname(socket.gethostname())
    if not ip_address or ip_address.startswith("127."):
        return APP_URL
    return f"http://{ip_address}:{PORT}"


def office_domain_url():
    return f"http://{PUBLIC_DOMAIN}:{PORT}"


def pythonw_path():
    candidates = [
        os.path.join(BASE_DIR, "venv", "Scripts", "python.exe"),
        os.path.join(BASE_DIR, "venv", "Scripts", "pythonw.exe"),
        sys.executable,
        "python",
    ]
    for candidate in candidates:
        if not candidate:
            continue
        if candidate != "python" and not os.path.exists(candidate):
            continue
        result = subprocess.run(
            [candidate, "-c", "import sys"],
            cwd=BASE_DIR,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=subprocess.CREATE_NO_WINDOW,
            check=False,
        )
        if result.returncode == 0:
            return candidate
    return "python"


def start_server():
    if is_server_running():
        return

    lock_fd = None
    try:
        lock_fd = os.open(START_LOCK_FILE, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        os.write(lock_fd, str(os.getpid()).encode("ascii"))
    except FileExistsError:
        return

    try:
        if is_server_running():
            return
        log("Starting server")
        subprocess.Popen(
            [pythonw_path(), APP_SCRIPT],
            cwd=BASE_DIR,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=subprocess.CREATE_NO_WINDOW,
        )
    finally:
        if lock_fd is not None:
            os.close(lock_fd)
        try:
            os.remove(START_LOCK_FILE)
        except OSError:
            pass


def listening_pids():
    result = subprocess.run(
        ["netstat", "-ano"],
        cwd=BASE_DIR,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW,
        text=True,
        check=False,
    )
    pids = set()
    for line in result.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 5 and parts[0].upper() == "TCP":
            local_address = parts[1]
            state = parts[3].upper()
            pid = parts[4]
            if local_address.endswith(f":{PORT}") and state == "LISTENING":
                pids.add(pid)
    return pids


def stop_server():
    log("Stopping server")
    try:
        os.remove(START_LOCK_FILE)
    except OSError:
        pass
    for pid in listening_pids():
        subprocess.run(
            ["taskkill", "/F", "/PID", pid, "/T"],
            cwd=BASE_DIR,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=subprocess.CREATE_NO_WINDOW,
            check=False,
        )


def restart_server():
    stop_server()
    time.sleep(1)
    start_server()


def open_local_website():
    start_server()
    webbrowser.open(APP_URL)


def open_lan_website():
    start_server()
    webbrowser.open(lan_url())


def show_urls(hwnd):
    status = "Running" if is_server_running() else "Stopped"
    message = (
        f"Status: {status}\n\n"
        f"Local URL:\n{APP_URL}\n\n"
        f"LAN/Online URL:\n{lan_url()}\n\n"
        "Note: Ye URL tabhi online rahega jab ye computer on ho aur same network se access ho."
    )
    user32.MessageBoxW(hwnd, message, APP_NAME, MB_OK | MB_ICONINFORMATION)


def open_control_menu():
    subprocess.Popen(
        [pythonw_path(), CONTROL_MENU],
        cwd=BASE_DIR,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW,
    )


def run_async(target):
    threading.Thread(target=target, daemon=True).start()


class TrayApp:
    def __init__(self):
        self.class_name = "AsijaTaskFlowTrayWindow"
        self.message_map = {}
        self.wndproc = WNDPROC(self.window_proc)
        self.hinst = kernel32.GetModuleHandleW(None)
        self.hwnd = None
        self.icon = None
        self.keep_running = True

    def watchdog(self):
        while self.keep_running:
            if not is_server_running():
                start_server()
            time.sleep(30)

    def create_window(self):
        wndclass = WNDCLASS()
        wndclass.lpfnWndProc = self.wndproc
        wndclass.hInstance = self.hinst
        wndclass.lpszClassName = self.class_name
        user32.RegisterClassW(ctypes.byref(wndclass))
        self.hwnd = user32.CreateWindowExW(
            0,
            self.class_name,
            APP_NAME,
            0,
            0,
            0,
            0,
            0,
            None,
            None,
            self.hinst,
            None,
        )

    def add_icon(self):
        ensure_icon_file()
        self.icon = user32.LoadImageW(
            None, ICON_FILE, IMAGE_ICON, 32, 32, LR_LOADFROMFILE
        )
        if not self.icon:
            self.icon = user32.LoadImageW(
                None, IDI_APPLICATION, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE
            )
        data = NOTIFYICONDATA()
        data.cbSize = ctypes.sizeof(NOTIFYICONDATA)
        data.hWnd = self.hwnd
        data.uID = 1
        data.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP
        data.uCallbackMessage = WM_TRAY
        data.hIcon = self.icon
        data.szTip = APP_NAME
        shell32.Shell_NotifyIconW(NIM_ADD, ctypes.byref(data))

    def update_tip(self):
        status = "Running" if is_server_running() else "Stopped"
        data = NOTIFYICONDATA()
        data.cbSize = ctypes.sizeof(NOTIFYICONDATA)
        data.hWnd = self.hwnd
        data.uID = 1
        data.uFlags = NIF_TIP
        data.szTip = f"{APP_NAME} - {status}"
        shell32.Shell_NotifyIconW(NIM_MODIFY, ctypes.byref(data))

    def remove_icon(self):
        data = NOTIFYICONDATA()
        data.cbSize = ctypes.sizeof(NOTIFYICONDATA)
        data.hWnd = self.hwnd
        data.uID = 1
        shell32.Shell_NotifyIconW(NIM_DELETE, ctypes.byref(data))

    def show_menu(self):
        self.update_tip()
        run_async(open_control_menu)

    def handle_command(self, command_id):
        if command_id == MENU_OPEN_LOCAL:
            run_async(open_local_website)
        elif command_id == MENU_OPEN_LAN:
            run_async(open_lan_website)
        elif command_id == MENU_SHOW_URLS:
            show_urls(self.hwnd)
        elif command_id == MENU_START:
            run_async(start_server)
        elif command_id == MENU_STOP:
            run_async(stop_server)
        elif command_id == MENU_RESTART:
            run_async(restart_server)
        elif command_id == MENU_EXIT:
            user32.DestroyWindow(self.hwnd)

    def window_proc(self, hwnd, msg, wparam, lparam):
        if msg == WM_TRAY:
            if lparam == WM_RBUTTONUP:
                self.show_menu()
            elif lparam == WM_LBUTTONDBLCLK:
                run_async(open_local_website)
            return 0
        if msg == WM_COMMAND:
            self.handle_command(wparam & 0xFFFF)
            return 0
        if msg == WM_DESTROY:
            self.keep_running = False
            self.remove_icon()
            user32.PostQuitMessage(0)
            return 0
        return user32.DefWindowProcW(hwnd, msg, wparam, lparam)

    def run(self):
        self.create_window()
        self.add_icon()
        run_async(start_server)
        run_async(self.watchdog)

        msg = wintypes.MSG()
        while user32.GetMessageW(ctypes.byref(msg), None, 0, 0) != 0:
            user32.TranslateMessage(ctypes.byref(msg))
            user32.DispatchMessageW(ctypes.byref(msg))


if __name__ == "__main__":
    os.chdir(BASE_DIR)
    log("Tray started")
    old_hwnd = user32.FindWindowW("AsijaTaskFlowTrayWindow", None)
    if old_hwnd:
        user32.PostMessageW(old_hwnd, WM_CLOSE, 0, 0)
        time.sleep(0.5)
    TrayApp().run()
