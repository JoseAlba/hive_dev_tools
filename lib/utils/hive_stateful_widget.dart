import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_dev_tools/services/hive_service.dart';
import 'package:hive_dev_tools/services/vm_service.dart';

import 'hive_cache.dart';
import 'hive_controller.dart';

typedef HiveBuilder =
    Widget Function(
      BuildContext context,
      Map<String, Map<String, String>> hiveData,
      String selectedKey,
      Widget? child,
    );

class Hiver extends HiveWidget {
  const Hiver({super.key, required this.builder, this.child});

  final HiveBuilder builder;

  final Widget? child;

  @override
  Widget build(
    BuildContext context,
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  ) {
    return builder(context, hiveData, selectedKey, child);
  }
}

/// A simple widget that provides access to the hive
abstract class HiveWidget extends HiveStatefulWidget {
  const HiveWidget({super.key});

  Widget build(
    BuildContext context,
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  );

  @override
  HiveState<HiveWidget> createState() => _HiveWidgetState();
}

class _HiveWidgetState extends HiveState<HiveWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, hiveData, selectedKey);
  }
}

/// A StatefulWidget that manages hive data
abstract class HiveStatefulWidget extends StatefulWidget {
  const HiveStatefulWidget({super.key});

  @override
  HiveState createState();

  @override
  HiveStatefulElement createElement() => HiveStatefulElement(this);
}

/// Base state class for HiveStatefulWidget that handles hive loading and
/// access
abstract class HiveState<T extends HiveStatefulWidget> extends State<T> {
  late Map<String, Map<String, String>> _hiveData;
  late String _selectedKey;

  /// Gets the currently active hive.
  Map<String, Map<String, String>> get hiveData {
    return HiveController.hiveData ?? _hiveData;
  }

  String get selectedKey {
    return HiveController.selectedKey ?? _selectedKey;
  }

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    // Initialize with cached values if available, otherwise use defaults
    if (HiveCache.hasCache()) {
      _hiveData = HiveCache.cachedHiveData!;
      _selectedKey = HiveCache.cachedSelectedKey!;
    } else {
      _hiveData = _defaultHiveData;
      _selectedKey = _defaultSelectedKey;
    }

    // Add listener for hive override changes
    HiveController.addListener(_handleHiveOverrideChange);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1), _getHive);
    });
  }

  @override
  void dispose() {
    // Remove listener when disposed
    HiveController.removeListener(_handleHiveOverrideChange);
    super.dispose();
  }

  /// Handle hive override changes
  void _handleHiveOverrideChange() {
    if (mounted) {
      setState(() {
        // State is updated when override changes
      });
    }
  }

  /// Loads hive data asynchronously
  Future<void> _getHive() async {
    try {
      await HiveService.evaluateGetBoxDataExpression();
      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   Future.delayed(const Duration(milliseconds: 2));
      // });
      final hiveData = await HiveService.fetchBoxData();
      VmService.copyStringToClipboard(hiveData.toString());
      final selectedKey = hiveData.isNotEmpty ? hiveData.keys.first : '';

      if (!mounted) return;

      // Check if hive values have actually changed
      bool hiveChanged = hiveData != _hiveData || selectedKey != _selectedKey;

      if (hiveChanged) {
        // Update instance variables
        _hiveData = hiveData;
        _selectedKey = selectedKey;

        // Update global cache
        HiveCache.updateCache(_hiveData, selectedKey);

        // Only call setState if there were actual changes
        setState(() {});
      }
    } catch (e) {
      rethrow;
    }
  }

  // Default hive values would be defined here
  static const Map<String, Map<String, String>> _defaultHiveData = {};
  static const String _defaultSelectedKey = '';
}

/// Custom element for HiveStatefulWidget
class HiveStatefulElement extends StatefulElement {
  HiveStatefulElement(super.widget);
}
