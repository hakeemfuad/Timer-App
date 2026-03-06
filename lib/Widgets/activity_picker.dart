import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityPicker extends StatelessWidget {
  final String title;
  final Color accentColor;
  final void Function(Activity) onSelected;

  const ActivityPicker({
    super.key,
    required this.title,
    required this.accentColor,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required Color accentColor,
    required void Function(Activity) onSelected,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => ActivityPicker(
        title: title,
        accentColor: accentColor,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final dialogWidth = (screen.width * 0.85).clamp(320.0, 580.0);
    final dialogHeight = (screen.height * 0.75).clamp(400.0, 680.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.grid_view_rounded,
                          color: accentColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Color(0xFF666666), size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.grey[100], height: 1),
              const SizedBox(height: 8),

              // Activity grid
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: Activity.all.length,
                  itemBuilder: (context, i) {
                    final activity = Activity.all[i];
                    return _ActivityCell(
                      activity: activity,
                      accentColor: accentColor,
                      onTap: () {
                        onSelected(activity);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCell extends StatelessWidget {
  final Activity activity;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActivityCell({
    required this.activity,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14.5)),
                child: Image.asset(
                  activity.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                activity.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D).withValues(alpha: 0.85),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
