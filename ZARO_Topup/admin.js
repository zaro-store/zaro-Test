import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

const SUPABASE_URL = "https://rtqdcbkttrxbmglzllmv.supabase.co";
const SUPABASE_KEY = "sb_publishable_iqwtKiJMmx9QEO4l1Zo7iQ_kHvZZH0c";
const ADMIN_UID = "1bb9ddef-57a8-43d2-bf0c-be6d0b1f1cac";
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const $ = (id) => document.getElementById(id);
const loginSection = $("loginSection"), dashboardSection = $("dashboardSection");
const loginForm = $("loginForm"), loginButton = $("loginButton"), loginMessage = $("loginMessage");
const pageNames = {overview:"نظرة عامة",orders:"إدارة الطلبات",products:"الألعاب والباقات",customers:"العملاء",support:"الدعم الفني",settings:"إعدادات النظام",operations:"مركز التشغيل والتسعير",app:"إدارة التطبيق"};
let orders=[], games=[], packages=[], customers=[], tickets=[], appUsers=[], selectedTicket=null, currentUser=null;

function escapeHTML(v){return String(v??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));}
function money(v){return v===null||v===undefined||v===""?"غير محدد":Number(v).toLocaleString("ar-EG",{maximumFractionDigits:2})+" ج.م";}
function date(v){return v?new Date(v).toLocaleString("ar-EG",{dateStyle:"medium",timeStyle:"short"}):"—";}
function statusText(s){return ({pending:"قيد الانتظار",completed:"مكتمل",rejected:"مرفوض",demo:"تجريبي",open:"مفتوحة",answered:"تم الرد",closed:"مغلقة",active:"نشط",suspended:"موقوف"}[s]||s||"غير محدد");}
function statusClass(s){return ["completed","active","answered"].includes(s)?"completed":["rejected","suspended","closed"].includes(s)?"rejected":s==="demo"?"demo":"pending";}
function showLogin(){loginSection.hidden=false;dashboardSection.hidden=true;document.body.classList.add("admin-login-page");}
function showDashboard(){loginSection.hidden=true;dashboardSection.hidden=false;document.body.classList.remove("admin-login-page");}
function notify(msg){const n=document.createElement("div");n.className="admin-toast";n.textContent=msg;document.body.append(n);setTimeout(()=>n.remove(),3500);}
function showPage(page){const target=$("page-"+page);if(!target)return;document.querySelectorAll(".dashboard-page").forEach(x=>x.classList.remove("active"));target.classList.add("active");document.querySelectorAll(".nav-item").forEach(x=>x.classList.toggle("active",x.dataset.page===page));$("pageTitle").textContent=pageNames[page]||"ZARO";$("sidebar").classList.remove("mobile-open");document.body.classList.remove("admin-menu-open");window.scrollTo({top:0,behavior:"smooth"});}
function setLoadingRow(id,cols,msg="جاري التحميل..."){$(id).innerHTML='<tr><td colspan="'+cols+'">'+escapeHTML(msg)+'</td></tr>';}

async function loadOrders(){
 const {data,error}=await supabase.from("orders").select("*").order("created_at",{ascending:false});
 if(error)throw error;orders=data||[];renderOrders();updateStats();
}
function orderRow(o,actions=false){
 const state=escapeHTML(o.status);
 return '<tr><td>#'+escapeHTML(o.id)+'</td><td>'+escapeHTML(o.customer_name||"—")+'</td><td>'+escapeHTML(o.game)+'</td><td>'+escapeHTML(o.player_id)+'</td><td>'+escapeHTML(o.package)+'</td><td>'+money(o.amount)+'</td><td>'+date(o.created_at)+'</td><td><span class="order-status '+statusClass(o.status)+'">'+statusText(o.status)+'</span></td><td>'+(actions&&o.status!=="demo"?'<select class="row-action-select order-state-select" data-id="'+escapeHTML(o.id)+'"><option value="pending" '+(state==="pending"?"selected":"")+'>قيد الانتظار</option><option value="completed" '+(state==="completed"?"selected":"")+'>مكتمل</option><option value="rejected" '+(state==="rejected"?"selected":"")+'>مرفوض</option></select>':(o.status==="demo"?"طلب تجريبي":"—"))+'</td></tr>';
}
function renderOrders(){
 const q=($("orderSearch")?.value||"").trim().toLowerCase(), st=$("orderStatusFilter")?.value||"";
 const filtered=orders.filter(o=>(!st||o.status===st)&&[o.id,o.customer_name,o.game,o.player_id,o.package].some(v=>String(v??"").toLowerCase().includes(q)));
 $("recentOrders").innerHTML=orders.length?orders.slice(0,6).map(o=>'<tr><td>#'+escapeHTML(o.id)+'</td><td>'+escapeHTML(o.game)+'</td><td>'+escapeHTML(o.player_id)+'</td><td>'+escapeHTML(o.package)+'</td><td>'+money(o.amount)+'</td><td><span class="order-status '+statusClass(o.status)+'">'+statusText(o.status)+'</span></td></tr>').join(""):'<tr><td colspan="6">لا توجد طلبات حتى الآن.</td></tr>';
 $("allOrders").innerHTML=filtered.length?filtered.map(o=>orderRow(o,true)).join(""):'<tr><td colspan="9">لا توجد نتائج مطابقة.</td></tr>';
 $("ordersResultCount").textContent=filtered.length+" طلب";
 $("pendingNavCount").textContent=orders.length.toLocaleString("ar-EG");
}
function updateStats(){
 const done=orders.filter(o=>o.status==="completed"),pending=orders.filter(o=>o.status==="pending");
 $("totalOrders").textContent=orders.length.toLocaleString("ar-EG");
 $("completedOrders").textContent=done.length.toLocaleString("ar-EG");
 $("pendingOrders").textContent=pending.length.toLocaleString("ar-EG");
 $("totalSales").textContent=money(done.reduce((s,o)=>s+Number(o.amount||0),0));
}

