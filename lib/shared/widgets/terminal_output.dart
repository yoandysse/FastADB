import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TerminalOutput extends StatelessWidget {
  final List<String> lines;
  final bool expanded;
  final VoidCallback? onCollapse;

  const TerminalOutput({
    super.key,
    this.lines = const [],
    this.expanded = false,
    this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded && lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final p = AppPalette.of(context);

    return Container(
      color: p.background,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: p.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expanded)
            Container(
              padding: const EdgeInsets.all(8),
              color: p.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terminal Output',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.textPrimary),
                  ),
                  if (onCollapse != null)
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: p.textSecondary),
                      onPressed: onCollapse,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          if (expanded && lines.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      lines[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Courier',
                        color: p.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (expanded && lines.isEmpty)
            Expanded(
              child: Center(
                child: Text('No output', style: TextStyle(color: p.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }
}
