const { app, BrowserWindow, shell } = require("electron");

const ADMIN_URL = "https://zaro-store.github.io/zaro-Test/ZARO_Topup/admin.html";
const ADMIN_ORIGIN = new URL(ADMIN_URL).origin;

function createWindow() {
  const win = new BrowserWindow({
    width: 1440,
    height: 920,
    minWidth: 980,
    minHeight: 650,
    title: "ZARO Admin",
    autoHideMenuBar: true,
    backgroundColor: "#080808",
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true
    }
  });

  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith("https://")) shell.openExternal(url);
    return { action: "deny" };
  });

  win.webContents.on("will-navigate", (event, url) => {
    try {
      if (new URL(url).origin !== ADMIN_ORIGIN) {
        event.preventDefault();
        if (url.startsWith("https://")) shell.openExternal(url);
      }
    } catch {
      event.preventDefault();
    }
  });

  win.loadURL(ADMIN_URL);
}

app.whenReady().then(() => {
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