async function loadCatalog(){
 const [g,p]=await Promise.all([supabase.from("catalog_games").select("*").order("sort_order"),supabase.from("catalog_packages").select("*").order("sort_order")]);
 if(g.error)throw g.error;if(p.error)throw p.error;games=g.data||[];packages=p.data||[];renderCatalog();
}
function renderCatalog(){
 $("gamesCount").textContent=games.length;$("packagesCount").textContent=packages.length;
 $("gamesGrid").innerHTML=games.map(g=>{const count=packages.filter(p=>p.game_id===g.id).length;return '<article class="game-admin-card"><div><span class="game-dot"></span><strong>'+escapeHTML(g.name_en||g.name_ar)+'</strong></div><p>'+escapeHTML(g.name_ar)+' · '+count+' باقة</p><div class="game-card-foot"><span class="order-status '+(g.is_active?"completed":"pending")+'">'+(g.is_active?"مفعّلة":"غير مفعّلة")+'</span><button class="mini-button game-toggle" data-id="'+g.id+'" data-active="'+g.is_active+'">'+(g.is_active?"إيقاف اللعبة":"تفعيل اللعبة")+'</button></div></article>';}).join("");
 const old=$("packageGameFilter").value;
 $("packageGameFilter").innerHTML='<option value="">كل الألعاب</option>'+games.map(g=>'<option value="'+g.id+'">'+escapeHTML(g.name_en||g.name_ar)+'</option>').join("");
 $("packageGameFilter").value=old;
 renderPackages();
}
function renderPackages(){
 const q=($("packageSearch").value||"").trim().toLowerCase(),gid=$("packageGameFilter").value;
 const filtered=packages.filter(p=>{const g=games.find(x=>x.id===p.game_id);return (!gid||p.game_id===gid)&&[p.package_name,p.amount_label,g?.name_en,g?.name_ar].some(v=>String(v||"").toLowerCase().includes(q));});
 $("packagesTable").innerHTML=filtered.length?filtered.map(p=>{const g=games.find(x=>x.id===p.game_id)||{};return '<tr data-package-row="'+p.id+'"><td>'+escapeHTML(g.name_en||g.name_ar||"—")+'</td><td><strong>'+escapeHTML(p.package_name)+'</strong><small class="cell-sub">'+escapeHTML(p.amount_label)+'</small></td><td><input class="package-field sku-field" aria-label="SKU المورد" value="'+escapeHTML(p.supplier_sku||"")+'" placeholder="Supplier SKU"></td><td><input class="package-field cost-field" aria-label="تكلفة المورد" type="number" min="0" step=".01" value="'+(p.supplier_cost??"")+'" placeholder="0.00"></td><td><input class="package-field price-field" aria-label="سعر البيع" type="number" min="0" step=".01" value="'+(p.selling_price??"")+'" placeholder="0.00"></td><td><select class="row-action-select package-active"><option value="false" '+(!p.is_active?"selected":"")+' >غير مفعّلة</option><option value="true" '+(p.is_active?"selected":"")+' >مفعّلة</option></select></td><td><button class="mini-button save-package" data-id="'+p.id+'">حفظ</button></td></tr>';}).join(""):'<tr><td colspan="7">لا توجد باقات مطابقة.</td></tr>';
}

