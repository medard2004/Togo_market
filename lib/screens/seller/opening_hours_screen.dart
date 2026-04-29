import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';

class OpeningHoursScreen extends StatefulWidget {
  const OpeningHoursScreen({super.key});

  @override
  State<OpeningHoursScreen> createState() => _OpeningHoursScreenState();
}

class _OpeningHoursScreenState extends State<OpeningHoursScreen> {
  final List<_DaySchedule> _days = [
    _DaySchedule(day: 'Lundi', open: true),
    _DaySchedule(day: 'Mardi', open: true),
    _DaySchedule(day: 'Mercredi', open: true),
    _DaySchedule(day: 'Jeudi', open: true),
    _DaySchedule(day: 'Vendredi', open: true),
    _DaySchedule(day: 'Samedi', open: true, closingTime: '14:00'),
    _DaySchedule(day: 'Dimanche', open: false),
  ];

  void _toggleOpen(int index, bool value) {
    setState(() {
      _days[index] = _days[index].copyWith(open: value);
    });
  }

  Future<void> _pickTime(int index, bool isOpening) async {
    final currentTime =
        isOpening ? _days[index].openingTime : _days[index].closingTime;
    final parts = currentTime.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpening ? 'Heure d\'ouverture' : 'Heure de fermeture',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.foreground,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;

      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      final finalStr = '$hh:$mm';

      setState(() {
        _days[index] = _days[index].copyWith(
          openingTime: isOpening ? finalStr : _days[index].openingTime,
          closingTime: isOpening ? _days[index].closingTime : finalStr,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasOpenDay = _days.any((day) => day.open);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        title: const Text(
          'Horaires d\'ouverture',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: hasOpenDay ? Get.back : null,
            style: TextButton.styleFrom(
              foregroundColor:
                  hasOpenDay ? AppTheme.primary : AppTheme.mutedForeground,
            ),
            child: const Text(
              'Sauvegarder',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        itemCount: _days.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildInfoCard(),
            );
          }
          final schedule = _days[index - 1];
          return _buildDayCard(schedule, index - 1);
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, color: Color(0xFFD4451A), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Indiquez vos horaires pour que les acheteurs sachent quand vous êtes disponible. Votre boutique apparaîtra comme "fermée" en dehors de ces horaires.',
              style: TextStyle(
                  fontSize: 13, height: 1.4, color: AppTheme.foreground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(_DaySchedule schedule, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.day,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  value: schedule.open,
                  activeTrackColor: AppTheme.primary,
                  inactiveTrackColor: const Color(0xFFEEEEEE),
                  onChanged: (value) => _toggleOpen(index, value),
                ),
              ),
            ],
          ),
          if (schedule.open) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeTile(
                    'OUVERTURE',
                    schedule.openingTime,
                    () => _pickTime(index, true),
                  ),
                ),
                Expanded(
                  child: _buildTimeTile(
                    'FERMETURE',
                    schedule.closingTime,
                    () => _pickTime(index, false),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            const Text(
              'Fermé ce jour',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppTheme.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeTile(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedForeground,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySchedule {
  final String day;
  final bool open;
  final String openingTime;
  final String closingTime;

  _DaySchedule({
    required this.day,
    this.open = true,
    this.openingTime = '08:00',
    this.closingTime = '18:00',
  });

  _DaySchedule copyWith({
    bool? open,
    String? openingTime,
    String? closingTime,
  }) {
    return _DaySchedule(
      day: day,
      open: open ?? this.open,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }
}
