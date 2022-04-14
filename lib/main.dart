import 'dart:async';

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

// const url =
//     'https://images.pexels.com/photos/2116388/pexels-photo-2116388.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500';

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final dateTime = useStream(getTime());
    // final controller = useTextEditingController();
    // final text = useState('');
    // useEffect(() {
    //   controller.addListener(() {
    //     text.value = controller.text;
    //   });
    //   return null;
    // }, [controller]);

    // final future = useMemoized(() => NetworkAssetBundle(Uri.parse(url))
    //     .load(url)
    //     .then((data) => data.buffer.asUint8List())
    //     .then((data) => Image.memory(data)));

    // final snapshot = useFuture(future);

    final countDown = useMemoized(() => CountDown(from: 20));
    final notifier = useListenable(countDown);
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is home'),
      ),
      body: Text(notifier.value.toString()),
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