async function loadCustomers(){
 const {data,error}=await supabase.from("customer_profiles").select("*").order("created_at",{ascending:false});
 if(error)throw error;customers=data||[];renderCustomers();
}
function renderCustomers(){
 const q=($("customerSearch").value||"").trim().toLowerCase(),st=$("customerStatusFilter").value;
 const rows=customers.filter(c=>(!st||c.status===st)&&[c.zaro_id,c.full_name,c.email].some(v=>String(v||"").toLowerCase().includes(q)));
 $("customersResultCount").textContent=rows.length+" عميل";
 $("customersTable").innerHTML=rows.length?rows.map(c=>'<tr><td><strong>'+escapeHTML(c.zaro_id||"—")+'</strong></td><td>'+escapeHTML(c.full_name||"—")+'</td><td>'+escapeHTML(c.email||"—")+'</td><td>'+date(c.created_at)+'</td><td><span class="order-status '+statusClass(c.status)+'">'+statusText(c.status)+'</span></td><td><select class="row-action-select customer-state-select" data-id="'+escapeHTML(c.user_id)+'"><option value="pending" '+(c.status==="pending"?"selected":"")+'>معلق</option><option value="active" '+(c.status==="active"?"selected":"")+'>نشط</option><option value="rejected" '+(c.status==="rejected"?"selected":"")+'>مرفوض</option><option value="suspended" '+(c.status==="suspended"?"selected":"")+'>موقوف</option></select></td></tr>').join(""):'<tr><td colspan="6">لا توجد بيانات عملاء مطابقة.</td></tr>';
}

async function loadAppUsers(){
 const {data,error}=await supabase.from("app_profiles")
  .select("user_id,zaro_id,display_name,points,lifetime_spend,rank_code,is_suspended,created_at")
  .order("created_at",{ascending:false});
 if(error)throw error;
 appUsers=data||[];
 $("appUsersCount").textContent=appUsers.length+" حساب";
 renderAppUsers();
}
function renderAppUsers(){
 $("appUsersTable").innerHTML=appUsers.length?appUsers.map(u=>'<tr data-user-id="'+escapeHTML(u.user_id)+'"><td><strong>'+escapeHTML(u.zaro_id||"—")+'</strong></td><td>'+escapeHTML(u.display_name||"ZARO Player")+'</td><td><span class="order-status completed">'+escapeHTML((u.rank_code||"rookie").toUpperCase())+'</span></td><td>'+Number(u.points||0).toLocaleString("en-US")+'</td><td><input class="package-field app-points-delta" type="number" step="1" min="-100000" max="100000" placeholder="+50 أو -20"></td><td><input class="package-field app-points-reason" type="text" maxlength="200" placeholder="سبب التعديل"></td><td><button class="mini-button save-app-points" data-id="'+escapeHTML(u.user_id)+'">حفظ</button></td></tr>').join(""):'<tr><td colspan="7">لا توجد حسابات تطبيق حتى الآن.</td></tr>';
}

async function loadTickets(){
 const {data,error}=await supabase.from("support_tickets").select("*").order("created_at",{ascending:false});
 if(error)throw error;tickets=data||[];$("ticketsCount").textContent=tickets.filter(t=>t.status==="open").length;$("openTicketsCount").textContent=tickets.filter(t=>t.status==="open").length;renderTickets();
}
function renderTickets(){
 $("ticketsList").innerHTML=tickets.length?tickets.map(t=>'<button class="ticket-item '+(selectedTicket===t.id?"selected":"")+'" data-ticket-id="'+t.id+'"><strong>'+escapeHTML(t.subject)+'</strong><span>'+escapeHTML(t.customer_name)+' · '+date(t.created_at)+'</span><em class="order-status '+statusClass(t.status)+'">'+statusText(t.status)+'</em></button>').join(""):'<p class="empty-message">لا توجد تذاكر دعم.</p>';
}
async function openTicket(id){
 selectedTicket=id;renderTickets();const t=tickets.find(x=>x.id===id);if(!t)return;
 $("ticketTitle").textContent=t.subject;$("ticketMeta").textContent=(t.customer_name||"")+(t.customer_email?" · "+t.customer_email:"");
 $("ticketStatus").disabled=false;$("ticketStatus").value=t.status;$("replyBody").disabled=false;$("sendReplyButton").disabled=false;
 $("messagesList").innerHTML='<p class="empty-message">جاري تحميل المحادثة...</p>';
 const {data,error}=await supabase.from("support_messages").select("*").eq("ticket_id",id).order("created_at",{ascending:true});
 if(error){$("messagesList").innerHTML='<p class="empty-message">تعذر تحميل الرسائل: '+escapeHTML(error.message)+'</p>';return;}
 $("messagesList").innerHTML=(data||[]).length?data.map(m=>'<div class="message-bubble '+(m.sender_role==="admin"?"admin-message":"customer-message")+'"><small>'+(m.sender_role==="admin"?"الإدارة":"العميل")+' · '+date(m.created_at)+'</small><p>'+escapeHTML(m.body)+'</p></div>').join(""):'<p class="empty-message">لا توجد رسائل.</p>';
 $("messagesList").scrollTop=$("messagesList").scrollHeight;
}


