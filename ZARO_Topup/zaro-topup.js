import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

const SUPABASE_URL = "https://rtqdcbkttrxbmglzllmv.supabase.co";
const SUPABASE_KEY = "sb_publishable_iqwtKiJMmx9QEO4l1Zo7iQ_kHvZZH0c";
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const pages = {
  "Z-game-freefire.html": { slug: "free-fire", fallback: "Free Fire", symbol: "◆" },
  "Z-game-PUBG.html": { slug: "pubg-mobile", fallback: "PUBG Mobile", symbol: "UC" },
  "Z-game-COD.html": { slug: "call-of-duty", fallback: "Call of Duty Mobile", symbol: "CP" },
  "Z-game-FC.html": { slug: "fc-mobile", fallback: "EA SPORTS FC Mobile", symbol: "FC" },
  "Z-game-ML.html": { slug: "mobile-legends", fallback: "Mobile Legends", symbol: "◆" },
  "Z-game-Roblox.html": { slug: "roblox", fallback: "Roblox", symbol: "R$" }
};
const filename = location.pathname.split("/").pop();
const config = pages[filename];
const container = document.querySelector(".diamond-packages");
const playerInput = document.querySelector("#playerId");
const zoneInput = document.querySelector("#zoneId, #zoneIdInput");
const selectedPackage = document.querySelector("#selectedPackage");
const selectedPrice = document.querySelector("#selectedPrice");
const confirmButton = document.querySelector("#confirmOrder, #confirmButton");

let game = null;
let packages = [];
let selected = null;

function message(text) {
  let node = document.getElementById("zaroCheckoutMessage");
  if (!node) {
    node = document.createElement("p");
    node.id = "zaroCheckoutMessage";
    node.setAttribute("role", "status");
    node.style.cssText = "color:#ffc400;text-align:center;line-height:1.8;margin:12px 0";
    confirmButton?.insertAdjacentElement("afterend", node);
  }
  node.textContent = text;
}

function renderPackages() {
  if (!container) return;
  container.replaceChildren();
  if (!packages.length) {
    const empty = document.createElement("p");
    empty.className = "empty-message";
    empty.style.cssText = "grid-column:1/-1;text-align:center;padding:18px;color:#ffc400;line-height:1.9";
    empty.textContent = "الباقات هتظهر هنا تلقائيًا بعد اعتماد أسعارها وبيانات المورد من لوحة إدارة ZARO.";
    container.appendChild(empty);
    if (confirmButton) confirmButton.disabled = true;
    if (selectedPackage) selectedPackage.textContent = "لا توجد باقات متاحة";
    if (selectedPrice) selectedPrice.textContent = "—";
    return;
  }
  packages.forEach((item) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "diamond-card";
    button.innerHTML = '<span class="diamond-icon currency-mark"></span><strong></strong><small></small><b>اختيار الباقة</b>';
    button.querySelector(".diamond-icon").textContent = game.currency_label || config.symbol;
    button.querySelector("strong").textContent = item.amount_label || item.package_name;
    button.querySelector("small").textContent = Number(item.selling_price).toLocaleString("en-US") + " EGP";
    button.addEventListener("click", () => {
      container.querySelectorAll(".diamond-card").forEach((card) => card.classList.remove("selected"));
      button.classList.add("selected");
      selected = item;
      if (selectedPackage) selectedPackage.textContent = item.amount_label || item.package_name;
      if (selectedPrice) selectedPrice.textContent = Number(item.selling_price).toLocaleString("en-US") + " ج.م";
      if (confirmButton) confirmButton.disabled = false;
    });
    container.appendChild(button);
  });
  if (confirmButton) confirmButton.disabled = true;
}

