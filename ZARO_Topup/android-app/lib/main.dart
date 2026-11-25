import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bg = Color(0xFF070707);
const panel = Color(0xFF151515);
const orange = Color(0xFFFF7900);
const yellow = Color(0xFFFFC400);
const white = Color(0xFFF7F7F7);
const muted = Color(0xFFB9B9B9);
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rtqdcbkttrxbmglzllmv.supabase.co',
    publishableKey: 'sb_publishable_iqwtKiJMmx9QEO4l1Zo7iQ_kHvZZH0c',
  );
  runApp(const ZaroApp());
}

class ZaroApp extends StatelessWidget {
  const ZaroApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ZARO',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: orange, secondary: yellow),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: white),
    ),
    home: const ZaroShell(),
  );
}

class Game {
  final String name;
  final String slug;
  final String image;
  final String description;
  const Game(this.name, this.slug, this.image, this.description);
}

const games = <Game>[
  Game('FREE FIRE', 'free-fire', 'assets/images/freefire.jpg', 'اشحن جواهر فري فاير'),
  Game('PUBG MOBILE', 'pubg-mobile', 'assets/images/pubg.jpg', 'اشحن شدات ببجي'),
  Game('CALL OF DUTY', 'call-of-duty', 'assets/images/cod.jpg', 'اشحن CP كول أوف ديوتي'),
  Game('EA SPORTS FC', 'fc-mobile', 'assets/images/fc.jpg', 'اشحن نقاط FC'),
  Game('MOBILE LEGENDS', 'mobile-legends', 'assets/images/ml.jpg', 'اشحن ألماس موبايل ليجندز'),
  Game('ROBLOX', 'roblox', 'assets/images/roblox.jpg', 'اشحن Robux'),
];

class ZaroShell extends StatefulWidget {
  const ZaroShell({super.key});
  @override
  State<ZaroShell> createState() => _ZaroShellState();
}

class _ZaroShellState extends State<ZaroShell> {
  int tab = 0;
  bool arabic = true;
  User? user;
  late final authSub = supabase.auth.onAuthStateChange.listen((state) {
    if (mounted) setState(() => user = state.session?.user);
  });

  @override
  void initState() {
    super.initState();
    user = supabase.auth.currentUser;
  }

  @override
  void dispose() {
    authSub.cancel();
    super.dispose();
  }

  String t(String ar, String en) => arabic ? ar : en;

  void openGame(Game game) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameDetailPage(game: game, arabic: arabic, user: user),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(arabic: arabic, onGameTap: openGame, onSeeAll: () => setState(() => tab = 1), onAccount: () => setState(() => tab = 4)),
      GamesPage(arabic: arabic, onGameTap: openGame),
      OrdersPage(arabic: arabic, user: user),
      SupportPage(arabic: arabic, user: user),
      AccountPage(arabic: arabic, user: user),
    ];
    return Directionality(
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(bottom: false, child: IndexedStack(index: tab, children: pages)),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            border: Border(top: BorderSide(color: orange.withOpacity(.85), width: 1.2)),
            boxShadow: [BoxShadow(color: orange.withOpacity(.16), blurRadius: 18, offset: const Offset(0, -5))],
          ),
          child: SafeArea(top: false, child: SizedBox(
            height: 70,
            child: Row(children: [
              _navItem(0, Icons.home_rounded, t('الرئيسية', 'Home')),
              _navItem(1, Icons.sports_esports_rounded, t('الألعاب', 'Games')),
              _navItem(2, Icons.shopping_bag_rounded, t('طلباتي', 'Orders')),
              _navItem(3, Icons.headset_mic_rounded, t('الدعم', 'Support')),
              _navItem(4, Icons.person_rounded, t('حسابي', 'Account')),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) => Expanded(
    child: InkWell(
      onTap: () => setState(() => tab = index),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 24, color: tab == index ? yellow : muted),
        const SizedBox(height: 4),
        Text(label, maxLines: 1, style: TextStyle(
          color: tab == index ? yellow : white,
          fontSize: 10.5,
          fontWeight: tab == index ? FontWeight.w900 : FontWeight.w600,
        )),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 3, width: tab == index ? 27 : 0,
          decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(4)),
        ),
      ]),
    ),
  );
}