async function loadPlatformControl(){
 const [versions, promotions, flags, settings, wallets, devices, audits, profiles] = await Promise.all([
  supabase.from("app_versions").select("*").eq("platform","android").order("build_number",{ascending:false}).limit(8),
  supabase.from("app_promotions").select("*").order("created_at",{ascending:false}).limit(8),
  supabase.from("app_feature_flags").select("*").order("flag_key"),
  supabase.from("app_settings").select("*").order("setting_key"),
  supabase.from("app_wallets").select("*").order("updated_at",{ascending:false}).limit(100),
  supabase.from("app_devices").select("platform,device_label,app_build,last_seen_at").order("last_seen_at",{ascending:false}).limit(30),
  supabase.from("app_audit_logs").select("*").order("created_at",{ascending:false}).limit(30),
  supabase.from("app_profiles").select("user_id,zaro_id,display_name").order("created_at",{ascending:false}).limit(500)
 ]);
 for(const [name,res] of [["الإصدارات",versions],["العروض",promotions],["المميزات",flags],["الإعدادات",settings],["المحافظ",wallets],["الأجهزة",devices],["السجل",audits],["الحسابات",profiles]]) if(res.error) throw new Error(name+": "+res.error.message);
 const profileMap=new Map((profiles.data||[]).map(p=>[p.user_id,p]));
 $("versionsList").innerHTML=(versions.data||[]).map(v=>'<p>'+escapeHTML(v.version_name)+' · build '+v.build_number+(v.is_mandatory?' · إجباري':'')+' · '+(v.is_active?'نشط':'متوقف')+'</p>').join("")||"لا توجد إصدارات مسجلة.";
 $("promotionsList").innerHTML=(promotions.data||[]).map(p=>'<div class="promotion-admin-row" style="display:flex;justify-content:space-between;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid #ffffff18"><span>'+escapeHTML(p.title)+' · '+escapeHTML(p.code||"بدون كود")+' · '+(p.is_active?'نشط':'متوقف')+'</span><button class="mini-button promotion-toggle" data-id="'+p.id+'" data-active="'+p.is_active+'">'+(p.is_active?'إيقاف':'تفعيل')+'</button></div>').join("")||"لا توجد عروض.";
 $("featureFlagsList").innerHTML=(flags.data||[]).map(f=>'<label style="display:flex;gap:8px;align-items:center;margin:8px 0"><input type="checkbox" class="feature-flag-toggle" data-key="'+escapeHTML(f.flag_key)+'" '+(f.enabled?'checked':'')+'> '+escapeHTML(f.flag_key)+'</label>').join("")||"لا توجد مفاتيح مميزات.";
 $("appSettingsList").innerHTML=(settings.data||[]).map(s=>{
  if(s.setting_key==="maintenance_mode") return '<label style="display:flex;gap:8px;align-items:center"><input type="checkbox" class="app-setting-toggle" data-key="maintenance_mode" '+(s.setting_value===true?'checked':'')+'> وضع الصيانة</label>';
  return '<p>'+escapeHTML(s.setting_key)+': '+escapeHTML(JSON.stringify(s.setting_value))+'</p>';
 }).join("")||"لا توجد إعدادات.";

 $("walletsTable").innerHTML=(wallets.data||[]).map(w=>{const p=profileMap.get(w.user_id)||{};return '<tr><td>'+escapeHTML(p.zaro_id||"—")+'</td><td>'+escapeHTML(p.display_name||"عميل")+'</td><td>'+money(w.balance)+'</td><td><input class="wallet-delta" type="number" step="0.01" placeholder="+/-"></td><td><input class="wallet-reason" placeholder="سبب التعديل"></td><td><button class="mini-button save-wallet" data-id="'+w.user_id+'">حفظ</button></td></tr>'}).join("")||'<tr><td colspan="6">لا توجد محافظ مسجلة.</td></tr>';
 $("devicesTable").innerHTML=(devices.data||[]).map(d=>'<tr><td>'+escapeHTML(d.platform)+'</td><td>'+escapeHTML(d.device_label||"غير محدد")+'</td><td>'+escapeHTML(d.app_build??"—")+'</td><td>'+date(d.last_seen_at)+'</td></tr>').join("")||'<tr><td colspan="4">لا توجد أجهزة مسجلة.</td></tr>';
 $("auditTable").innerHTML=(audits.data||[]).map(a=>'<tr><td>'+escapeHTML(a.action)+'</td><td>'+escapeHTML(a.entity_type)+'</td><td>'+escapeHTML(a.entity_id||"—")+'</td><td>'+escapeHTML(JSON.stringify(a.details))+'</td><td>'+date(a.created_at)+'</td></tr>').join("")||'<tr><td colspan="5">لا توجد عمليات مسجلة.</td></tr>';
}
async function loadAll(){
 $("refreshButton").classList.add("is-loading");
 const jobs=[["الطلبات",loadOrders],["الكتالوج",loadCatalog],["العملاء",loadCustomers],["حسابات التطبيق",loadAppUsers],["الدعم",loadTickets],["مركز التحكم",loadPlatformControl]];
 const errors=[];
 for(const [name,fn] of jobs){try{await fn();}catch(e){console.error(name,e);errors.push(name+": "+e.message);}}
 $("refreshButton").classList.remove("is-loading");
 if(errors.length)notify("تعذر تحميل: "+errors.join(" | "));
}