function addCouponField() {
  if (!confirmButton || document.getElementById("zaroPromoCode")) return;
  const wrapper = document.createElement("label");
  wrapper.style.cssText = "display:block;margin:16px 0;color:#ffc400;font-weight:700";
  wrapper.textContent = "كود الخصم (اختياري)";
  const input = document.createElement("input");
  input.id = "zaroPromoCode";
  input.type = "text";
  input.maxLength = 40;
  input.autocomplete = "off";
  input.placeholder = "أدخل كود الخصم";
  input.style.cssText = "display:block;width:100%;margin-top:8px;padding:13px;border-radius:10px;border:1px solid #ff7900;background:#111;color:white;font:inherit";
  wrapper.appendChild(input);
  confirmButton.parentElement.insertBefore(wrapper, confirmButton);
}

async function loadCatalog() {
  if (!config || !container || !confirmButton) return;
  confirmButton.disabled = true;
  try {
    const { data: gameRow, error: gameError } = await supabase.from("catalog_games")
      .select("id,name_en,currency_label,is_active").eq("slug", config.slug).maybeSingle();
    if (gameError) throw gameError;
    if (!gameRow || !gameRow.is_active) {
      game = { name_en: config.fallback, currency_label: config.symbol };
      packages = [];
      renderPackages();
      return;
    }
    game = gameRow;
    const { data, error } = await supabase.from("catalog_packages")
      .select("id,package_name,amount_label,selling_price")
      .eq("game_id", game.id).eq("is_active", true).not("selling_price", "is", null)
      .order("sort_order", { ascending: true });
    if (error) throw error;
    packages = data || [];
    renderPackages();
    addCouponField();
  } catch (error) {
    console.error("ZARO catalog error:", error);
    message("تعذر تحميل الباقات حاليًا. حدّث الصفحة بعد قليل.");
  }
}

async function submitOrder() {
  const playerId = (playerInput?.value || "").trim();
  const zoneId = (zoneInput?.value || "").trim();
  if (!playerId || playerId.length < 3 || playerId.length > 40) {
    message("اكتب Player ID صحيحًا.");
    return;
  }
  if (config.slug === "mobile-legends" && !zoneId) {
    message("اكتب Zone ID الخاص بحسابك.");
    return;
  }
  if (!selected) {
    message("اختار باقة متاحة الأول.");
    return;
  }
  confirmButton.disabled = true;
  const originalText = confirmButton.textContent;
  confirmButton.textContent = "جاري إرسال الطلب...";
  try {
    const { data: { session } } = await supabase.auth.getSession();
    const promoCode = (document.getElementById("zaroPromoCode")?.value || "").trim().toUpperCase();
    const response = await fetch(SUPABASE_URL + "/functions/v1/create-order", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "apikey": SUPABASE_KEY,
        ...(session ? { "Authorization": "Bearer " + session.access_token } : {})
      },
      body: JSON.stringify({
        playerId, zoneId: zoneId || null,
        game: game.name_en || config.fallback,
        package: selected.package_name,
        promoCode: promoCode || null
      })
    });
    const result = await response.json();
    if (!response.ok || result.success !== true) throw new Error(result.error || "تعذر تسجيل الطلب.");
    const localOrders = JSON.parse(localStorage.getItem("zaroOrders") || "[]");
    localOrders.unshift({
      id: result.orderId, game: game.name_en || config.fallback,
      playerId, zoneId: zoneId || null, package: selected.package_name,
      price: result.amount, status: "pending", date: new Date().toLocaleString("ar-EG")
    });
    localStorage.setItem("zaroOrders", JSON.stringify(localOrders));
    message("تم تسجيل الطلب بنجاح. حالته قيد الانتظار لحين تفعيل الدفع والشحن.");
    window.location.href = "ZOrders.html";
  } catch (error) {
    message(error.message || "حصلت مشكلة أثناء تسجيل الطلب.");
    confirmButton.disabled = false;
    confirmButton.textContent = originalText;
  }
}

if (config && confirmButton) {
  addCouponField();
  confirmButton.addEventListener("click", submitOrder);
  loadCatalog();
}
