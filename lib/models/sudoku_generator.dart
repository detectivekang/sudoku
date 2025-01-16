import 'dart:math';

class SudokuGenerator {
  final Random _random = Random();

  List<List<int>> generate({required int difficulty}) {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board, 0, 0);
    _removeNumbers(board, difficulty);
    return board;
  }

  bool isValidMove(List<List<int>> board, int row, int col, int num) {
    // 행 검사
    for (int x = 0; x < 9; x++) {
      if (board[row][x] == num) return false;
    }

    // 열 검사
    for (int x = 0; x < 9; x++) {
      if (board[x][col] == num) return false;
    }

    // 3x3 박스 검사
    int boxRow = row - row % 3;
    int boxCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[boxRow + i][boxCol + j] == num) return false;
      }
    }

    return true;
  }

  bool _fillBoard(List<List<int>> board, int row, int col) {
    if (col == 9) {
      row++;
      col = 0;
    }
    if (row == 9) return true;

    if (board[row][col] != 0) {
      return _fillBoard(board, row, col + 1);
    }

    List<int> nums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    nums.shuffle(_random);

    for (int num in nums) {
      if (isValidMove(board, row, col, num)) {
        board[row][col] = num;
        if (_fillBoard(board, row, col + 1)) return true;
        board[row][col] = 0;
      }
    }

    return false;
  }

  void _removeNumbers(List<List<int>> board, int count) {
    int removed = 0;
    while (removed < count) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);
      if (board[row][col] != 0) {
        board[row][col] = 0;
        removed++;
      }
    }
  }
} 