class HomePage extends StatelessWidget {
  final bool arabic;
  final ValueChanged<Game> onGameTap;
  final VoidCallback onSeeAll;
  final VoidCallback onAccount;
  const HomePage({super.key, required this.arabic, required this.onGameTap, required this.onSeeAll, required this.onAccount});
  String t(String ar, String en) => arabic ? ar : en;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 14),
        child: Row(children: [
          SizedBox(width: 145, height: 65, child: Image.asset('assets/zaro-logo.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('ZARO', style: TextStyle(fontSize: 32, color: orange, fontWeight: FontWeight.w900)))),
          const Spacer(),
          _roundButton(context, Icons.notifications_none_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage(arabic: arabic)))),
          const SizedBox(width: 9),
          _roundButton(context, Icons.person_outline_rounded, onAccount),
          const SizedBox(width: 9),
          InkWell(
            onTap: () => (context.findAncestorStateOfType<_ZaroShellState>()!).setState(() => (context.findAncestorStateOfType<_ZaroShellState>()!).arabic = !arabic),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(border: Border.all(color: orange), borderRadius: BorderRadius.circular(24), color: panel),
              child: Text(arabic ? 'EN' : 'عربي', style: const TextStyle(color: yellow, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      )),
      SliverToBoxAdapter(child: Container(
        height: 220, margin: const EdgeInsets.symmetric(horizontal: 14), clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25), border: Border.all(color: orange, width: 1.4),
          gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF321300), Color(0xFF080808), Color(0xFF1C0900)]),
          boxShadow: [BoxShadow(color: orange.withOpacity(.2), blurRadius: 20)],
        ),
        child: Stack(children: [
          Positioned(right: -10, top: -6, bottom: -6, width: 205, child: Opacity(opacity: .30, child: Image.asset('assets/zaro-logo.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(t('اشحن الآن', 'TOP UP NOW'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: white)),
              const SizedBox(height: 7),
              Text(t('بأمان وسرعة على ZARO', 'Fast and secure with ZARO'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: white)),
              const SizedBox(height: 17),
              InkWell(onTap: onSeeAll, borderRadius: BorderRadius.circular(30), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF241000), borderRadius: BorderRadius.circular(30), border: Border.all(color: yellow, width: 1.6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t('تصفح الألعاب', 'BROWSE GAMES'), style: const TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8), const Icon(Icons.chevron_left, color: yellow),
                ]),
              )),
            ]),
          ),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
        child: Row(children: [
          const Icon(Icons.sports_esports_rounded, color: yellow, size: 24), const SizedBox(width: 8),
          Text(t('الألعاب المتاحة', 'AVAILABLE GAMES'), style: const TextStyle(color: white, fontSize: 19, fontWeight: FontWeight.w900)),
          const Spacer(),
          TextButton(onPressed: onSeeAll, child: Text(t('عرض الكل', 'VIEW ALL'), style: const TextStyle(color: yellow, fontWeight: FontWeight.bold))),
        ]),
      )),
      SliverToBoxAdapter(child: SizedBox(
        height: 178,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14), scrollDirection: Axis.horizontal,
          itemCount: games.length, separatorBuilder: (_, __) => const SizedBox(width: 11),
          itemBuilder: (_, i) => InkWell(
            onTap: () => onGameTap(games[i]), borderRadius: BorderRadius.circular(18),
            child: Container(width: 132, clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: orange, width: 1.1)),
              child: Image.asset(games[i].image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: panel, alignment: Alignment.center, child: Text(games[i].name, textAlign: TextAlign.center, style: const TextStyle(color: white, fontWeight: FontWeight.bold)))),
            ),
          ),
        ),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.only(top: 27, bottom: 25),
        child: Column(children: const [
          Text('ZARO.', style: TextStyle(color: orange, fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2)),
          SizedBox(height: 4),
          Text('YOUR GAME. YOUR WORLD.', style: TextStyle(color: white, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w600)),
        ]),
      )),
    ],
  );

  Widget _roundButton(BuildContext context, IconData icon, VoidCallback action) => InkWell(
    onTap: action, borderRadius: BorderRadius.circular(30),
    child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: panel, border: Border.all(color: orange)), child: Icon(icon, color: white, size: 24)),
  );
}

