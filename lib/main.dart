import 'package:flutter/material.dart';
import 'download_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.now();

  final downloadManager = DownloadManager();

  final asset1 = await downloadManager.getAsset('asset1');
  print('$now asset1: $asset1');
  final asset2 = await downloadManager.getAsset('asset2');
  print('$now asset2: $asset2');
}
