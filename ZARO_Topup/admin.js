
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

const SUPABASE_URL = "https://rtqdcbkttrxbmglzllmv.supabase.co";
const SUPABASE_KEY = "sb_publishable_iqwtKiJMmx9QEO4l1Zo7iQ_kHvZZH0c";
const ADMIN_UID = "1bb9ddef-57a8-43d2-bf0c-be6d0b1f1cac";

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const loginSection = document.getElementById("loginSection");
const dashboardSection = document.getElementById("dashboardSection");

const loginForm = document.getElementById("loginForm");
const loginButton = document.getElementById("loginButton");
const loginMessage = document.getElementById("loginMessage");
const logoutButton = document.getElementById("logoutButton");

const totalOrders = document.getElementById("totalOrders");
const completedOrders = document.getElementById("completedOrders");
const pendingOrders = document.getElementById("pendingOrders");
const totalSales = document.getElementById("totalSales");

const recentOrders = document.getElementById("recentOrders");
const allOrders = document.getElementById("allOrders");
const orderSearch = document.getElementById("orderSearch");
const pageTitle = document.getElementById("pageTitle");

let orders = [];

const pageNames = {
    overview: "نظرة عامة",
    orders: "إدارة الطلبات",
    products: "الألعاب والباقات",
    customers: "العملاء",
    settings: "الإعدادات"
};

function showLogin() {
    loginSection.hidden = false;
    dashboardSection.hidden = true;
    document.body.classList.add("admin-login-page");
}

function showDashboard() {
    loginSection.hidden = true;
    dashboardSection.hidden = false;
    document.body.classList.remove("admin-login-page");
}

function escapeHTML(value) {
    return String(value ?? "").replace(/[&<>"']/g, char => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
    })[char]);
}

function formatMoney(value) {
    return Number(value || 0).toLocaleString("ar-EG", {
        maximumFractionDigits: 2
    }) + " ج.م";
}

function formatDate(value) {
    if (!value) return "-";

    return new Date(value).toLocaleDateString("ar-EG", {
        year: "numeric",
        month: "short",
        day: "numeric"
    });
}

function statusLabel(status) {
    const labels = {
        pending: "قيد الانتظار",
        completed: "مكتمل",
        rejected: "مرفوض"
    };

    return labels[status] || status;
}

function statusClass(status) {
    if (status === "completed") return "completed";
    if (status === "rejected") return "rejected";
    return "pending";
}

function orderRow(order, showActions = false) {
    const id = escapeHTML(order.id);
    const status = escapeHTML(order.status);
    const game = escapeHTML(order.game);
    const player = escapeHTML(order.player_id);
    const packageName = escapeHTML(order.package);

    return `
        <tr>
            <td>#${id}</td>
            <td>${game}</td>
            <td>${player}</td>
            <td>${packageName}</td>
            <td>${formatMoney(order.amount)}</td>
            ${showActions ? `<td>${formatDate(order.created_at)}</td>` : ""}
            <td>
                <span class="order-status ${statusClass(order.status)}">
                    ${escapeHTML(statusLabel(order.status))}
                </span>
            </td>
            ${showActions ? `
                <td>
                    <select class="status-select" data-order-id="${id}">
                        <option value="pending" ${status === "pending" ? "selected" : ""}>معلق</option>
                        <option value="completed" ${status === "completed" ? "selected" : ""}>مكتمل</option>
                        <option value="rejected" ${status === "rejected" ? "selected" : ""}>مرفوض</option>
                    </select>
                </td>
            ` : ""}
        </tr>
    `;
}

function renderOrders() {
    if (!orders.length) {
        recentOrders.innerHTML =
            `<tr><td colspan="6">لا توجد طلبات حتى الآن.</td></tr>`;

        allOrders.innerHTML =
            `<tr><td colspan="8">لا توجد طلبات حتى الآن.</td></tr>`;

        return;
    }

    recentOrders.innerHTML = orders
        .slice(0, 5)
        .map(order => orderRow(order))
        .join("");

    renderAllOrders();
}

function renderAllOrders() {
    const search = orderSearch.value.trim().toLowerCase();

    const filtered = orders.filter(order =>
        String(order.id).toLowerCase().includes(search) ||
        String(order.player_id).toLowerCase().includes(search) ||
        String(order.game).toLowerCase().includes(search)
    );

    allOrders.innerHTML = filtered.length
        ? filtered.map(order => orderRow(order, true)).join("")
        : `<tr><td colspan="8">لا توجد نتائج مطابقة.</td></tr>`;
}