class GamesPage extends StatelessWidget {
  final bool arabic;
  final ValueChanged<Game> onGameTap;
  const GamesPage({super.key, required this.arabic, required this.onGameTap});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverToBoxAdapter(child: _pageHeader(arabic ? 'كل الألعاب' : 'All Games')),
    SliverPadding(
      padding: const EdgeInsets.all(14),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, i) => InkWell(
          onTap: () => onGameTap(games[i]), borderRadius: BorderRadius.circular(18),
          child: Container(clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: orange)),
            child: Column(children: [
              Expanded(child: Image.asset(games[i].image, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.videogame_asset, color: yellow, size: 50))),
              Padding(padding: const EdgeInsets.all(9), child: Text(games[i].name, textAlign: TextAlign.center, style: const TextStyle(color: white, fontWeight: FontWeight.w800, fontSize: 12))),
            ]),
          ),
        ), childCount: games.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 13, crossAxisSpacing: 13, childAspectRatio: .88),
      ),
    ),
  ]);
}

class GameDetailPage extends StatefulWidget {
  final Game game;
  final bool arabic;
  final User? user;
  const GameDetailPage({super.key, required this.game, required this.arabic, required this.user});
  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final player = TextEditingController();
  final zone = TextEditingController();
  List<Map<String, dynamic>> packages = [];
  String? selectedPackage;
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  @override
  void dispose() {
    player.dispose();
    zone.dispose();
    super.dispose();
  }

  Future<void> loadPackages() async {
    try {
      final gameRow = await supabase.from('catalog_games').select('id').eq('slug', widget.game.slug).eq('is_active', true).maybeSingle();
      if (gameRow != null) {
        final rows = await supabase.from('catalog_packages').select('package_name,amount_label,selling_price').eq('game_id', gameRow['id']).eq('is_active', true).order('sort_order');
        packages = List<Map<String, dynamic>>.from(rows);
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> submitOrder() async {
    if (widget.user == null) {
      _message('سجّل دخولك الأول من صفحة حسابي.');
      return;
    }
    if (selectedPackage == null || player.text.trim().length < 3) {
      _message('اكتب Player ID واختار باقة متاحة.');
      return;
    }
    if (widget.game.slug == 'mobile-legends' && zone.text.trim().isEmpty) {
      _message('اكتب Zone ID الخاص بحسابك.');
      return;
    }
    setState(() => sending = true);
    try {
      final result = await supabase.functions.invoke('create-order', body: {
        'playerId': player.text.trim(),
        'zoneId': zone.text.trim().isEmpty ? null : zone.text.trim(),
        'game': widget.game.name == 'MOBILE LEGENDS' ? 'Mobile Legends' : widget.game.name,
        'package': selectedPackage,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      if (result.status >= 400 || data['success'] != true) {
        throw Exception(data['error'] ?? 'تعذر تسجيل الطلب');
      }
      if (mounted) {
        _message('تم تسجيل الطلب التجريبي رقم ' + data['orderId'].toString());
        Navigator.pop(context);
      }
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), backgroundColor: panel));
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: widget.arabic ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.game.name)),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(widget.game.image, height: 210, fit: BoxFit.cover)),
        const SizedBox(height: 18),
        Text(widget.game.name, style: const TextStyle(color: yellow, fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        Text(widget.game.description, style: const TextStyle(color: white, fontSize: 16)),
        const SizedBox(height: 20),
        _field(player, 'PLAYER ID'),
        if (widget.game.slug == 'mobile-legends') ...[
          const SizedBox(height: 12), _field(zone, 'ZONE ID'),
        ],
        const SizedBox(height: 20),
        const Text('الباقات المتاحة من لوحة الإدارة', style: TextStyle(color: white, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        if (loading) const Center(child: CircularProgressIndicator(color: orange))
        else if (packages.isEmpty) const _InfoPanel(text: 'لا توجد باقات مفعّلة حاليًا. عند تفعيل اللعبة وباقاتها من لوحة الأدمن هتظهر هنا تلقائيًا.')
        else ...packages.map((p) {
          final name = (p['package_name'] ?? '').toString();
          final price = p['selling_price'];
          final active = selectedPackage == name;
          return Card(
            color: active ? const Color(0xFF38200D) : panel,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: active ? yellow : orange.withOpacity(.35))),
            child: ListTile(
              onTap: () => setState(() => selectedPackage = name),
              leading: Icon(active ? Icons.check_circle : Icons.circle_outlined, color: yellow),
              title: Text((p['amount_label'] ?? name).toString(), style: const TextStyle(color: white, fontWeight: FontWeight.bold)),
              trailing: Text(price == null ? 'السعر لاحقًا' : price.toString() + ' ج.م', style: const TextStyle(color: yellow, fontWeight: FontWeight.bold)),
            ),
          );
        }),
        const SizedBox(height: 18),
        SizedBox(height: 52, child: FilledButton(
          onPressed: sending || packages.isEmpty ? null : submitOrder,
          style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.black),
          child: Text(sending ? 'جاري التسجيل...' : 'تسجيل الطلب التجريبي', style: const TextStyle(fontWeight: FontWeight.w900)),
        )),
        const SizedBox(height: 10),
        const Text('لا يوجد دفع أو شحن حقيقي قبل اعتماد المورد وتفعيل الباقات.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 11)),
      ]),
    ),
  );

  Widget _field(TextEditingController c, String label) => TextField(
    controller: c, style: const TextStyle(color: white),
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: yellow), filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
  );
}

