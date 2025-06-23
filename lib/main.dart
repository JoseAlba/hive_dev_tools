import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:hive_dev_tools/services/hive_service.dart';
import 'package:hive_dev_tools/services/vm_service.dart';
import 'package:hive_dev_tools/utils/hive_controller.dart';
import 'package:hive_dev_tools/utils/hive_stateful_widget.dart';

const _width = 300.0;

void main() {
  runApp(const HiveDevToolsApp());
}

class HiveDevToolsApp extends HiveWidget {
  const HiveDevToolsApp({super.key});

  @override
  Widget build(
    BuildContext context,
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  ) {
    return DevToolsExtension(
      child: Column(
        children: [
          TextButton(
            onPressed: () async {
              await HiveService.evaluateGetBoxDataExpression();
              HiveController.hiveData = await HiveService.fetchBoxData();
            },
            child: Text('Get Box Data'),
          ),
          Row(
            children: [
              _GraphElement(text: 'Hive Box'),
              _GraphElement(text: 'Key'),
              _GraphElement(text: 'Value'),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_HiveBoxView(), _HiveBoxKeyView(), _HiveBoxValueView()],
          ),
        ],
      ),
    );
  }
}

class _HiveBoxView extends HiveWidget {
  const _HiveBoxView();

  @override
  Widget build(
    BuildContext context,
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  ) {
    return Column(
      children:
          hiveData.keys.map((key) {
            return InkWell(
              onTap: () {
                HiveController.selectedKey = key;
                VmService.copyStringToClipboard(hiveData[key].toString());
              },
              child: SizedBox(
                width: _width,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color:
                      HiveController.selectedKey == key
                          ? Colors.blue.withValues(alpha: 0.8)
                          : null,
                  child: Text(
                    key,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _HiveBoxKeyView extends HiveWidget {
  const _HiveBoxKeyView();

  @override
  Widget build(
    BuildContext context,
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  ) {
    return Column(
      children:
          hiveData[selectedKey]?.keys.map((key) {
            return _GraphElement(text: key.toString());
          }).toList() ??
          [_NothingGraphElement()],
    );
  }
}

class _HiveBoxValueView extends HiveWidget {
  const _HiveBoxValueView();

  @override
  Widget build(
    BuildContext context,
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  ) {
    return Column(
      children:
          hiveData[selectedKey]?.keys.map((key) {
            return _GraphElement(text: hiveData[selectedKey]![key].toString());
          }).toList() ??
          [_NothingGraphElement()],
    );
  }
}

class _NothingGraphElement extends StatelessWidget {
  const _NothingGraphElement();

  @override
  Widget build(BuildContext context) {
    return _GraphElement(text: 'Nothing');
  }
}

class _GraphElement extends StatelessWidget {
  const _GraphElement({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        VmService.copyStringToClipboard(text);
      },
      child: SizedBox(
        width: _width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
