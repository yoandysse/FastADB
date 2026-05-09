import 'package:flutter/material.dart';
import '../../shared/widgets/app_shell.dart';

class ShortcutsScreen extends StatelessWidget {
  const ShortcutsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: 'shortcuts',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shortcuts'),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Shortcuts will be configured here'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Open add shortcut modal
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
