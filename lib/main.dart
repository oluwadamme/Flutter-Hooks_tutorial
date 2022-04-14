import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hooks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// Stream<String> getTime() => Stream.periodic(
//     const Duration(seconds: 1), (_) => DateTime.now().toIso8601String());

const url =
    'https://images.pexels.com/photos/2116388/pexels-photo-2116388.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500';
const imageHeight = 300.0;

enum Action {
  rotateLeft,
  rotateRight,
  moreVisible,
  lessVisible,
}

@immutable
class State {
  final double rotationDeg;
  final double alpha;

  const State({required this.rotationDeg, required this.alpha});

  const State.zero()
      : rotationDeg = 0.0,
        alpha = 1.0;

  State rotateRight() => State(
        alpha: alpha,
        rotationDeg: rotationDeg + 10.0,
      );
  State rotateLeft() => State(
        alpha: alpha,
        rotationDeg: rotationDeg - 10.0,
      );
  State increaseAlpha() => State(
        alpha: min(alpha + 0.1, 1.0),
        rotationDeg: rotationDeg,
      );
  State decreaseAlpha() => State(
        alpha: max(alpha - 0.1, 0.0),
        rotationDeg: rotationDeg,
      );
}

State reducer(State oldState, Action? action) {
  switch (action) {
    case Action.rotateLeft:
      return oldState.rotateLeft();
    case Action.rotateRight:
      return oldState.rotateRight();
    case Action.moreVisible:
      return oldState.increaseAlpha();
    case Action.lessVisible:
      return oldState.decreaseAlpha();
    case null:
      return oldState;
  }
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useReducer<State, Action?>(reducer,
        initialState: const State.zero(), initialAction: null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is home'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  store.dispatch(Action.rotateLeft);
                },
                child: const Text('Rotate Left'),
              ),
              TextButton(
                onPressed: () {
                  store.dispatch(Action.rotateRight);
                },
                child: const Text('Rotate Right'),
              ),
              TextButton(
                onPressed: () {
                  store.dispatch(Action.moreVisible);
                },
                child: const Text('More Visible'),
              ),
              TextButton(
                onPressed: () {
                  store.dispatch(Action.lessVisible);
                },
                child: const Text('Less Visible'),
              )
            ],
          ),
          const SizedBox(
            height: 100,
          ),
          Opacity(
            opacity: store.state.alpha,
            child: RotationTransition(
                turns: AlwaysStoppedAnimation(store.state.rotationDeg / 360.0),
                child: Image.network(
                  url,
                  height: 400,
                )),
          ),
        ],
      ),
    );
  }
}

class FadeAnimation extends StatelessWidget {
  const FadeAnimation({
    Key? key,
    required this.size,
    required this.opacity,
    required this.controller,
  }) : super(key: key);

  final AnimationController size;
  final AnimationController opacity;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: size,
          axis: Axis.vertical,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: opacity,
            child: Image.network(
              url,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: controller,
            itemBuilder: ((context, index) {
              return ListTile(
                title: Text('Person ${index + 1}'),
              );
            }),
            itemCount: 100,
          ),
        )
      ],
    );
  }
}

// this extension is to prevent null value
extension CompactMap<T> on Iterable<T?> {
  Iterable<T> compactMap<E>([E? Function(T?)? transform]) =>
      map(transform ?? (e) => e).where((e) => e != null).cast();
}

class CountDown extends ValueNotifier<int> {
  late StreamSubscription sub;
  CountDown({required int from}) : super(from) {
    sub = Stream.periodic(const Duration(seconds: 1), (v) => from - v)
        .takeWhile((value) => value >= 0)
        .listen((value) {
      this.value = value;
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

extension Normalize on num {
  num normalized(
    num selfRangeMin,
    num selfRangeMax, [
    num normalizedRangeMin = 0.0,
    num normalizedRangeMax = 1.0,
  ]) =>
      (normalizedRangeMax - normalizedRangeMin) *
          ((this - selfRangeMin) / (selfRangeMax - selfRangeMin)) +
      normalizedRangeMin;
}
