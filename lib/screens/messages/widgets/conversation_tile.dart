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
    return Container(
        padding: EdgeInsets.all(r.s(12)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(16)),
          boxShadow: AppTheme.shadowCard,
          border: isSelectionMode && isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Checkbox en mode sÃ©lection
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
                if (item.img.isNotEmpty)
                  CircleAvatar(
                    radius: r.s(26),
                    backgroundImage: CachedNetworkImageProvider(item.img),
                    backgroundColor: AppTheme.muted,
                  )
                else
                  CircleAvatar(
                    radius: r.s(26),
                    backgroundColor: AppTheme.muted,
                    child: Icon(Icons.person, size: r.s(26), color: AppTheme.mutedForeground),
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
                    ],
                  ),
                  SizedBox(height: r.s(3)),
                  Row(
                    children: [
                      if (item.isSentByMe) ...[
                        Icon(
                          item.isSeenByOther ? Icons.done_all : Icons.check,
                          size: 16,
                          color: item.isSeenByOther ? Colors.blueAccent : AppTheme.mutedForeground,
                        ),
                        SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: r.s(8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: r.fs(11),
                    color:
                        hasUnread ? AppTheme.primary : AppTheme.mutedForeground,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (hasUnread) ...[
                  SizedBox(height: r.s(6)),
                  Container(
                    padding: EdgeInsets.all(r.s(4)),
                    constraints: BoxConstraints(
                      minWidth: r.s(20),
                      minHeight: r.s(20),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item.unread > 99 ? '99+' : '${item.unread}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.fs(10),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
  }
}
