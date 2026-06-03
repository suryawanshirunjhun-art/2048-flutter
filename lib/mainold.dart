import 'package:flutter/material.dart';
import 'game_logic.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GameScreen(), debugShowCheckedModeBanner: false);
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameLogic game = GameLogic();
  bool canMove = true;

  // ✅ NEW: swipe tracking
  Offset? startPosition;
  Offset? endPosition;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    setState(() {
      game = GameLogic();
      game.addRandomTile();
      game.addRandomTile();
    });
  }

  void makeMove(String dir) {
    if (!canMove) return;

    setState(() {
      if (!game.hasWon() && !game.gameOver()) {
        game.makeMove(dir);
      }
    });

    canMove = false;
    Future.delayed(Duration(milliseconds: 150), () {
      canMove = true;
    });
  }

  Color getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.grey[200]!;
      case 4:
        return Color.fromARGB(255, 164, 223, 204);
      case 8:
        return Color.fromARGB(255, 122, 192, 183);
      case 16:
        return Color.fromARGB(255, 86, 147, 142);
      case 32:
        return Color.fromARGB(255, 71, 115, 116);
      case 64:
        return Color.fromARGB(255, 48, 71, 72);
      case 128:
        return Colors.yellow[600]!;
      case 256:
        return Colors.yellow[700]!;
      case 512:
        return Colors.amber[700]!;
      case 1024:
        return Colors.amber[800]!;
      case 2048:
        return Colors.amber[900]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGameOver = game.gameOver();
    bool hasWon = game.hasWon();

    return Scaffold(
      appBar: AppBar(
        title: Text("2048"),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: startNewGame),
        ],
      ),
      body: GestureDetector(
        // ✅ NEW SWIPE LOGIC
        onPanStart: (details) {
          startPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          endPosition = details.localPosition;
        },
        onPanEnd: (details) {
          if (startPosition == null || endPosition == null) return;

          double dx = endPosition!.dx - startPosition!.dx;
          double dy = endPosition!.dy - startPosition!.dy;

          const threshold = 60; // 🔥 adjust if needed

          if (dx.abs() > dy.abs()) {
            if (dx > threshold)
              makeMove("right");
            else if (dx < -threshold)
              makeMove("left");
          } else {
            if (dy > threshold)
              makeMove("down");
            else if (dy < -threshold)
              makeMove("up");
          }

          startPosition = null;
          endPosition = null;
        },

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Score: ${game.score}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                width: 320,
                height: 320,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 16,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (context, index) {
                    int row = index ~/ 4;
                    int col = index % 4;
                    int val = game.board[row][col];

                    return Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: getTileColor(val),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          val == 0 ? "" : val.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: val <= 4 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 20),

            if (hasWon)
              Text(
                "YOU WON!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

            if (isGameOver && !hasWon)
              Text(
                "GAME OVER!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

            SizedBox(height: 20),
            Text("Swipe to move tiles"),
          ],
        ),
      ),
    );
  }
}
