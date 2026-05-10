import 'package:flutter/material.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class ShortcutsScreen extends StatelessWidget {
  const ShortcutsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);

    return AppShell(
      currentRoute: 'shortcuts',
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: p.background,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.shortcutsTitle,
                style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Container(height: 1, color: p.divider),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: 48, color: p.textDisabled),
                  const SizedBox(height: 16),
                  Text(l.shortcutsEmptyTitle,
                      style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(l.shortcutsEmptySubtitle,
                      style: TextStyle(color: p.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
