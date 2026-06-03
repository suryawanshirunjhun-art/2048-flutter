// lib/main.dart
import 'package:flutter/material.dart';
import 'game_logic.dart';

void main() {
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
      home: SplashPage(),
    );
  }
}

// ================= SPLASH / HOME =================

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scale = Tween<double>(begin: 0.8, end: 1.1).animate(_controller);

    Future.delayed(Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  void goToGame() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => GamePage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF44F),
      body: GestureDetector(
        onTap: goToGame,
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '2048',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to Start',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= GAME PAGE =================

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameLogic game = GameLogic();

  @override
  void initState() {
    super.initState();
    game.addRandomTile();
    game.addRandomTile();
  }

  void handleSwipe(String direction) {
    setState(() {
      game.makeMove(direction);
      if (game.hasWon()) {
        _showEndDialog("You Win!");
      } else if (game.gameOver()) {
        _showEndDialog("Game Over");
      }
    });
  }

  void restartGame() {
    setState(() {
      game = GameLogic();
      game.addRandomTile();
      game.addRandomTile();
    });
  }

  void _showEndDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: Text("Restart"),
            ),
          ),
        ],
      ),
    );
  }

  Color getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color.fromARGB(255, 237, 238, 214);
      case 4:
        return const Color.fromARGB(255, 236, 245, 177);
      case 8:
        return const Color.fromRGBO(224, 243, 160, 1);
      case 16:
        return const Color.fromARGB(255, 217, 252, 119);
      case 32:
        return const Color.fromARGB(255, 215, 252, 93);
      case 64:
        return const Color.fromARGB(255, 194, 241, 85);
      case 128:
        return const Color.fromARGB(255, 197, 234, 49);
      case 256:
        return const Color.fromARGB(255, 174, 215, 25);
      case 512:
        return const Color.fromRGBO(150, 197, 7, 1);
      case 1024:
        return const Color.fromARGB(255, 150, 178, 11);
      case 2048:
        return const Color.fromARGB(255, 147, 174, 13);
      default:
        return const Color.fromARGB(255, 154, 240, 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    double boardSize = MediaQuery.of(context).size.width - 32;
    double tileSize = boardSize / 4 - 12;

    return Scaffold(
      appBar: AppBar(
        title: Text('2048 Premium'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 131, 232, 78),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) handleSwipe("up");
          if (details.primaryVelocity! > 0) handleSwipe("down");
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) handleSwipe("left");
          if (details.primaryVelocity! > 0) handleSwipe("right");
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: ${game.score}',
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: restartGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          149,
                          222,
                          70,
                        ),
                      ),
                      child: Text("Restart"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: boardSize,
                height: boardSize,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (j) {
                            return Container(
                              width: tileSize,
                              height: tileSize,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (j) {
                            int val = game.board[i][j];
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: tileSize,
                              height: tileSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: val == 0
                                    ? Colors.grey.shade700
                                    : getTileColor(val),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                val == 0 ? '' : '$val',
                                style: TextStyle(
                                  fontSize: tileSize / 2.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // ✅ ONLY CHANGE
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