loginForm.addEventListener("submit",async e=>{
 e.preventDefault();loginButton.disabled=true;loginButton.textContent="جاري التحقق...";loginMessage.textContent="";
 try{
  const {data,error}=await supabase.auth.signInWithPassword({email:$("email").value.trim(),password:$("password").value});
  if(error)throw error;if(data.user.id!==ADMIN_UID){await supabase.auth.signOut();throw new Error("هذا الحساب غير مصرح له بالدخول.");}
  currentUser=data.user;loginMessage.style.color="#39d98a";loginMessage.textContent="تم تسجيل الدخول بنجاح.";showDashboard();$("adminEmail").textContent=data.user.email||"مدير المتجر";$("sessionEmail").textContent=data.user.email||"—";await loadAll();
 }catch(err){loginMessage.style.color="#ff6262";loginMessage.textContent=err.message;}finally{loginButton.disabled=false;loginButton.textContent="تسجيل الدخول";}
});

document.addEventListener("click",e=>{
 const button=e.target.closest("[data-page]");
 if(!button)return;
 const page=button.dataset.page;
 if(!page||!$("page-"+page))return;
 e.preventDefault();e.stopPropagation();showPage(page);
});
$("mobileMenuButton").addEventListener("click",()=>{
 const open=$("sidebar").classList.toggle("mobile-open");
 document.body.classList.toggle("admin-menu-open",open);
});
document.addEventListener("click",e=>{
 if(window.matchMedia("(max-width: 760px)").matches && $("sidebar").classList.contains("mobile-open") && !e.target.closest("#sidebar") && !e.target.closest("#mobileMenuButton")){
  $("sidebar").classList.remove("mobile-open");document.body.classList.remove("admin-menu-open");
 }
});
$("refreshButton").addEventListener("click",loadAll);
$("orderSearch").addEventListener("input",renderOrders);$("orderStatusFilter").addEventListener("change",renderOrders);
$("packageSearch").addEventListener("input",renderPackages);$("packageGameFilter").addEventListener("change",renderPackages);
$("customerSearch").addEventListener("input",renderCustomers);$("customerStatusFilter").addEventListener("change",renderCustomers);

