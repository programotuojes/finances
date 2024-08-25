import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

final _isPermissionHandlerSupportedPlatform = Platform.isAndroid || Platform.isIOS || kIsWeb || Platform.isWindows;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListenableBuilder(
        listenable: AppPaths.listenable,
        builder: (context, child) {
          return ListView(
            children: [
              ListTile(
                leading: const SizedBox.shrink(),
                title: Text(
                  'General',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              ListTile(
                onTap: () async {
                  if (_isPermissionHandlerSupportedPlatform &&
                      !await Permission.storage.request().isGranted &&
                      !await Permission.manageExternalStorage.isGranted) {
                    if (context.mounted) {
                      _showMissingPermissionsSnackBar(context);
                    }
                    return;
                  }

                  var dir = await getDirectoryPath();
                  if (dir != null) {
                    await AppPaths.setAppPath(dir);
                  }
                },
                leading: const Icon(Icons.folder_open),
                title: const Text('Location'),
                subtitle: Text(AppPaths.base),
              ),
              ListTile(
                onTap: () async {
                  await AppPaths.setAppPath(AppPaths.baseDefault);
                },
                leading: const Icon(Icons.restore),
                title: const Text('Reset to default location'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMissingPermissionsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Don't have storage permissions"),
        action: SnackBarAction(
          label: 'Open settings',
          onPressed: () async {
            await openAppSettings();
          },
        ),
      ),
    );
  }
}
