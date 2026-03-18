import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    Stream.periodic(const Duration(milliseconds: 40), (i) => i)
        .take(50)
        .listen((i) {
      if (mounted) setState(() => _progress = (i + 1) * 2.0 / 100.0);
      if (i == 49) Future.delayed(const Duration(milliseconds: 200), () => Get.offNamed('/onboarding'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.s(32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: r.s(88), height: r.s(88),
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(r.rad(28))),
                child: Icon(Icons.shopping_bag_outlined, size: r.s(48), color: AppTheme.primary),
              ),
              SizedBox(height: r.s(24)),
              Text('Togo Market',
                  style: TextStyle(fontSize: r.fs(32), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
              SizedBox(height: r.s(8)),
              Text('Le Marché Local de Lomé',
                  style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w500, color: AppTheme.primary)),
              SizedBox(height: r.s(48)),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppTheme.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 6,
                ),
              ),
              SizedBox(height: r.s(32)),
              Text('SIMPLE • ÉLÉGANT • LOCAL',
                  style: TextStyle(fontSize: r.fs(11), fontWeight: FontWeight.w700, letterSpacing: 2, color: AppTheme.mutedForeground)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(8)),
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(r.rad(20))),
                child: Text('🇹🇬 FAIT AU TOGO',
                    style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
              SizedBox(height: r.s(40)),
            ],
          ),
        ),
      ),
    );
  }
}
