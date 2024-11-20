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

  void removeFavoriteWord(word) {
    favorites.remove(word);
    notifyListeners();
  }
}

// ...

class MyHomePage extends StatefulWidget {
  // _开头表示 private，其私有性质将由编译器保障
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        // 是很先进的页面占位符
        page = FavoriteWordsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // LayoutBuilder 的特点是，每次视口尺寸发生变化时（包括屏幕旋转），系统都会调用 LayoutBuilder 的 build 函数
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            // 安全区说的其实就是不会被设备的物理形状影响的部分
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600, // 是否隐藏 label
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                // 这里其实就类似于 onChange
                onDestinationSelected: (value) {
                  print('selected: $value');
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // Expanded Widget 就是 flex: 1
            Expanded(
              child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page),
            ),
          ],
        ),
      );
    });
  }
}

class FavoriteWordsPage extends StatelessWidget {
  const FavoriteWordsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return ListView(
      children: appState.favorites
          .map((text) => (Row(children: [
                Expanded(
                  child: BigCard(
                    wordPairs: text,
                    operationButton: ElevatedButton(
                      onPressed: () {
                        appState.removeFavoriteWord(text);
                      },
                      child: Icon(Icons.delete_forever_sharp),
                    ),
                  ),
                ),
                // ElevatedButton.icon(
                //   onPressed: () {},
                //   icon: Icon(Icons.delete_forever_sharp),
                //   label: Text('remove'),
                // )
              ])))
          .toList(),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var wordPairs = appState.currentWord;

    IconData icon;
    if (appState.favorites.contains(wordPairs)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(wordPairs: wordPairs),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNextWord();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...
class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.wordPairs, this.operationButton});

  final Widget? operationButton;
  final WordPair wordPairs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Expanded(
            child: Text(
              wordPairs.asLowerCase, style: style,
              // 这里我们其实拿到的是一个 word pairs，我们可以这样来做一个格式化
              // 为什么要这样做呢，是因为 flutter 默认支持无障碍
              // 如果不这样分割单词的话，可能会让文本被错误发音
              semanticsLabel: "${wordPairs.first} ${wordPairs.second}",
            ),
          ),
          if (operationButton != null) ...[
            operationButton!,
          ]
        ]),
      ),
    );
  }
}