class AccountPage extends StatefulWidget {
  final bool arabic;
  final User? user;
  const AccountPage({super.key, required this.arabic, required this.user});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final id = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final newPassword = TextEditingController();
  bool registering = false;
  bool busy = false;
  String feedback = '';

  @override
  void dispose() {
    id.dispose(); password.dispose(); name.dispose(); email.dispose(); newPassword.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> profile() async {
    final uid = widget.user!.id;
    final customer = await supabase.from('customer_profiles').select('zaro_id,full_name,email,status,created_at').eq('user_id', uid).maybeSingle();
    final app = await supabase.from('app_profiles').select('rank_code,points,lifetime_spend').eq('user_id', uid).maybeSingle();
    return {'customer': customer, 'app': app};
  }

  Future<void> login() async {
    if (id.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => feedback = 'اكتب ZARO ID وكلمة المرور.');
      return;
    }
    setState(() { busy = true; feedback = ''; });
    try {
      final response = await supabase.functions.invoke('zaro-id-login', body: {
        'zaroId': id.text.trim().toUpperCase(),
        'password': password.text,
      });
      if (response.status >= 400) {
        final d = response.data is Map ? Map<String, dynamic>.from(response.data) : <String, dynamic>{};
        throw Exception(d['error'] ?? 'بيانات الدخول غير صحيحة.');
      }
      final data = Map<String, dynamic>.from(response.data as Map);
      await supabase.auth.setSession(data['refresh_token'].toString(), accessToken: data['access_token'].toString());
    } catch (e) {
      setState(() => feedback = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> signup() async {
    if (name.text.trim().length < 2 || !email.text.contains('@') || newPassword.text.length < 8) {
      setState(() => feedback = 'راجع الاسم والبريد، وكلمة المرور لازم تكون 8 أحرف على الأقل.');
      return;
    }
    setState(() { busy = true; feedback = ''; });
    try {
      final result = await supabase.auth.signUp(
        email: email.text.trim(),
        password: newPassword.text,
        data: {'full_name': name.text.trim()},
      );
      if (result.session == null) {
        setState(() => feedback = 'تم إنشاء الحساب. افتح بريدك وأكد الحساب، وبعدها استنى موافقة الإدارة وتخصيص ZARO ID.');
      } else {
        setState(() => feedback = 'تم إنشاء الحساب. حسابك قيد المراجعة وسيظهر الـID بعد موافقة الإدارة.');
      }
    } catch (e) {
      setState(() => feedback = 'تعذر إنشاء الحساب: ' + e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return ListView(padding: const EdgeInsets.all(20), children: [
        _pageHeader('حساب ZARO'),
        const _InfoPanel(text: 'سجّل الدخول باستخدام ZARO ID وكلمة المرور. لو لسه معندكش حساب، أنشئ حساب جديد بالبريد الإلكتروني.'),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: _tabButton('تسجيل الدخول', !registering, () => setState(() { registering = false; feedback = ''; }))),
          const SizedBox(width: 8),
          Expanded(child: _tabButton('إنشاء حساب', registering, () => setState(() { registering = true; feedback = ''; }))),
        ]),
        const SizedBox(height: 15),
        if (!registering) ...[
          _input(id, 'ZARO ID', hint: 'ZARO-000001'),
          const SizedBox(height: 12),
          _input(password, 'كلمة المرور', secret: true),
          const SizedBox(height: 15),
          _actionButton('دخول إلى حسابي', busy ? null : login),
        ] else ...[
          _input(name, 'الاسم بالكامل'),
          const SizedBox(height: 12),
          _input(email, 'البريد الإلكتروني'),
          const SizedBox(height: 12),
          _input(newPassword, 'كلمة المرور (8 أحرف على الأقل)', secret: true),
          const SizedBox(height: 15),
          _actionButton('إنشاء حساب ZARO', busy ? null : signup),
        ],
        if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 15), child: Text(feedback, style: const TextStyle(color: yellow, height: 1.6), textAlign: TextAlign.center)),
      ]);
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: profile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: orange));
        if (snapshot.hasError) return Center(child: Text('تعذر تحميل الحساب: ' + snapshot.error.toString(), textAlign: TextAlign.center));
        final customer = snapshot.data?['customer'] as Map<String, dynamic>?;
        final app = snapshot.data?['app'] as Map<String, dynamic>?;
        final status = (customer?['status'] ?? 'pending').toString();
        final rank = (app?['rank_code'] ?? 'rookie').toString().toUpperCase();
        return ListView(padding: const EdgeInsets.all(20), children: [
          _pageHeader('حسابي'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: orange), gradient: const LinearGradient(colors: [Color(0xFF291000), Color(0xFF101010)])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ZARO MEMBER', style: TextStyle(color: yellow, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 9),
              Text((customer?['full_name'] ?? widget.user!.email ?? 'ZARO Player').toString(), style: const TextStyle(color: white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('ZARO ID', style: TextStyle(color: muted, fontSize: 11)),
              Text((customer?['zaro_id'] ?? 'بانتظار موافقة الإدارة').toString(), style: const TextStyle(color: yellow, fontSize: 20, fontWeight: FontWeight.w900)),
            ]),
          ),
          const SizedBox(height: 14),
          _InfoPanel(text: status == 'active' ? 'حسابك نشط. تقدر تسجل طلبات وتستخدم مركز الدعم.' : 'حالة الحساب: ' + status + '. بعد موافقة الإدارة هيظهر رقم ZARO ID وتقدر تسجل طلبات.'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _statCard('RANK', rank)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('POINTS', (app?['points'] ?? 0).toString())),
          ]),
          const SizedBox(height: 12),
          _statCard('إجمالي مشترياتك', (app?['lifetime_spend'] ?? 0).toString() + ' ج.م'),
          const SizedBox(height: 18),
          _actionButton('تسجيل الخروج', () async { await supabase.auth.signOut(); if (mounted) setState(() {}); }),
        ]);
      },
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(backgroundColor: active ? const Color(0xFF321700) : panel, foregroundColor: active ? yellow : white, side: BorderSide(color: active ? yellow : orange.withOpacity(.4))),
    child: Text(label),
  );
}

