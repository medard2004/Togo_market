import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

class FilterModal extends StatefulWidget {
  final String selectedSort;
  final bool showOnlineOnly;
  final bool showUnreadOnly;
  final Function(String) onSortChanged;
  final Function(bool) onOnlineOnlyChanged;
  final Function(bool) onUnreadOnlyChanged;
  final Function() onFiltersApplied;

  const FilterModal({
    super.key,
    required this.selectedSort,
    required this.showOnlineOnly,
    required this.showUnreadOnly,
    required this.onSortChanged,
    required this.onOnlineOnlyChanged,
    required this.onUnreadOnlyChanged,
    required this.onFiltersApplied,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String _tempSelectedSort;
  late bool _tempShowOnlineOnly;
  late bool _tempShowUnreadOnly;

  @override
  void initState() {
    super.initState();
    _tempSelectedSort = widget.selectedSort;
    _tempShowOnlineOnly = widget.showOnlineOnly;
    _tempShowUnreadOnly = widget.showUnreadOnly;
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      margin: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.rad(20)),
        boxShadow: AppTheme.shadowCardLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header compact
          Padding(
            padding: EdgeInsets.all(r.s(16)),
            child: Row(
              children: [
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: r.fs(18),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: r.s(24),
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Contenu principal
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tri rapide - boutons en ligne
                Text(
                  'Trier par',
                  style: TextStyle(
                    fontSize: r.fs(14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(8)),
                Row(
                  children: [
                    _buildQuickSortButton('Récent', 'date_desc'),
                    SizedBox(width: r.s(8)),
                    _buildQuickSortButton('Ancien', 'date_asc'),
                    SizedBox(width: r.s(8)),
                    _buildQuickSortButton('A-Z', 'name_asc'),
                  ],
                ),

                SizedBox(height: r.s(16)),

                // Filtres - chips
                Text(
                  'Afficher',
                  style: TextStyle(
                    fontSize: r.fs(14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(8)),
                Wrap(
                  spacing: r.s(8),
                  runSpacing: r.s(8),
                  children: [
                    _buildFilterChip('En ligne', _tempShowOnlineOnly, (value) {
                      setState(() => _tempShowOnlineOnly = value);
                    }),
                    _buildFilterChip('Non lus', _tempShowUnreadOnly, (value) {
                      setState(() => _tempShowUnreadOnly = value);
                    }),
                  ],
                ),

                SizedBox(height: r.s(20)),
              ],
            ),
          ),

          // Bouton Appliquer
          Padding(
            padding: EdgeInsets.all(r.s(16)),
            child: GestureDetector(
              onTap: () {
                widget.onSortChanged(_tempSelectedSort);
                widget.onOnlineOnlyChanged(_tempShowOnlineOnly);
                widget.onUnreadOnlyChanged(_tempShowUnreadOnly);
                widget.onFiltersApplied();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: r.s(44),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(12)),
                ),
                child: Center(
                  child: Text(
                    'Appliquer les filtres',
                    style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSortButton(String label, String value) {
    final r = R(context);
    final isSelected = _tempSelectedSort == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tempSelectedSort = value),
        child: Container(
          height: r.s(36),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.rad(8)),
            border: Border.all(
              color:
                  isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: r.fs(12),
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, Function(bool) onChanged) {
    final r = R(context);
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(6)),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.rad(16)),
          border: Border.all(
            color:
                isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: r.fs(12),
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.foreground,
          ),
        ),
      ),
    );
  }
}
