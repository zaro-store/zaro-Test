import 'package:flutter/material.dart';

const bg = Color(0xFF070707);
const panel = Color(0xFF151515);
const orange = Color(0xFFFF7900);
const yellow = Color(0xFFFFC400);
const white = Color(0xFFF7F7F7);
const muted = Color(0xFFB9B9B9);

void main() => runApp(const ZaroApp());

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
    ),
    home: const ZaroShell(),
  );
}

class Game {
  final String name;
  final String image;
  final String description;
  const Game(this.name, this.image, this.description);
}

const games = <Game>[
  Game('FREE FIRE', 'assets/images/freefire.jpg', 'اشحن جواهر فري فاير'),
  Game('PUBG MOBILE', 'assets/images/pubg.jpg', 'اشحن شدات ببجي'),
  Game('CALL OF DUTY', 'assets/images/cod.jpg', 'اشحن CP كول أوف ديوتي'),
  Game('EA SPORTS FC', 'assets/images/fc.jpg', 'اشحن نقاط FC'),
  Game('MOBILE LEGENDS', 'assets/images/ml.jpg', 'اشحن ألماس موبايل ليجندز'),
  Game('ROBLOX', 'assets/images/roblox.jpg', 'اشحن Robux'),
];

class ZaroShell extends StatefulWidget {
  const ZaroShell({super.key});
  @override
  State<ZaroShell> createState() => _ZaroShellState();
}

class _ZaroShellState extends State<ZaroShell> {
  int tab = 0;
  bool arabic = true;

  String t(String ar, String en) => arabic ? ar : en;

  void openGame(Game game) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameDetailPage(game: game, arabic: arabic),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(arabic: arabic, onGameTap: openGame, onSeeAll: () => setState(() => tab = 1)),
      GamesPage(arabic: arabic, onGameTap: openGame),
      SimplePage(
        icon: Icons.receipt_long_rounded,
        title: t('طلباتي', 'My Orders'),
        message: t('طلباتك هتظهر هنا بعد ربط نظام الطلبات بالحساب.', 'Your orders will appear here once order services are connected.'),
        arabic: arabic,
      ),
      SimplePage(
        icon: Icons.headset_mic_rounded,
        title: t('الدعم', 'Support'),
        message: t('مركز دعم ZARO. خدمة المحادثة والطلبات المباشرة لم يتم ربطها بعد.', 'ZARO support center. Live chat and ticket services are not connected yet.'),
        arabic: arabic,
      ),
      SimplePage(
        icon: Icons.person_rounded,
        title: t('حسابي', 'My Account'),
        message: t('ملف الحساب وتسجيل الدخول سيتم تفعيله عند ربط نظام الحسابات.', 'Account profile and sign-in will be enabled when account services are connected.'),
        arabic: arabic,
      ),
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
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 70,
              child: Row(children: [
                _navItem(0, Icons.home_rounded, t('الرئيسية', 'Home')),
                _navItem(1, Icons.sports_esports_rounded, t('الألعاب', 'Games')),
                _navItem(2, Icons.shopping_bag_rounded, t('طلباتي', 'Orders')),
                _navItem(3, Icons.headset_mic_rounded, t('الدعم', 'Support')),
                _navItem(4, Icons.person_rounded, t('حسابي', 'Account')),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) => Expanded(
    child: InkWell(
      onTap: () => setState(() => tab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            height: 3,
            width: tab == index ? 27 : 0,
            decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  final bool arabic;
  final ValueChanged<Game> onGameTap;
  final VoidCallback onSeeAll;
  const HomePage({super.key, required this.arabic, required this.onGameTap, required this.onSeeAll});

  String t(String ar, String en) => arabic ? ar : en;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(child: _header(context)),
      SliverToBoxAdapter(child: _hero()),
      SliverToBoxAdapter(child: _sectionTitle()),
      SliverToBoxAdapter(child: SizedBox(
        height: 178,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          itemCount: games.length,
          separatorBuilder: (_, __) => const SizedBox(width: 11),
          itemBuilder: (_, i) => _gameCard(games[i]),
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

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(15, 8, 15, 14),
    child: Row(children: [
      SizedBox(width: 154, height: 68, child: Image.asset(
        'assets/zaro-logo.png', fit: BoxFit.contain, alignment: Alignment.centerLeft,
        errorBuilder: (_, __, ___) => const Text('ZARO', style: TextStyle(fontSize: 32, color: orange, fontWeight: FontWeight.w900)),
      )),
      const Spacer(),
      _roundButton(context, Icons.notifications_none_rounded),
      const SizedBox(width: 9),
      _roundButton(context, Icons.person_outline_rounded),
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
  );

  Widget _roundButton(BuildContext context, IconData icon) => InkWell(
    onTap: () {
      if (icon == Icons.notifications_none_rounded) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsPage(arabic: arabic)));
      } else {
        (context.findAncestorStateOfType<_ZaroShellState>()!).setState(() => (context.findAncestorStateOfType<_ZaroShellState>()!).tab = 4);
      }
    },
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: panel, border: Border.all(color: orange)),
      child: Icon(icon, color: white, size: 24),
    ),
  );

  Widget _hero() => Container(
    height: 220,
    margin: const EdgeInsets.symmetric(horizontal: 14),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: orange, width: 1.4),
      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF321300), Color(0xFF080808), Color(0xFF1C0900)]),
      boxShadow: [BoxShadow(color: orange.withOpacity(.2), blurRadius: 20)],
    ),
    child: Stack(children: [
      Positioned(right: -10, top: -6, bottom: -6, width: 205, child: Opacity(
        opacity: .30,
        child: Image.asset('assets/zaro-logo.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
      )),
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
  );

  Widget _sectionTitle() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
    child: Row(children: [
      const Icon(Icons.sports_esports_rounded, color: yellow, size: 24),
      const SizedBox(width: 8),
      Text(t('الألعاب المتاحة', 'AVAILABLE GAMES'), style: const TextStyle(color: white, fontSize: 19, fontWeight: FontWeight.w900)),
      const Spacer(),
      TextButton(onPressed: onSeeAll, child: Text(t('عرض الكل', 'VIEW ALL'), style: const TextStyle(color: yellow, fontWeight: FontWeight.bold))),
    ]),
  );

  Widget _gameCard(Game game) => InkWell(
    onTap: () => onGameTap(game),
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: 132,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: orange, width: 1.1)),
      child: Image.asset(game.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(
        color: panel, alignment: Alignment.center,
        child: Text(game.name, textAlign: TextAlign.center, style: const TextStyle(color: white, fontWeight: FontWeight.bold)),
      )),
    ),
  );
}

