const { app, BrowserWindow, shell } = require("electron");

const ADMIN_URL = "https://zaro-store.github.io/zaro-Test/ZARO_Topup/admin.html";

function createWindow() {
  const win = new BrowserWindow({
    width: 1440,
    height: 900,
    minWidth: 1050,
    minHeight: 680,
    title: "ZARO Admin",
    backgroundColor: "#0b0b0d",
    autoHideMenuBar: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true
    }
  });

  win.loadURL(ADMIN_URL);

  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith("https://") || url.startsWith("http://")) {
      shell.openExternal(url);
    }
    return { action: "deny" };
  });

  win.webContents.on("will-navigate", (event, url) => {
    if (!url.startsWith("https://zaro-store.github.io/")) {
      event.preventDefault();
      if (url.startsWith("https://") || url.startsWith("http://")) {
        shell.openExternal(url);
      }
    }
  });
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