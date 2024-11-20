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

  var favorites = <WordPair>{};

  void toggleFavorite() {
    if (favorites.contains(currentWord)) {
      // 不得不说，这个 remove 方法很先进啊（bushi
      favorites.remove(currentWord);
    } else {
      favorites.add(currentWord);
    }
    // 最后记得要通知更新
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 这个就是一个 "store"
    var appState = context.watch<MyAppState>();
    var word = appState.currentWord;
    var isContained = appState.favorites.contains(word);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('A random AWESOME idea:'),
            SizedBox(height: 10),
            BigCard(word: word),
            // flutter 这样添加按钮

            Row(
              // 可以和之前一样，用 mainAxisAlignment 实现水平居中
              // mainAxisAlignment: MainAxisAlignment.center,
              // 但是为了练习，我们用 mainAxisSize 实现
              // 它相当于把 div 变成了 span （但是为啥能居中？其实我没看懂
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    // 当然，其实全局（可以直接访问）还有专门的 Icons，用 Icons.favorite 就能访问
                    child: Text(isContained ? "❤️爱了!" : "💔不爱了!")),
                SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () {
                      print("haha");
                      appState.getNextWord();
                    },
                    child: Text("换一个!")),
              ],
            )
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
