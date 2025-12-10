import 'dart:typed_data';

import 'package:asset_delivery/asset_delivery.dart';
import 'package:asset_delivery/asset_delivery_method_channel.dart';
import 'package:asset_delivery/asset_delivery_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAssetDeliveryPlatform
    with MockPlatformInterfaceMixin
    implements AssetDeliveryPlatform {
  MockAssetDeliveryPlatform({this.assetBasePath});

  String? lastAssetPackName;
  String? lastFileExtension;
  final String? assetBasePath;

  @override
  Future<void> fetch(String assetPackName) async {
    // Simulate a successful fetch call.
  }

  @override
  Future<void> fetchAssetPackState(String assetPackName) async {
    // Simulate fetching asset pack state.
  }

  @override
  void getAssetPackStatus(Function(Map<String, dynamic>) onUpdate) {
    // Simulate setting a listener.
  }

  @override
  Future<String?> getAssetPackPath({
    required String assetPackName,
    required String fileExtension,
  }) async {
    lastAssetPackName = assetPackName;
    lastFileExtension = fileExtension;

    if (assetBasePath == null) {
      return null;
    }

    // Simulate fetching asset pack state.
    return '$assetBasePath/$assetPackName';
  }

  @override
  Future<Uint8List?> getInstallTimeAssetBytes(String relativeAssetPath) async {
    return null;
    // Simulate fetching asset pack state.
  }

  @override
  Stream<StatusMap> watchAssetPackStatus(String assetPackName) {
    return const Stream<StatusMap>.empty();
  }
}

void main() {
  final AssetDeliveryPlatform initialPlatform = AssetDeliveryPlatform.instance;

  test('$MethodChannelAssetDelivery is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAssetDelivery>());
  });

  test('getPlatformVersion', () async {
    //AssetDelivery assetDeliveryPlugin = AssetDelivery();
    MockAssetDeliveryPlatform fakePlatform = MockAssetDeliveryPlatform();
    AssetDeliveryPlatform.instance = fakePlatform;
  });

  // TODO: This test does not work
  test(
    'getAssetPackPath returns Android asset path with pack name appended',
    () async {
      const assetPackName = 'android_pack';
      const fileExtension = 'png';
      const assetBasePath = '/data/user/0/com.example.app/files/assetpacks';

      final mockPlatform = MockAssetDeliveryPlatform(
        assetBasePath: assetBasePath,
      );

      AssetDeliveryPlatform.instance = mockPlatform;

      final assetPath = await AssetDelivery.getAssetPackPath(
        assetPackName: assetPackName,
        fileExtension: fileExtension,
      );

      expect(mockPlatform.lastAssetPackName, assetPackName);
      expect(mockPlatform.lastFileExtension, fileExtension);
      expect(assetPath, '$assetBasePath/$assetPackName');
    },
  );

  test('fetch method', () async {
    const assetPackName = 'samplePack';
    await AssetDelivery.fetch(assetPackName);
    // No exceptions should occur for a successful call.
  });

  test('fetchAssetPackState method', () async {
    const assetPackName = 'samplePack';
    await AssetDelivery.fetchAssetPackState(assetPackName);
    // Again, just verifying that the method runs without exception.
  });

  test('getAssetPackStatus', () {
    callback(Map<String, dynamic> data) {
      // Handle data here in the listener callback.
    }
    AssetDelivery.getAssetPackStatus(callback);
    // This should complete without error.
  });
}
