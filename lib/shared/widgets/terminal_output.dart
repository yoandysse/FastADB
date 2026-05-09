import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TerminalOutput extends StatelessWidget {
  final List<String> lines;
  final bool expanded;
  final VoidCallback? onCollapse;

  const TerminalOutput({
    Key? key,
    this.lines = const [],
    this.expanded = false,
    this.onCollapse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!expanded && lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.background,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expanded)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Terminal Output',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (onCollapse != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
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
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Courier',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (expanded && lines.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No output'),
              ),
            ),
        ],
      ),
    );
  }
}