$("allOrders").addEventListener("change",async e=>{
 const s=e.target.closest(".order-state-select");if(!s)return;const id=s.dataset.id,newStatus=s.value;
 const order=orders.find(o=>String(o.id)===String(id));
 if(newStatus==="completed"&&(!order||order.payment_status!=="paid"||order.fulfillment_status!=="fulfilled")){notify("لا يمكن إغلاق الطلب كمكتمل قبل تأكيد الدفع من بوابة الدفع ونجاح الشحن من المورد.");await loadOrders();return;}
 if(newStatus==="completed"&&!confirm("تأكيد اكتمال الدفع والشحن لهذا الطلب؟")){await loadOrders();return;}
 s.disabled=true;const {error}=await supabase.from("orders").update({status:newStatus}).eq("id",id);if(error){notify("فشل تحديث الطلب: "+error.message);}else notify("تم تحديث حالة الطلب.");await loadOrders();
});
$("gamesGrid").addEventListener("click",async e=>{
 const b=e.target.closest(".game-toggle");if(!b)return;const g=games.find(x=>x.id===b.dataset.id);if(!g)return;const active=b.dataset.active!=="true";
 if(active&&!packages.some(p=>p.game_id===g.id&&p.is_active)){notify("فعّل باقة واحدة على الأقل بعد تأكيد بيانات المورد أولًا.");return;}
 if(!confirm(active?"تفعيل ظهور اللعبة في الكتالوج؟ تأكد من جاهزية الباقات والمورد.":"إيقاف اللعبة من الكتالوج؟"))return;
 b.disabled=true;const {error}=await supabase.from("catalog_games").update({is_active:active,updated_at:new Date().toISOString()}).eq("id",g.id);if(error)notify("تعذر تحديث اللعبة: "+error.message);else notify("تم تحديث اللعبة.");await loadCatalog();
});
$("packagesTable").addEventListener("click",async e=>{
 const b=e.target.closest(".save-package");if(!b)return;const row=b.closest("tr"),id=b.dataset.id,p=packages.find(x=>x.id===id);if(!p)return;
 const sku=row.querySelector(".sku-field").value.trim(),cost=row.querySelector(".cost-field").value,price=row.querySelector(".price-field").value;
 const supplierCost=cost===""?null:Number(cost),sellingPrice=price===""?null:Number(price),isActive=row.querySelector(".package-active").value==="true";
 if((supplierCost!==null&&(!Number.isFinite(supplierCost)||supplierCost<0))||(sellingPrice!==null&&(!Number.isFinite(sellingPrice)||sellingPrice<0))){notify("راجع الأرقام المدخلة.");return;}
 if(isActive&&(!sku||supplierCost===null||sellingPrice===null||sellingPrice<=0)){notify("لا يمكن تفعيل باقة بدون SKU وتكلفة وسعر بيع صحيحين من المورد.");return;}
 if(isActive&&!p.is_active&&!confirm("تفعيل هذه الباقة في الكتالوج العام؟ تأكد أن المورد أكد السعر وSKU وأن الشحن جاهز.")){return;}
 b.disabled=true;const {error}=await supabase.from("catalog_packages").update({supplier_sku:sku||null,supplier_cost:supplierCost,selling_price:sellingPrice,is_active:isActive,updated_at:new Date().toISOString()}).eq("id",id);b.disabled=false;
 if(error)notify("فشل حفظ الباقة: "+error.message);else notify("تم حفظ بيانات الباقة، ولم يتم تفعيلها.");await loadCatalog();
});
$("appUsersTable").addEventListener("click",async e=>{
 const b=e.target.closest(".save-app-points");if(!b)return;
 const row=b.closest("tr"),userId=b.dataset.id;
 const delta=Number(row.querySelector(".app-points-delta").value);
 const reason=row.querySelector(".app-points-reason").value.trim();
 if(!Number.isInteger(delta)||delta===0){notify("اكتب عدد نقاط صحيح غير صفر.");return;}
 if(reason.length<2){notify("اكتب سبب تعديل النقاط.");return;}
 b.disabled=true;
 const {data,error}=await supabase.rpc("zaro_admin_adjust_app_points",{p_user_id:userId,p_delta:delta,p_reason:reason});
 b.disabled=false;
 if(error){notify("تعذر تعديل النقاط: "+error.message);return;}
 notify("تم تحديث النقاط إلى "+data+" وإعادة حساب الرتبة.");
 await loadAppUsers();
});
$("customersTable").addEventListener("change",async e=>{
 const s=e.target.closest(".customer-state-select");if(!s)return;const id=s.dataset.id,status=s.value;s.disabled=true;
 let error=null;
 if(status==="pending"){
  const result=await supabase.from("customer_profiles").update({status,reviewed_at:new Date().toISOString(),reviewed_by:ADMIN_UID}).eq("user_id",id);
  error=result.error;
 }else{
  const result=await supabase.rpc("zaro_review_customer",{p_user_id:id,p_decision:status});
  error=result.error;
 }
 if(error)notify("تعذر تحديث العميل: "+error.message);
 else notify(status==="active"?"تم تفعيل الحساب وتخصيص ZARO ID وربط ملف التطبيق.":"تم تحديث حالة العميل.");
 await loadCustomers();await loadAppUsers();
});
$("ticketsList").addEventListener("click",e=>{const b=e.target.closest("[data-ticket-id]");if(b)openTicket(b.dataset.ticketId);});
$("ticketStatus").addEventListener("change",async e=>{
 if(!selectedTicket)return;const status=e.target.value;const {error}=await supabase.from("support_tickets").update({status,updated_at:new Date().toISOString()}).eq("id",selectedTicket);
 if(error)notify("تعذر تحديث التذكرة: "+error.message);else{notify("تم تحديث حالة التذكرة.");await loadTickets();}
});
$("replyForm").addEventListener("submit",async e=>{
 e.preventDefault();if(!selectedTicket)return;const body=$("replyBody").value.trim();if(!body)return;
 $("sendReplyButton").disabled=true;
 const {error}=await supabase.from("support_messages").insert({ticket_id:selectedTicket,sender_role:"admin",body});
 if(error){notify("تعذر إرسال الرد: "+error.message);$("sendReplyButton").disabled=false;return;}
 await supabase.from("support_tickets").update({status:"answered",updated_at:new Date().toISOString()}).eq("id",selectedTicket);
 $("replyBody").value="";$("sendReplyButton").disabled=false;notify("تم إرسال الرد.");await loadTickets();await openTicket(selectedTicket);
});
$("logoutButton").addEventListener("click",async()=>{const {error}=await supabase.auth.signOut();if(error){notify("تعذر تسجيل الخروج: "+error.message);return;}orders=[];games=[];packages=[];customers=[];tickets=[];selectedTicket=null;loginForm.reset();loginMessage.textContent="";showLogin();});
supabase.auth.onAuthStateChange((event,session)=>{if(event==="SIGNED_OUT"||!session){currentUser=null;showLogin();}});
async function checkSession(){const {data,error}=await supabase.auth.getSession();if(error||!data.session){showLogin();return;}if(data.session.user.id!==ADMIN_UID){await supabase.auth.signOut();showLogin();return;}currentUser=data.session.user;showDashboard();$("adminEmail").textContent=currentUser.email||"مدير المتجر";$("sessionEmail").textContent=currentUser.email||"—";await loadAll();}