class GamesPage extends StatelessWidget {
  final bool arabic;
  final ValueChanged<Game> onGameTap;
  const GamesPage({super.key, required this.arabic, required this.onGameTap});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
    child: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _pageHeader(arabic ? 'كل الألعاب' : 'All Games')),
      SliverPadding(
        padding: const EdgeInsets.all(14),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, i) => InkWell(
            onTap: () => onGameTap(games[i]),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              clipBehavior: Clip.antiAlias,
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
    ]),
  );
}

class GameDetailPage extends StatelessWidget {
  final Game game;
  final bool arabic;
  const GameDetailPage({super.key, required this.game, required this.arabic});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      appBar: AppBar(title: Text(game.name), backgroundColor: bg, foregroundColor: white),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(game.image, height: 230, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 180, child: Icon(Icons.videogame_asset, color: yellow, size: 70)))),
        const SizedBox(height: 20),
        Text(game.name, style: const TextStyle(color: yellow, fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(game.description, style: const TextStyle(color: white, fontSize: 16)),
        const SizedBox(height: 15),
        Text(arabic ? 'صفحة الشحن التفصيلية وربط الباقات والدفع لم يتم تفعيله داخل نسخة التطبيق الحالية.' : 'The full top-up page, packages and payment are not enabled in this app build yet.', style: const TextStyle(color: muted, height: 1.6)),
      ]),
    ),
  );
}

class NotificationsPage extends StatelessWidget {
  final bool arabic;
  const NotificationsPage({super.key, required this.arabic});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      appBar: AppBar(title: Text(arabic ? 'الإشعارات' : 'Notifications'), backgroundColor: bg, foregroundColor: white),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.notifications_off_outlined, color: yellow, size: 62),
          const SizedBox(height: 14),
          Text(arabic ? 'مفيش إشعارات جديدة' : 'No new notifications', style: const TextStyle(color: white, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(arabic ? 'لما يبقى فيه تحديث حقيقي لطلبك أو حسابك هيظهر هنا.' : 'Real order or account updates will appear here.', textAlign: TextAlign.center, style: const TextStyle(color: muted, height: 1.5)),
        ]),
      )),
    ),
  );
}

class SimplePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool arabic;
  const SimplePage({super.key, required this.icon, required this.title, required this.message, required this.arabic});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
    child: Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/zaro-logo.png', width: 145, height: 90, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('ZARO', style: TextStyle(color: orange, fontSize: 34, fontWeight: FontWeight.w900))),
        const SizedBox(height: 22),
        Icon(icon, color: yellow, size: 48),
        const SizedBox(height: 13),
        Text(title, style: const TextStyle(color: white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: muted, height: 1.6)),
      ]),
    )),
  );
}

Widget _pageHeader(String title) => Padding(
  padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
  child: Row(children: [
    Image.asset('assets/zaro-logo.png', width: 70, height: 48, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('ZARO', style: TextStyle(color: orange, fontWeight: FontWeight.w900))),
    const SizedBox(width: 12),
    Text(title, style: const TextStyle(color: white, fontSize: 23, fontWeight: FontWeight.w900)),
  ]),
);
