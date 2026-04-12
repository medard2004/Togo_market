import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

class ConversationTile extends StatelessWidget {
  final dynamic item;
  final R r;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const ConversationTile({
    super.key,
    required this.item,
    required this.r,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = item.unread > 0;
    return GestureDetector(
      onTap:
          isSelectionMode ? onSelectionChanged : () => Get.toNamed('/chat/c1'),
      child: Container(
        padding: EdgeInsets.all(r.s(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.rad(16)),
          boxShadow: AppTheme.shadowCard,
          border: isSelectionMode && isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Checkbox en mode sélection
            if (isSelectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelectionChanged?.call(),
                activeColor: AppTheme.primary,
              ),
              SizedBox(width: r.s(8)),
            ],

            // Avatar + badge non lu
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: r.s(26),
                  backgroundImage: CachedNetworkImageProvider(item.img),
                  backgroundColor: AppTheme.muted,
                ),
                if (hasUnread)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: r.s(12),
                      height: r.s(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: r.s(12)),

            // Nom + dernier message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ),
                      SizedBox(width: r.s(8)),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: r.fs(11),
                          color:
                              hasUnread ? AppTheme.primary : AppTheme.mutedForeground,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.s(3)),
                  Text(
                    item.msg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.fs(13),
                      color:
                          hasUnread ? AppTheme.foreground : AppTheme.mutedForeground,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Miniature produit
            if (item.productImg != null) ...[
              SizedBox(width: r.s(10)),
              ClipRRect(
                borderRadius: BorderRadius.circular(r.rad(10)),
                child: CachedNetworkImage(
                  imageUrl: item.productImg!,
                  width: r.s(46),
                  height: r.s(46),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: r.s(46),
                    height: r.s(46),
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(r.rad(10)),
                    ),
                    child: Icon(Icons.image_not_supported,
                        size: r.s(18), color: AppTheme.mutedForeground),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(width: r.s(10)),
              Container(
                width: r.s(46),
                height: r.s(46),
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(r.rad(10)),
                ),
                child: Icon(Icons.image_not_supported_outlined,
                    size: r.s(20), color: AppTheme.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
