import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SellerStatsScreen extends StatefulWidget {
  const SellerStatsScreen({super.key});

  @override
  State<SellerStatsScreen> createState() => _SellerStatsScreenState();
}

class _SellerStatsScreenState extends State<SellerStatsScreen>
    with SingleTickerProviderStateMixin {
  int selectedPeriod = 0;
  late final AnimationController _controller;
  late final Animation<double> _periodAnim;
  late final Animation<double> _kpiAnim;
  late final Animation<double> _barChartAnim;
  late final Animation<double> _lineChartAnim;
  late final Animation<double> _pieChartAnim;
  late final Animation<double> _topProductsAnim;

  final kpis = const <KPI>[
    KPI(
        icon: Icons.visibility_outlined,
        label: 'Vues totales',
        value: '230',
        change: '+12%',
        positive: true),
    KPI(
        icon: Icons.shopping_cart_outlined,
        label: 'Commandes',
        value: '18',
        change: '+5%',
        positive: true),
    KPI(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        value: '42',
        change: '-3%',
        positive: false),
    KPI(
        icon: Icons.star_outline,
        label: 'Note moyenne',
        value: '4.8',
        change: '+0.2',
        positive: true),
  ];

  final topProducts = const [
    {'name': 'iPhone 13 Pro', 'views': 85, 'orders': 12},
    {'name': 'Samsung Galaxy S22', 'views': 62, 'orders': 8},
    {'name': 'AirPods Pro', 'views': 48, 'orders': 15},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _periodAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut));
    _kpiAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOut));
    _barChartAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut));
    _lineChartAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut));
    _pieChartAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut));
    _topProductsAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _StatsAppBar(
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            FadeSlideIn(
              animation: _periodAnim,
              child: _PeriodSelector(
                selectedIndex: selectedPeriod,
                onSelect: (i) => setState(() => selectedPeriod = i),
              ),
            ),

            const SizedBox(height: 16),

            FadeSlideIn(
              animation: _kpiAnim,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: List.generate(kpis.length, (i) {
                  final k = kpis[i];
                  final start = 0.1 + (i * 0.05);
                  final end = start + 0.3;
                  final kpiItemAnim = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      start.clamp(0.0, 1.0),
                      end.clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  );
                  return FadeSlideIn(
                    animation: kpiItemAnim,
                    offsetY: 10,
                    child: _TapScale(
                      onTap: () {},
                      child: _KpiCard(kpi: k),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            FadeSlideIn(
              animation: _barChartAnim,
              child: _TapScale(
                onTap: () {},
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vues par jour',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Évolution des visites sur votre boutique',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 176,
                        child: BarChart(
                          _barChartData(),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FadeSlideIn(
              animation: _lineChartAnim,
              child: _TapScale(
                onTap: () {},
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ventes mensuelles',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Nombre de ventes par mois',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 176,
                        child: LineChart(
                          _lineChartData(),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FadeSlideIn(
              animation: _pieChartAnim,
              child: _TapScale(
                onTap: () {},
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Répartition par catégorie',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Catégories les plus consultées',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 128,
                            height: 128,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                                sections: [
                                  PieChartSectionData(
                                      value: 45,
                                      color: AppTheme.primary,
                                      radius: 25,
                                      showTitle: false),
                                  PieChartSectionData(
                                      value: 25,
                                      color: AppTheme.secondary,
                                      radius: 25,
                                      showTitle: false),
                                  PieChartSectionData(
                                      value: 20,
                                      color: const Color(0xFFF59E0B),
                                      radius: 25,
                                      showTitle: false),
                                  PieChartSectionData(
                                      value: 10,
                                      color: const Color(0xFF94A3B8),
                                      radius: 25,
                                      showTitle: false),
                                ],
                              ),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: _DonutLegend(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FadeSlideIn(
              animation: _topProductsAnim,
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits les plus vus',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Top 3 produits',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (var i = 0; i < topProducts.length; i++) ...[
                      if (i != 0)
                        const Divider(
                          color: AppTheme.border,
                          height: 1,
                          thickness: 1,
                        ),
                      Builder(builder: (context) {
                        final delay = 0.5 + (i * 0.06);
                        final productAnim = CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            delay.clamp(0.0, 1.0),
                            (delay + 0.25).clamp(0.0, 1.0),
                            curve: Curves.easeOut,
                          ),
                        );
                        return FadeSlideIn(
                          animation: productAnim,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: _TapScale(
                              onTap: () {},
                              child: _TopProductRow(
                                rank: i + 1,
                                name: topProducts[i]['name'] as String,
                                views: topProducts[i]['views'] as int,
                                orders: topProducts[i]['orders'] as int,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  BarChartData _barChartData() {
    const values = [18, 32, 25, 40, 35, 52, 28];
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 60,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppTheme.cardColor,
          tooltipBorder: const BorderSide(color: AppTheme.border),
          tooltipBorderRadius: BorderRadius.circular(12),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.toInt()} vues',
              const TextStyle(
                color: AppTheme.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
              final i = value.toInt();
              if (i < 0 || i >= days.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  days[i],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 15,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedForeground,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 15,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: AppTheme.border,
          strokeWidth: 1,
          dashArray: [3, 3],
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: values.asMap().entries.map((e) {
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.toDouble(),
              color: AppTheme.primary,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData _lineChartData() {
    return LineChartData(
      minY: 0,
      maxY: 35,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: AppTheme.border,
          strokeWidth: 1,
          dashArray: [3, 3],
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
              final i = value.toInt();
              if (i < 0 || i >= months.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  months[i],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 10,
            getTitlesWidget: (value, meta) => Text(
              '${value.toInt()}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.mutedForeground,
              ),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 12),
            FlSpot(1, 18),
            FlSpot(2, 15),
            FlSpot(3, 24),
            FlSpot(4, 30),
            FlSpot(5, 22),
          ],
          isCurved: true,
          color: AppTheme.primary,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: AppTheme.primary,
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.cardColor,
          tooltipBorder: const BorderSide(color: AppTheme.border),
          tooltipBorderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _StatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  const _StatsAppBar({required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.background.withAlpha(204); // ~0.8
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppTheme.foreground,
            ),
          ),
          leading: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 20, color: AppTheme.primary),
          ),
          actions: const [SizedBox(width: 36)],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: AppTheme.border),
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _PeriodSelector({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = const ['7 jours', '30 jours', '3 mois'];
    return Row(
      children: List.generate(items.length, (i) {
        final active = selectedIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
            child: _TapScale(
              onTap: () => onSelect(i),
              duration: const Duration(milliseconds: 100),
              pressedScale: 0.96,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : const Color(0xFFF1EDE8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(77), // 0.3
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : const [],
                ),
                child: Center(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppTheme.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowCard,
      ),
      child: child,
    );
  }
}

class KPI {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final bool positive;

  const KPI({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
  });
}

class _KpiCard extends StatelessWidget {
  final KPI kpi;
  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final changeColor = kpi.positive ? AppTheme.green : AppTheme.red;
    final changeIcon =
        kpi.positive ? Icons.trending_up : Icons.trending_down;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(26), // 0.1
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(kpi.icon, size: 14, color: AppTheme.primary),
              ),
              Row(
                children: [
                  Icon(changeIcon, size: 10, color: changeColor),
                  const SizedBox(width: 4),
                  Text(
                    kpi.change,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            kpi.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kpi.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Électronique', 45, AppTheme.primary),
      ('Mode', 25, AppTheme.secondary),
      ('Maison', 20, Color(0xFFF59E0B)),
      ('Autres', 10, Color(0xFF94A3B8)),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final it in items) ...[
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: it.$3, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  it.$1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.foreground,
                  ),
                ),
              ),
              Text(
                '${it.$2}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ]
      ],
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int rank;
  final String name;
  final int views;
  final int orders;

  const _TopProductRow({
    required this.rank,
    required this.name,
    required this.views,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.visibility,
                      size: 10, color: AppTheme.mutedForeground),
                  const SizedBox(width: 4),
                  Text(
                    '$views vues',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.inventory_2,
                      size: 10, color: AppTheme.mutedForeground),
                  const SizedBox(width: 4),
                  Text(
                    '$orders ventes',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.animation,
    required this.child,
    this.offsetY = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, (1 - animation.value) * offsetY),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressedScale;

  const _TapScale({
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.pressedScale = 0.96,
  });

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

