import 'package:hive/hive.dart';

class PersistedAssetManager {
  final HiveInterface storage;

  PersistedAssetManager(this.storage);

  Future<String> getAsset(String assetId) async {
    final box = await storage.openLazyBox("hiveBoxName");

    String? asset = await box.get(assetId);

    if (asset == null) {
      asset = await fetchFromApi(assetId);
      await box.put(assetId, asset);
    }

    return asset;
  }

  Future<String> fetchFromApi(String assetId) async {
    final created = DateTime.now();

    switch (assetId) {
      case 'asset1':
        return '$created foo';
      case 'asset2':
        return '$created bar';
    }

    throw '404: $assetId not found';
  }
}
