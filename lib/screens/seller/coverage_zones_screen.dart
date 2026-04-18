import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';

class CoverageZonesScreen extends StatefulWidget {
  const CoverageZonesScreen({super.key});

  @override
  State<CoverageZonesScreen> createState() => _CoverageZonesScreenState();
}

class _CoverageZonesScreenState extends State<CoverageZonesScreen> {
  final List<String> _allZones = [
    'Tokoin',
    'Avépozo',
    'Adidogomé',
    'Bè',
    'Kégué',
    'Nyékonakpoè',
    'Agbalépédo',
    'Amadahomé',
    'Agoè',
    'Legbassito',
  ];
  final Set<String> _selectedZones = {'Tokoin', 'Adidogomé', 'Bè'};
  String _search = '';
  late List<String> _filteredZones;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredZones = _allZones;
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _search = _searchCtrl.text.trim();
      _filteredZones = _allZones
          .where((zone) => zone.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    });
  }

  void _toggleZone(String zone) {
    setState(() {
      if (_selectedZones.contains(zone)) {
        _selectedZones.remove(zone);
      } else {
        _selectedZones.add(zone);
      }
    });
  }

  void _selectAll() {
    setState(() => _selectedZones.addAll(_filteredZones));
  }

  void _clearAll() {
    setState(() => _selectedZones.removeAll(_filteredZones));
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final activeCount = _selectedZones.length;
    final canSave = activeCount > 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Zones de couverture'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: canSave ? () => Get.back() : null,
            child: Text(
              'Sauvegarder',
              style: TextStyle(
                color: canSave ? AppTheme.primary : AppTheme.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildSummaryCard(r, activeCount),
          const SizedBox(height: 20),
          _buildSearchBar(r),
          const SizedBox(height: 12),
          _buildActionButtons(r),
          const SizedBox(height: 18),
          if (_selectedZones.isNotEmpty) ...[
            _buildSectionTitle('Zones activées'),
            const SizedBox(height: 10),
            _buildSelectedChips(),
            const SizedBox(height: 18),
          ],
          _buildSectionTitle('Zones disponibles'),
          const SizedBox(height: 12),
          ..._buildZoneListWidgets(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(R r, int activeCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zones de couverture',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez les quartiers que vous pouvez desservir. Les zones actives aident vos clients à savoir si vous livrez chez eux.',
            style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground, height: 1.6),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildSummaryBadge(Icons.location_on_outlined, '$activeCount activées'),
              SizedBox(width: r.s(12)),
              _buildSummaryBadge(Icons.speed, '10 km max'),
              SizedBox(width: r.s(12)),
              _buildSummaryBadge(Icons.calendar_month, '7j/7'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(R r) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.mutedForeground),
          SizedBox(width: r.s(10)),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Rechercher une zone',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(R r) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: _selectAll,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.cardColor,
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Tout sélectionner',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: r.s(10)),
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: _clearAll,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.cardColor,
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Tout désélectionner',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.foreground,
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: _selectedZones.map((zone) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                zone,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildZoneListWidgets() {
    final zones = _filteredZones;
    if (zones.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Text(
            'Aucune zone trouvée.\nEssayez une autre recherche.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.mutedForeground, height: 1.5),
          ),
        ),
      ];
    }

    return zones
        .map((zone) {
          final selected = _selectedZones.contains(zone);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildZoneTile(zone, selected),
          );
        })
        .toList();
  }

  Widget _buildZoneTile(String zone, bool selected) {
    return TogoPressableScale(
      onTap: () => _toggleZone(zone),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check : Icons.location_city,
                color: selected ? AppTheme.primary : AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Livraison jusqu’à 10 km • 30 min',
                    style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
