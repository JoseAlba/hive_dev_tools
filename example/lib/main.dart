import 'dart:convert';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_service.dart';

void main() async {
  await Hive.initFlutter();
  await HiveService.getBoxData();

  await Hive.openBox(HiveBoxes.box1);
  await Hive.openBox(HiveBoxes.box2);

  runApp(ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final box = Hive.box(HiveBoxes.box1);
  late final PlayerCacheDatasource datasource;
  Player? player;

  @override
  void initState() {
    super.initState();
    datasource = PlayerCacheDatasource(box: box);
    final result = datasource.get();
    result.fold((_) => player = null, (player) => this.player = player);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                player == null ? 'Player is null' : 'Player ${player!.name}',
              ),
              TextButton(
                onPressed: () {
                  final result = datasource.get();
                  result.fold(
                    (_) => player = null,
                    (player) => this.player = player,
                  );
                  setState(() {});
                },
                child: Text('get'),
              ),
              for (Player p in Player.values) ...[
                TextButton(
                  onPressed: () async {
                    await datasource.save(p);
                    final result = datasource.get();
                    result.fold(
                      (_) => player = null,
                      (player) => this.player = player,
                    );
                    setState(() {});
                  },
                  child: Text('set ${p.name}'),
                ),
              ],
              TextButton(
                onPressed: () {
                  datasource.box.clear();
                  player = null;
                  setState(() {});
                },
                child: Text('clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Player {
  warrior,
  dragon,
  none;

  static Player fromJson(String json) {
    return Player.values.firstWhere(
      (player) => player.name == json,
      orElse: () => Player.none,
    );
  }

  String toJson() {
    return name;
  }
}

class PlayerCacheDatasource {
  const PlayerCacheDatasource({required this.box});

  final Box box;

  Either<Exception, Player> get() {
    try {
      final json = box.get(HiveKeys.player);
      if (json != null) {
        final player = Player.fromJson(jsonDecode(json));
        return Right(player);
      } else {
        return Left(Exception('No cache found'));
      }
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, void>> save(Player player) async {
    try {
      final json = jsonEncode(player.toJson());
      await box.put(HiveKeys.player, json);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}

class HiveBoxes {
  const HiveBoxes._();

  static const box1 = 'box1';
  static const box2 = 'box2';
}

class HiveKeys {
  const HiveKeys._();

  static const player = 'player';
}