class OrdersPage extends StatelessWidget {
  final bool arabic;
  final User? user;
  const OrdersPage({super.key, required this.arabic, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const _LoginPrompt();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: orange));
        if (snapshot.hasError) return Center(child: Text('تعذر تحميل الطلبات: ' + snapshot.error.toString()));
        final orders = snapshot.data ?? [];
        return RefreshIndicator(
          color: orange,
          onRefresh: () async { await _load(); },
          child: ListView(padding: const EdgeInsets.all(18), children: [
            _pageHeader('طلباتي'),
            if (orders.isEmpty) const _InfoPanel(text: 'لسه مفيش طلبات مرتبطة بحسابك. الطلبات اللي بتعملها من التطبيق هتظهر هنا، والإدارة هتشوفها في لوحة ZARO.'),
            ...orders.map((o) => Card(
              color: panel,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: orange.withOpacity(.35))),
              child: ListTile(
                title: Text((o['game'] ?? 'Game').toString(), style: const TextStyle(color: white, fontWeight: FontWeight.bold)),
                subtitle: Text((o['package'] ?? '').toString() + '\nPlayer ID: ' + (o['player_id'] ?? '').toString() + '\n' + (o['created_at'] ?? '').toString(), style: const TextStyle(color: muted, height: 1.5)),
                trailing: Text((o['status'] ?? 'pending').toString(), style: const TextStyle(color: yellow, fontSize: 11, fontWeight: FontWeight.bold)),
                isThreeLine: true,
              ),
            )),
          ]),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await supabase.from('orders').select('id,game,package,player_id,zone_id,amount,status,created_at').eq('user_id', user!.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }
}