$("refreshPlatformData")?.addEventListener("click",()=>loadPlatformControl().catch(e=>notify(e.message)));
$("versionForm")?.addEventListener("submit",async e=>{
 e.preventDefault();
 const build=Number($("versionBuild").value),minBuild=Number($("versionMinBuild").value);
 if(!Number.isInteger(build)||build<1||!Number.isInteger(minBuild)||minBuild<1||minBuild>build){notify("راجع أرقام الإصدارات.");return;}
 const {error}=await supabase.from("app_versions").insert({platform:"android",version_name:$("versionName").value.trim(),build_number:build,min_supported_build:minBuild,download_url:$("versionUrl").value.trim()||null,release_notes:{ar:$("versionNotes").value.trim()},is_latest:true,is_mandatory:$("versionMandatory").checked,is_active:true,published_at:new Date().toISOString()});
 if(error){notify("تعذر نشر الإصدار: "+error.message);return;}
 await supabase.from("app_versions").update({is_latest:false}).eq("platform","android").lt("build_number",build);
 await supabase.from("app_audit_logs").insert({actor_user_id:currentUser.id,action:"publish_app_version",entity_type:"app_version",entity_id:String(build),details:{version:$("versionName").value.trim(),mandatory:$("versionMandatory").checked}});
 e.target.reset();notify("تم تسجيل الإصدار في نظام التحديثات. يلزم التأكد من نشر ملف APK على رابط صالح.");await loadPlatformControl();
});
$("notificationForm")?.addEventListener("submit",async e=>{
 e.preventDefault();const zaroId=$("notificationZaroId").value.trim();let userId=null;
 if(zaroId){const {data,error}=await supabase.from("app_profiles").select("user_id").eq("zaro_id",zaroId).maybeSingle();if(error||!data){notify("لم يتم العثور على ZARO ID.");return;}userId=data.user_id;}
 const {error}=await supabase.from("app_notifications").insert({user_id:userId,title:$("notificationTitle").value.trim(),body:$("notificationBody").value.trim(),notification_type:"admin"});
 if(error){notify("تعذر إرسال الإشعار: "+error.message);return;}
 await supabase.from("app_audit_logs").insert({actor_user_id:currentUser.id,action:"send_notification",entity_type:"notification",details:{target:zaroId||"all"}});
 e.target.reset();notify("تم حفظ الإشعار داخل مركز إشعارات التطبيق.");await loadPlatformControl();
});
$("promotionsList")?.addEventListener("click",async e=>{
 const b=e.target.closest(".promotion-toggle");if(!b)return;
 const next=b.dataset.active!=="true";b.disabled=true;
 const {error}=await supabase.from("app_promotions").update({is_active:next,updated_at:new Date().toISOString()}).eq("id",b.dataset.id);
 if(error){notify("تعذر تحديث العرض: "+error.message);b.disabled=false;return;}
 notify(next?"تم تفعيل العرض.":"تم إيقاف العرض.");await loadPlatformControl();
});
$("promotionForm")?.addEventListener("submit",async e=>{
 e.preventDefault();const startsText=$("promotionStartsAt").value,endsText=$("promotionEndsAt").value,maxText=$("promotionMaxUses").value.trim();const startsAt=startsText?new Date(startsText).toISOString():null,endsAt=endsText?new Date(endsText).toISOString():null,maxUses=maxText?Number(maxText):null;if((maxUses!==null&&(!Number.isInteger(maxUses)||maxUses<1))||(startsAt&&endsAt&&new Date(endsAt)<=new Date(startsAt))){notify("راجع حد الاستخدام وتواريخ العرض.");return;}const {error}=await supabase.from("app_promotions").insert({code:$("promotionCode").value.trim().toUpperCase()||null,title:$("promotionTitle").value.trim(),discount_type:$("promotionType").value,discount_value:Number($("promotionValue").value),max_uses:maxUses,starts_at:startsAt,ends_at:endsAt,is_active:true});
 if(error){notify("تعذر إنشاء العرض: "+error.message);return;}e.target.reset();notify("تم إنشاء العرض. تطبيق الخصم على الطلبات يحتاج ربطًا بمسار الدفع.");await loadPlatformControl();
});
$("appSettingsList")?.addEventListener("change",async e=>{
 const box=e.target.closest(".app-setting-toggle");if(!box)return;
 const {error}=await supabase.from("app_settings").update({setting_value:box.checked,updated_at:new Date().toISOString(),updated_by:currentUser.id}).eq("setting_key",box.dataset.key);
 if(error){notify("تعذر تحديث الإعداد: "+error.message);box.checked=!box.checked;}else notify("تم تحديث إعداد المنصة.");
});
$("featureFlagsList")?.addEventListener("change",async e=>{
 const box=e.target.closest(".feature-flag-toggle");if(!box)return;
 const {error}=await supabase.from("app_feature_flags").update({enabled:box.checked,updated_at:new Date().toISOString(),updated_by:currentUser.id}).eq("flag_key",box.dataset.key);
 if(error){notify("تعذر تغيير الميزة: "+error.message);box.checked=!box.checked;}else notify("تم تحديث إعداد الميزة.");
});
$("walletsTable")?.addEventListener("click",async e=>{
 const b=e.target.closest(".save-wallet");if(!b)return;const row=b.closest("tr"),delta=Number(row.querySelector(".wallet-delta").value),reason=row.querySelector(".wallet-reason").value.trim();
 if(!Number.isFinite(delta)||delta===0||reason.length<3){notify("أدخل مبلغًا صحيحًا وسببًا واضحًا.");return;}
 b.disabled=true;const {data,error}=await supabase.rpc("zaro_admin_adjust_wallet",{p_user_id:b.dataset.id,p_amount_delta:delta,p_description:reason});b.disabled=false;
 if(error){notify("تعذر تعديل المحفظة: "+error.message);return;}notify("تم تحديث الرصيد إلى "+money(data));await loadPlatformControl();
});

checkSession();

const opsCost=$("opsCost"),opsMargin=$("opsMargin");
function calculateOpsPrice(){
 if(!opsCost||!opsMargin)return;
 const c=Number(opsCost.value),m=Number(opsMargin.value);
 if(!opsCost.value||c<=0||!Number.isFinite(m)||m<0){$("opsPrice").textContent="—";$("opsProfit").textContent="أدخل تكلفة صحيحة";return;}
 const selling=c*(1+m/100);
 $("opsPrice").textContent=selling.toLocaleString("ar-EG",{maximumFractionDigits:2})+" ج.م";
 $("opsProfit").textContent="ربح تقديري: "+(selling-c).toLocaleString("ar-EG",{maximumFractionDigits:2})+" ج.م";
}
opsCost?.addEventListener("input",calculateOpsPrice);
opsMargin?.addEventListener("input",calculateOpsPrice);