function updateStats() {
    const completed = orders.filter(order => order.status === "completed");
    const pending = orders.filter(order => order.status === "pending");

    const sales = completed.reduce(
        (sum, order) => sum + Number(order.amount || 0),
        0
    );

    totalOrders.textContent = orders.length.toLocaleString("ar-EG");
    completedOrders.textContent = completed.length.toLocaleString("ar-EG");
    pendingOrders.textContent = pending.length.toLocaleString("ar-EG");
    totalSales.textContent = formatMoney(sales);
}

async function loadOrders() {
    recentOrders.innerHTML =
        `<tr><td colspan="6">جاري تحميل الطلبات...</td></tr>`;

    allOrders.innerHTML =
        `<tr><td colspan="8">جاري تحميل الطلبات...</td></tr>`;

    const { data, error } = await supabase
        .from("orders")
        .select("*")
        .order("created_at", { ascending: false });

    if (error) {
        console.error(error);

        recentOrders.innerHTML =
            `<tr><td colspan="6">تعذر تحميل الطلبات.</td></tr>`;

        allOrders.innerHTML =
            `<tr><td colspan="8">تعذر تحميل الطلبات: ${escapeHTML(error.message)}</td></tr>`;

        return;
    }

    orders = data || [];

    updateStats();
    renderOrders();
}

async function checkAdminSession() {
    const { data, error } = await supabase.auth.getSession();

    if (error || !data.session) {
        showLogin();
        return;
    }

    if (data.session.user.id !== ADMIN_UID) {
        await supabase.auth.signOut();
        showLogin();
        return;
    }

    showDashboard();
    await loadOrders();
}

// تسجيل الدخول
loginForm.addEventListener("submit", async event => {
    event.preventDefault();

    loginButton.disabled = true;
    loginButton.textContent = "جاري التحقق...";
    loginMessage.textContent = "";

    try {
        const email = document.getElementById("email").value.trim();
        const password = document.getElementById("password").value;

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) throw error;

        if (data.user.id !== ADMIN_UID) {
            await supabase.auth.signOut();
            throw new Error("هذا الحساب غير مصرح له بالدخول.");
        }

        loginMessage.style.color = "#39d98a";
        loginMessage.textContent = "تم تسجيل الدخول بنجاح.";

        showDashboard();
        await loadOrders();

    } catch (error) {
        loginMessage.style.color = "#ff6262";
        loginMessage.textContent = error.message;
    } finally {
        loginButton.disabled = false;
        loginButton.textContent = "تسجيل الدخول";
    }
});

// التنقل بين الصفحات
document.querySelectorAll("[data-page]").forEach(button => {
    button.addEventListener("click", () => {
        const page = button.dataset.page;
        const target = document.getElementById(`page-${page}`);

        if (!target) return;

        document.querySelectorAll(".dashboard-page")
            .forEach(section => section.classList.remove("active"));

        target.classList.add("active");

        document.querySelectorAll(".nav-item")
            .forEach(item => item.classList.remove("active"));

        document.querySelectorAll(`.nav-item[data-page="${page}"]`)
            .forEach(item => item.classList.add("active"));

        pageTitle.textContent = pageNames[page] || "ZARO";
    });
});

// البحث
orderSearch.addEventListener("input", renderAllOrders);

// تغيير حالة الطلب
allOrders.addEventListener("change", async event => {
    const select = event.target.closest(".status-select");

    if (!select) return;

    const orderId = select.dataset.orderId;
    const newStatus = select.value;

    select.disabled = true;

    const { error } = await supabase
        .from("orders")
        .update({ status: newStatus })
        .eq("id", orderId);

    select.disabled = false;

    if (error) {
        alert("فشل تحديث حالة الطلب: " + error.message);
        await loadOrders();
        return;
    }

    await loadOrders();
});

// تسجيل الخروج
logoutButton.addEventListener("click", async () => {
    const { error } = await supabase.auth.signOut();

    if (error) {
        alert("تعذر تسجيل الخروج: " + error.message);
        return;
    }

    orders = [];
    loginForm.reset();
    loginMessage.textContent = "";
    showLogin();
});

// مراقبة انتهاء الجلسة
supabase.auth.onAuthStateChange((event, session) => {
    if (event === "SIGNED_OUT" || !session) {
        showLogin();
    }
});

// تشغيل اللوحة عند فتح الصفحة
checkAdminSession();

