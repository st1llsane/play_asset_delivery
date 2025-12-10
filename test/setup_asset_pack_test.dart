// ignore_for_file: avoid_print

/// Тесты для команды setup_asset_pack.dart
///
/// Данные тесты проверяют функциональность команды создания asset
/// pack'ов для Android Play Asset Delivery.
///
/// Запуск тестов:
/// ```
/// flutter test test/setup_asset_pack_test.dart
/// ```
///
/// Или запуск всех тестов:
/// ```
/// flutter test
/// ```
///
/// Тесты покрывают:
/// - Проверку ошибок при отсутствии аргументов
/// - Проверку ошибок при неверном типе доставки
/// - Создание asset pack с типом доставки on-demand (по умолчанию)
/// - Создание asset pack с типом доставки install-time
/// - Создание asset pack с типом доставки fast-follow
/// - Проверку на дублирование asset pack'ов
/// - Обновление app/build.gradle с настройками assetPacks
library;

import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('setup_asset_pack command tests', () {
    late Directory tempDir;
    late String originalDir;

    setUp(() async {
      // Сохраняем текущую директорию
      originalDir = Directory.current.path;

      // Создаем временную директорию для тестов
      tempDir = await Directory.systemTemp.createTemp('asset_pack_test_');
      Directory.current = tempDir;

      // Создаем минимальную структуру Flutter проекта
      final androidDir = Directory('${tempDir.path}/android');
      await androidDir.create(recursive: true);

      final appDir = Directory('${tempDir.path}/android/app');
      await appDir.create(recursive: true);

      // Создаем settings.gradle
      final settingsFile = File('${tempDir.path}/android/settings.gradle');
      await settingsFile.writeAsString('''
pluginManagement {
    repositories {
        google()
        mavenCentral()
    }
}

include ":app"
''');

      // Создаем build.gradle для app
      final buildGradleFile = File('${tempDir.path}/android/app/build.gradle');
      await buildGradleFile.writeAsString('''
android {
    namespace = "com.example.test"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.test"
        minSdk = 21
        targetSdk = 34
    }
}
''');
    });

    tearDown(() async {
      // Возвращаемся в исходную директорию
      Directory.current = originalDir;

      // Удаляем временную директорию
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should show error when no arguments provided', () async {
      final result = await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
      ], workingDirectory: originalDir);

      expect(result.exitCode, equals(1));
      expect(
        result.stdout.toString(),
        contains('Please provide an asset pack name'),
      );
      expect(result.stdout.toString(), contains('Usage:'));
    });

    test('should show error for invalid delivery type', () async {
      final result = await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
        'test_pack',
        'invalid-type',
      ], workingDirectory: originalDir);

      expect(result.exitCode, equals(1));
      expect(result.stdout.toString(), contains('Invalid delivery type'));
      expect(
        result.stdout.toString(),
        contains('Allowed types are: on-demand, install-time, fast-follow'),
      );
    });

    test(
      'should create asset pack with on-demand delivery type (default)',
      () async {
        final result = await Process.run('dart', [
          '$originalDir/bin/setup_asset_pack.dart',
          'my_assets',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString(),
          contains('Added "include \':my_assets\'" to settings.gradle'),
        );
        expect(
          result.stdout.toString(),
          contains('Created asset pack directory'),
        );
        expect(
          result.stdout.toString(),
          contains('Created build.gradle.kts for my_assets'),
        );
        expect(
          result.stdout.toString(),
          contains('Created AndroidManifest.xml for my_assets'),
        );

        // Проверяем, что директория создана
        final assetPackDir = Directory('${tempDir.path}/android/my_assets');
        expect(await assetPackDir.exists(), isTrue);

        // Проверяем build.gradle.kts
        final buildGradle = File(
          '${tempDir.path}/android/my_assets/build.gradle.kts',
        );
        expect(await buildGradle.exists(), isTrue);
        final buildGradleContent = await buildGradle.readAsString();
        expect(buildGradleContent, contains('packName.set("my_assets")'));
        expect(buildGradleContent, contains('deliveryType.set("on-demand")'));

        // Проверяем AndroidManifest.xml
        final manifest = File(
          '${tempDir.path}/android/my_assets/manifest/AndroidManifest.xml',
        );
        expect(await manifest.exists(), isTrue);
        final manifestContent = await manifest.readAsString();
        expect(manifestContent, contains('split="my_assets"'));
        expect(manifestContent, contains('<dist:on-demand/>'));
      },
    );

    test('should create asset pack with install-time delivery type', () async {
      final result = await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
        'install_assets',
        'install-time',
      ], workingDirectory: tempDir.path);

      expect(result.exitCode, equals(0));

      // Проверяем build.gradle.kts
      final buildGradle = File(
        '${tempDir.path}/android/install_assets/build.gradle.kts',
      );
      final buildGradleContent = await buildGradle.readAsString();
      expect(buildGradleContent, contains('deliveryType.set("install-time")'));

      // Проверяем AndroidManifest.xml
      final manifest = File(
        '${tempDir.path}/android/install_assets/manifest/AndroidManifest.xml',
      );
      final manifestContent = await manifest.readAsString();
      expect(manifestContent, contains('<dist:install-time/>'));
    });

    test('should create asset pack with fast-follow delivery type', () async {
      final result = await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
        'fast_assets',
        'fast-follow',
      ], workingDirectory: tempDir.path);

      expect(result.exitCode, equals(0));

      // Проверяем build.gradle.kts
      final buildGradle = File(
        '${tempDir.path}/android/fast_assets/build.gradle.kts',
      );
      final buildGradleContent = await buildGradle.readAsString();
      expect(buildGradleContent, contains('deliveryType.set("fast-follow")'));

      // Проверяем AndroidManifest.xml
      final manifest = File(
        '${tempDir.path}/android/fast_assets/manifest/AndroidManifest.xml',
      );
      final manifestContent = await manifest.readAsString();
      expect(manifestContent, contains('<dist:fast-follow/>'));
    });

    test('should not create duplicate asset pack', () async {
      // Создаем asset pack первый раз
      await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
        'duplicate_test',
      ], workingDirectory: tempDir.path);

      // Пытаемся создать еще раз
      final result = await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
        'duplicate_test',
      ], workingDirectory: tempDir.path);

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        contains('already exists in settings.gradle'),
      );
      expect(
        result.stdout.toString(),
        contains('Asset pack directory "duplicate_test" already exists'),
      );
    });

    test('should update app/build.gradle with assetPacks', () async {
      final result = await Process.run('dart', [
        '$originalDir/bin/setup_asset_pack.dart',
        'gradle_test',
      ], workingDirectory: tempDir.path);

      expect(result.exitCode, equals(0));

      // Проверяем, что app/build.gradle обновлен
      final appBuildGradle = File('${tempDir.path}/android/app/build.gradle');
      final content = await appBuildGradle.readAsString();
      expect(content, contains('assetPacks'));
      expect(content, contains(':gradle_test'));
    });
  });
}
