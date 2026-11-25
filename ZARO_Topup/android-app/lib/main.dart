import 'package:flutter/material.dart';

const bg = Color(0xFF050505), orange = Color(0xFFFF7900), yellow = Color(0xFFFFC400), white = Color(0xFFF7F7F7), muted = Color(0xFFB9B9B9);
const root = 'https://zaro-store.github.io/zaro-Test/ZARO_Topup/';
String img(String file) => '${root}ZARO_game_images_v2/images/$file';
const logo = '${root}zaro-logo.png.png';

void main() => runApp(const ZaroApp());

class ZaroApp extends StatelessWidget {
  const ZaroApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'ZARO',
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: bg, colorScheme: const ColorScheme.dark(primary: orange, secondary: yellow), useMaterial3: true),
    home: const ZaroHome(),
  );
}

class ZaroHome extends StatefulWidget {
  const ZaroHome({super.key});
  @override
  State<ZaroHome> createState() => _ZaroHomeState();
}

class _ZaroHomeState extends State<ZaroHome> {
  int tab = 0;
  bool ar = true;
  String tr(String a, String e) => ar ? a : e;
  final games = const [
    ['CALL OF DUTY','cod.jpg'], ['ROBLOX','roblox.jpg'], ['FREE FIRE','freefire.jpg'],
    ['PUBG MOBILE','pubg.jpg'], ['MOBILE LEGENDS','ml.jpg'], ['EA SPORTS FC','fc.jpg'],
  ];
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      body: SafeArea(bottom: false, child: Stack(children: [
        const Positioned.fill(child: _Glow()),
        CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(child: header()),
          SliverToBoxAdapter(child: hero()),
          SliverToBoxAdapter(child: dots()),
          SliverToBoxAdapter(child: heading()),
          SliverToBoxAdapter(child: gameCards()),
          SliverToBoxAdapter(child: footer()),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
        ]),
      ])),
      bottomNavigationBar: bottomBar(),
    ),
  );

  Widget header() => Padding(
    padding: const EdgeInsets.fromLTRB(15, 8, 15, 14),
    child: Row(children: [
      SizedBox(width: 180, height: 76, child: Image.network(logo, fit: BoxFit.contain, alignment: Alignment.centerLeft, errorBuilder: (_,__,___) => const Text('ZARO', style: TextStyle(fontSize: 32, color: orange, fontWeight: FontWeight.w900)))),
      const Spacer(),
      action(Icons.notifications_none_rounded, '3'), const SizedBox(width: 10), action(Icons.person_outline_rounded),
      const SizedBox(width: 9),
      InkWell(onTap: () => setState(() => ar = !ar), child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: orange), borderRadius: BorderRadius.circular(22), color: const Color(0xFF101010)),
        child: Text(ar ? 'EN' : 'عربي', style: const TextStyle(color: yellow, fontWeight: FontWeight.bold)),
      )),
    ]),
  );

  Widget action(IconData icon, [String? badge]) => Stack(clipBehavior: Clip.none, children: [
    Container(width: 47, height: 47, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0B0B0B), border: Border.all(color: orange)), child: Icon(icon, color: white, size: 26)),
    if (badge != null) Positioned(top: -4, right: -3, child: CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
  ]);

  Widget hero() => Container(
    height: 222, margin: const EdgeInsets.symmetric(horizontal: 14), clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25), border: Border.all(color: orange, width: 1.4),
      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF321300), Color(0xFF080808), Color(0xFF1C0900)]),
      boxShadow: [BoxShadow(color: orange.withOpacity(.24), blurRadius: 22)],
    ),
    child: Stack(children: [
      Positioned(right: -15, top: -15, bottom: -20, width: 235, child: Opacity(opacity: .82, child: Image.network(logo, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()))),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Colors.black.withOpacity(.02), Colors.black.withOpacity(.35), Colors.black.withOpacity(.92)])))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(tr('اشحن الآن','TOP UP NOW'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: white)),
          const SizedBox(height: 7),
          Text(tr('بأمان وسرعة على ZARO','Fast and secure with ZARO'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: white)),
          const SizedBox(height: 17),
          Container(padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 11), decoration: BoxDecoration(color: const Color(0xFF241000), borderRadius: BorderRadius.circular(30), border: Border.all(color: yellow, width: 1.7), boxShadow: [BoxShadow(color: orange.withOpacity(.42), blurRadius: 14)]), child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(tr('اشحن الآن','TOP UP NOW'), style: const TextStyle(color: white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10), const Icon(Icons.chevron_left, color: yellow),
          ])),
        ],
      )),
    ]),
  );

  Widget dots() => Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(
    width: i == 0 ? 30 : 12, height: 9, margin: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(color: i == 0 ? yellow : const Color(0xFF555555), borderRadius: BorderRadius.circular(20)),
  ))));

  Widget heading() => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 14), child: Row(children: [
    const Icon(Icons.sports_esports_rounded, color: yellow, size: 25), const SizedBox(width: 8),
    Text(tr('جميع الألعاب','ALL GAMES'), style: const TextStyle(color: white, fontSize: 21, fontWeight: FontWeight.w900)),
    const Spacer(),
    Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: orange.withOpacity(.8))), child: Row(children: [
      Text(tr('عرض الكل','VIEW ALL'), style: const TextStyle(color: white, fontWeight: FontWeight.w700)), const SizedBox(width: 4), const Icon(Icons.chevron_left, color: yellow, size: 19),
    ])),
  ]));

  Widget gameCards() => SizedBox(height: 178, child: ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 14), scrollDirection: Axis.horizontal, itemCount: games.length,
    separatorBuilder: (_,__) => const SizedBox(width: 10),
    itemBuilder: (_,i) => Container(width: 132, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: orange, width: 1.2), boxShadow: [BoxShadow(color: orange.withOpacity(.15), blurRadius: 12)]),
      child: Image.network(img(games[i][1]), fit: BoxFit.cover, errorBuilder: (_,__,___) => Center(child: Text(games[i][0], textAlign: TextAlign.center))),
    ),
  ));

  Widget footer() => Padding(padding: const EdgeInsets.only(top: 25), child: Column(children: const [
    Text('ZARO.', style: TextStyle(color: orange, fontSize: 31, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2)),
    SizedBox(height: 4), Text('YOUR GAME. YOUR WORLD.', style: TextStyle(color: white, fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.w600)),
  ]));

  Widget bottomBar() {
    final labels = ar ? ['الرئيسية','الألعاب','طلباتي','الدعم','حسابي'] : ['Home','Games','Orders','Support','Account'];
    const icons = [Icons.home_rounded, Icons.sports_esports_rounded, Icons.shopping_bag_rounded, Icons.headset_mic_rounded, Icons.person_rounded];
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF090909), border: Border(top: BorderSide(color: orange.withOpacity(.9), width: 1.2)), boxShadow: [BoxShadow(color: orange.withOpacity(.18), blurRadius: 18, offset: const Offset(0,-5))]),
      child: SafeArea(top: false, child: SizedBox(height: 72, child: Row(children: List.generate(5, (i) => Expanded(child: InkWell(
        onTap: () => setState(() => tab = i),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(border: i < 4 ? Border(left: BorderSide(color: orange.withOpacity(.24))) : null),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icons[i], size: 25, color: tab == i ? yellow : muted), const SizedBox(height: 4),
            Text(labels[i], maxLines: 1, style: TextStyle(color: tab == i ? yellow : white, fontSize: 11, fontWeight: tab == i ? FontWeight.w900 : FontWeight.w600)),
            const SizedBox(height: 3), AnimatedContainer(duration: const Duration(milliseconds: 200), height: 3, width: tab == i ? 34 : 0, decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(4))),
          ]),
        ),
      )))))),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow();
  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _GlowPainter(), child: const SizedBox.expand()));
}
class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..shader = const LinearGradient(colors: [Color(0x24FF6A00), Color(0x00FF6A00)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
    final line = Paint()..color = orange.withOpacity(.2)..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0,30)..lineTo(size.width*.18,0)..moveTo(size.width,size.height*.76)..lineTo(size.width*.82,size.height);
    canvas.drawPath(path,line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
