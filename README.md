# 🐝 Hive DevTool for Dart DevTools
A Flutter package that integrates Hive with Dart DevTools, allowing developers to conveniently inspect and visualize Hive boxes and cached data directly within their development workflow.

## Features

- View all active Hive boxes in Dart DevTools
- Explore stored key-value pairs in real-time
- Improve debugging efficiency for apps using Hive for local storage

## Installation

```yaml
dev_dependencies:
  hive_dev_tools: 0.0.1
```

Create a file called `hive_service.dart`

Add the following code:

```dart
import 'package:hive_dev_tools/services/service_manager_service.dart';
import 'package:vm_service/vm_service.dart' hide VmService;

class HiveService {
  const HiveService._();

  static final _boxDataExpression = 'HiveService.boxData';
  static final _getBoxDataExpression = 'HiveService.getBoxData()';

  static Future<void> evaluateGetBoxDataExpression() async {
    await ServiceManagerService.evalInRunningApp(_getBoxDataExpression);
  }

  static Future<Map<String, Map<String, String>>> fetchBoxData() async {
    final hiveObj = await _getHiveAppObj();

    final hiveBoxes = await _getHiveBoxes(hiveObj!);

    final Map<String, Map<String, String>> hiveData = {};
    for (var key in hiveBoxes.keys) {
      hiveData[key] = await _getHiveBoxData(hiveBoxes[key]);
    }
    return hiveData;
  }

  static Future<Obj?> _getHiveAppObj() async {
    final response = await ServiceManagerService.evalInRunningApp(
      _boxDataExpression,
    );
    final objectId = (response as InstanceRef).id!;
    return await ServiceManagerService.getObject(objectId);
  }

  static Future<Map<String, Obj?>> _getHiveBoxes(Obj? obj) async {
    final Map<String, Obj?> map = {};
    if (obj == null) {
      return map;
    }

    final List<dynamic> associations = obj.toJson()['associations'];
    for (final association in associations) {
      if (association is Map<String, dynamic> &&
          association.containsKey('key') &&
          association.containsKey('value')) {
        final dynamic key = association['key'];
        final dynamic value = association['value'];

        // Process the key
        String? keyString;
        if (key is Map<String, dynamic> && key.containsKey('valueAsString')) {
          keyString = key['valueAsString'] as String;
        } else {
          // Handle cases where the key is not a simple string
          keyString = key.toString();
        }

        // Process the value
        final valueId = value['id'] as String;
        final valueObj = await ServiceManagerService.getObject(valueId);
        map[keyString] = valueObj;
      }
    }
    return map;
  }

  static Future<Map<String, String>> _getHiveBoxData(Obj? obj) async {
    final Map<String, String> map = {};
    if (obj == null) {
      return map;
    }

    final List<dynamic> associations = obj.toJson()['associations'];
    for (final association in associations) {
      if (association is Map<String, dynamic> &&
          association.containsKey('key') &&
          association.containsKey('value')) {
        final dynamic key = association['key'];
        final dynamic value = association['value'];

        // Process the key
        String? keyString;
        if (key is Map<String, dynamic> && key.containsKey('valueAsString')) {
          keyString = key['valueAsString'] as String;
        } else {
          // Handle cases where the key is not a simple string
          keyString = key.toString();
        }

        // Process the value
        final valueString = value['valueAsString'] as String;
        map[keyString] = valueString;
      }
    }
    return map;
  }
}

```

Then add the following command after Hive.initFlutter().
```dart
void main() async {
  await Hive.initFlutter();
  await HiveService.getBoxData();
  
  runApp(ExampleApp());
}
```

Please look at the example app as an example.

## 📢 Contributions
Contributions, issues, and feature requests are welcome!

## 📝 License

This project is licensed under the MIT License. 
