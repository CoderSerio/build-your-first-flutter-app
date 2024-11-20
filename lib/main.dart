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
          colorScheme: ColorScheme.fromSeed(
              seedColor: /*Colors.deepOrange*/ Color(0xFF00FF00)),
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
    var word = appState.currentWord;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('A random AWESOME idea:'),
            SizedBox(height: 10),
            BigCard(word: word),
            // flutter 这样添加按钮
            ElevatedButton(
                onPressed: () {
                  print("haha");
                  appState.getNextWord();
                },
                child: Text("点一下就会爆炸!"))
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.word,
  });

  final WordPair word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          word.asLowerCase, style: style,
          // 这里我们其实拿到的是一个 word pairs，我们可以这样来做一个格式化
          // 为什么要这样做呢，是因为 flutter 默认支持无障碍
          // 如果不这样分割单词的话，可能会让文本被错误发音
          semanticsLabel: "${word.first} ${word.second}",
        ),
      ),
    );
  }
}
