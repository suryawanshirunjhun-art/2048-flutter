import 'dart:math';

class GameLogic {
  int score = 0;
  int size = 4;
  List<List<int>> board = List.generate(4, (_) => List.generate(4, (_) => 0));

  // ---------------- Movement ----------------
  void moveLeft() {
    for (int i = 0; i < size; i++) {
      List<int> newRow = List.filled(size, 0);
      int index = 0;

      for (int j = 0; j < size; j++) {
        if (board[i][j] != 0) newRow[index++] = board[i][j];
      }

      for (int j = 0; j < size - 1; j++) {
        if (newRow[j] != 0 && newRow[j] == newRow[j + 1]) {
          newRow[j] *= 2;
          score += newRow[j];
          newRow[j + 1] = 0;
        }
      }

      List<int> finalRow = List.filled(size, 0);
      index = 0;
      for (int j = 0; j < size; j++) {
        if (newRow[j] != 0) finalRow[index++] = newRow[j];
      }

      board[i] = finalRow;
    }
  }

  void reverseRow(int i) {
    for (int j = 0; j < size ~/ 2; j++) {
      int temp = board[i][j];
      board[i][j] = board[i][size - 1 - j];
      board[i][size - 1 - j] = temp;
    }
  }

  void moveRight() {
    for (int i = 0; i < size; i++) reverseRow(i);
    moveLeft();
    for (int i = 0; i < size; i++) reverseRow(i);
  }

  void transpose() {
    for (int i = 0; i < size; i++) {
      for (int j = i + 1; j < size; j++) {
        int temp = board[i][j];
        board[i][j] = board[j][i];
        board[j][i] = temp;
      }
    }
  }

  void moveUp() {
    transpose();
    moveLeft();
    transpose();
  }

  void moveDown() {
    transpose();
    moveRight();
    transpose();
  }

  // ---------------- Tile Logic ----------------
  void addRandomTile() {
    if (isFull()) return;

    Random rand = Random();

    while (true) {
      int r = rand.nextInt(size);
      int c = rand.nextInt(size);

      if (board[r][c] == 0) {
        int randomNumber = rand.nextInt(10);

        if (randomNumber == 0) {
          board[r][c] = 4; // 10% chance
        } else {
          board[r][c] = 2; // 90% chance
        }

        break;
      }
    }
  }

  bool isFull() {
    for (var row in board) {
      for (var val in row) if (val == 0) return false;
    }
    return true;
  }

  // ---------------- Copy & Compare ----------------
  List<List<int>> copyBoard() {
    return board.map((row) => List<int>.from(row)).toList();
  }

  bool isSame(List<List<int>> b1, List<List<int>> b2) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (b1[i][j] != b2[i][j]) return false;
      }
    }
    return true;
  }

  void makeMove(String dir) {
    var oldBoard = copyBoard();

    switch (dir) {
      case "left":
        moveLeft();
        break;
      case "right":
        moveRight();
        break;
      case "up":
        moveUp();
        break;
      case "down":
        moveDown();
        break;
    }

    if (!isSame(oldBoard, board)) addRandomTile();
  }

  // ---------------- Win / Game Over ----------------
  bool hasWon() {
    for (var row in board) {
      if (row.contains(2048)) return true;
    }
    return false;
  }

  bool canMerge() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (i < size - 1 && board[i][j] == board[i + 1][j]) return true;
        if (j < size - 1 && board[i][j] == board[i][j + 1]) return true;
      }
    }
    return false;
  }

  bool gameOver() {
    return isFull() && !canMerge();
  }
}
