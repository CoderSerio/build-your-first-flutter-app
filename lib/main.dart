import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build 类似于 constructor
  @override
  Widget build(BuildContext context) {
    // 通过 ChangeNotifierProvider 注册一个“全局状态管理”
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var currentWord = WordPair.random();

  void getNextWord() {
    currentWord = WordPair.random();
    // MyApp中，create: (context) => MyAppState() 与这里发生了关联
    // 可以使用 notifyListeners 来让当前 class 的 ChangeNotifierProvider 的节点被通知到更新状态
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 这个就是一个 "store"
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          Text('A random AWESOME idea:'),
          Text(appState.currentWord.asLowerCase),
          // flutter 这样添加按钮
          ElevatedButton(
              onPressed: () {
                print("haha");
                appState.getNextWord();
              },
              child: Text("点一下就会爆炸"))
        ],
      ),
    );
  }
}