class SupportPage extends StatefulWidget {
  final bool arabic;
  final User? user;
  const SupportPage({super.key, required this.arabic, required this.user});
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final subject = TextEditingController();
  final body = TextEditingController();
  bool sending = false;
  String feedback = '';

  @override
  void dispose() { subject.dispose(); body.dispose(); super.dispose(); }

  Future<List<Map<String, dynamic>>> loadTickets() async {
    final rows = await supabase.from('support_tickets').select('id,subject,status,created_at,updated_at').eq('user_id', widget.user!.id).order('updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> createTicket() async {
    if (subject.text.trim().length < 2 || body.text.trim().length < 2) {
      setState(() => feedback = 'اكتب عنوان المشكلة وتفاصيلها.');
      return;
    }
    setState(() { sending = true; feedback = ''; });
    try {
      await supabase.rpc('zaro_app_create_support_ticket', params: {
        'p_subject': subject.text.trim(),
        'p_body': body.text.trim(),
      });
      subject.clear(); body.clear();
      setState(() => feedback = 'تم إرسال تذكرتك. فريق ZARO هيشوفها من لوحة الإدارة.');
    } catch (e) {
      setState(() => feedback = 'تعذر إرسال التذكرة: ' + e.toString());
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) return const _LoginPrompt();
    return ListView(padding: const EdgeInsets.all(18), children: [
      _pageHeader('مركز دعم ZARO'),
      const _InfoPanel(text: 'افتح تذكرة جديدة، وتابع رد فريق الدعم من نفس التطبيق. رسائلك هتظهر في لوحة إدارة ZARO.'),
      const SizedBox(height: 14),
      _input(subject, 'عنوان المشكلة'),
      const SizedBox(height: 10),
      TextField(controller: body, minLines: 3, maxLines: 6, style: const TextStyle(color: white), decoration: InputDecoration(labelText: 'اشرح المشكلة', labelStyle: const TextStyle(color: yellow), filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)))),
      const SizedBox(height: 10),
      _actionButton(sending ? 'جاري الإرسال...' : 'إرسال التذكرة', sending ? null : createTicket),
      if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(feedback, style: const TextStyle(color: yellow), textAlign: TextAlign.center)),
      const SizedBox(height: 20),
      const Text('تذاكر الدعم السابقة', style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: loadTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: orange));
          if (snapshot.hasError) return Text('تعذر تحميل التذاكر: ' + snapshot.error.toString(), style: const TextStyle(color: muted));
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) return const _InfoPanel(text: 'مفيش تذاكر دعم لحد دلوقتي.');
          return Column(children: tickets.map((ticket) => Card(
            color: panel,
            child: ListTile(
              title: Text((ticket['subject'] ?? '').toString(), style: const TextStyle(color: white, fontWeight: FontWeight.bold)),
              subtitle: Text('الحالة: ' + (ticket['status'] ?? 'open').toString(), style: const TextStyle(color: muted)),
              trailing: const Icon(Icons.chevron_left, color: yellow),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportConversationPage(ticket: ticket))),
            ),
          )).toList());
        },
      ),
    ]);
  }
}

class SupportConversationPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const SupportConversationPage({super.key, required this.ticket});
  @override
  State<SupportConversationPage> createState() => _SupportConversationPageState();
}

class _SupportConversationPageState extends State<SupportConversationPage> {
  final reply = TextEditingController();
  bool sending = false;
  Future<List<Map<String, dynamic>>> loadMessages() async {
    final rows = await supabase.from('support_messages').select('id,sender_role,body,created_at').eq('ticket_id', widget.ticket['id']).order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }
  Future<void> send() async {
    if (reply.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      await supabase.rpc('zaro_app_send_support_message', params: {'p_ticket_id': widget.ticket['id'], 'p_body': reply.text.trim()});
      reply.clear();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
  @override
  void dispose() { reply.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text((widget.ticket['subject'] ?? 'محادثة الدعم').toString())),
    body: Column(children: [
      Expanded(child: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: orange));
          if (snapshot.hasError) return Center(child: Text('تعذر تحميل الرسائل: ' + snapshot.error.toString()));
          final messages = snapshot.data ?? [];
          return ListView(padding: const EdgeInsets.all(14), children: messages.map((m) {
            final admin = m['sender_role'] == 'admin';
            return Align(
              alignment: admin ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: admin ? const Color(0xFF242424) : const Color(0xFF38200D), borderRadius: BorderRadius.circular(14), border: Border.all(color: orange.withOpacity(.35))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(admin ? 'ZARO Support' : 'أنت', style: const TextStyle(color: yellow, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text((m['body'] ?? '').toString(), style: const TextStyle(color: white, height: 1.5)),
                ]),
              ),
            );
          }).toList());
        },
      )),
      SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(child: TextField(controller: reply, style: const TextStyle(color: white), decoration: InputDecoration(hintText: 'اكتب ردك...', filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 8),
          IconButton(onPressed: sending ? null : send, icon: const Icon(Icons.send_rounded, color: yellow)),
        ]),
      )),
    ]),
  );
}

class NotificationsPage extends StatelessWidget {
  final bool arabic;
  const NotificationsPage({super.key, required this.arabic});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(arabic ? 'الإشعارات' : 'Notifications')),
    body: const Center(child: _InfoPanel(text: 'تحديثات الطلبات وردود الدعم هتظهر هنا بعد تفعيل نظام الإشعارات.')),
  );
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(padding: EdgeInsets.all(25), child: _InfoPanel(text: 'لازم تسجل الدخول بحساب ZARO الأول عشان تشوف بياناتك.')),
  );
}

class _InfoPanel extends StatelessWidget {
  final String text;
  const _InfoPanel({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15), border: Border.all(color: orange.withOpacity(.35))),
    child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: muted, height: 1.6)),
  );
}

Widget _input(TextEditingController c, String label, {bool secret = false, String? hint}) => TextField(
  controller: c, obscureText: secret, style: const TextStyle(color: white),
  decoration: InputDecoration(labelText: label, hintText: hint, labelStyle: const TextStyle(color: yellow), hintStyle: const TextStyle(color: muted), filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
);

Widget _actionButton(String label, VoidCallback? onTap) => SizedBox(
  height: 50,
  child: FilledButton(
    onPressed: onTap,
    style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.black, disabledBackgroundColor: muted.withOpacity(.3)),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
  ),
);

Widget _statCard(String title, String value) => Container(
  width: double.infinity, padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(13), border: Border.all(color: orange.withOpacity(.35))),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: muted, fontSize: 11)),
    const SizedBox(height: 5),
    Text(value, style: const TextStyle(color: yellow, fontWeight: FontWeight.w900, fontSize: 17)),
  ]),
);

Widget _pageHeader(String title) => Padding(
  padding: const EdgeInsets.fromLTRB(2, 14, 2, 18),
  child: Row(children: [
    Image.asset('assets/zaro-logo.png', width: 68, height: 48, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('ZARO', style: TextStyle(color: orange, fontWeight: FontWeight.w900))),
    const SizedBox(width: 12),
    Text(title, style: const TextStyle(color: white, fontSize: 23, fontWeight: FontWeight.w900)),
  ]),
);
