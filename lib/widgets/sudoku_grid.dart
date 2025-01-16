import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class SudokuGrid extends StatefulWidget {
  final List<List<int>> board;
  final List<List<int>> originalBoard;
  final int selectedRow;
  final int selectedCol;
  final Function(int, int) onCellTap;

  const SudokuGrid({
    super.key,
    required this.board,
    required this.originalBoard,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
  });

  @override
  State<SudokuGrid> createState() => _SudokuGridState();
}

class _SudokuGridState extends State<SudokuGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _lastSelectedRow;
  int? _lastSelectedCol;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SudokuGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRow != oldWidget.selectedRow || 
        widget.selectedCol != oldWidget.selectedCol) {
      _lastSelectedRow = widget.selectedRow;
      _lastSelectedCol = widget.selectedCol;
      _controller.forward(from: 0.0);
    }
  }

  bool _isInCross(int row, int col) {
    if (_lastSelectedRow == null || _lastSelectedCol == null) return false;
    return row == _lastSelectedRow || col == _lastSelectedCol;
  }

  bool _isInDiagonal(int row, int col) {
    if (widget.selectedRow == -1 || widget.selectedCol == -1) return false;
    return (row - widget.selectedRow).abs() == (col - widget.selectedCol).abs();
  }

  bool _isSameNumber(int row, int col) {
    if (widget.selectedRow == -1 || widget.selectedCol == -1) return false;
    final selectedNumber = widget.board[widget.selectedRow][widget.selectedCol];
    return selectedNumber != 0 && widget.board[row][col] == selectedNumber;
  }

  Color _getCellColor(int row, int col) {
    if (row == widget.selectedRow && col == widget.selectedCol) {
      return Colors.lightBlue[100]!;
    } else if (_isSameNumber(row, col)) {
      return Colors.lightBlue[50]!;
    } else if (_isInCross(row, col)) {
      return Color.lerp(
        Colors.yellow[100]!,
        Colors.white,
        _animation.value,
      )!;
    } else if (_isInDiagonal(row, col)) {
      return Colors.grey[100]!;
    } else if (widget.originalBoard[row][col] != 0) {
      return Colors.grey[200]!;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = ResponsiveSize.getSudokuGridSize(context);
    final cellSize = gridSize / 9;

    return Center(
      child: Container(
        width: gridSize,
        height: gridSize,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            if (widget.selectedRow != -1 && widget.selectedCol != -1)
              CustomPaint(
                size: Size(gridSize, gridSize),
                painter: GuidelinePainter(
                  selectedRow: widget.selectedRow,
                  selectedCol: widget.selectedCol,
                  cellSize: cellSize,
                ),
              ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, index) {
                    final row = index ~/ 9;
                    final col = index % 9;

                    return GestureDetector(
                      onTap: () => widget.onCellTap(row, col),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
                            ),
                            bottom: BorderSide(
                              width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
                            ),
                          ),
                          color: _getCellColor(row, col),
                        ),
                        child: Center(
                          child: Text(
                            widget.board[row][col] != 0 
                                ? widget.board[row][col].toString() 
                                : '',
                            style: TextStyle(
                              fontSize: cellSize * 0.6,
                              fontWeight: widget.originalBoard[row][col] != 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: widget.originalBoard[row][col] != 0
                                  ? Colors.black
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GuidelinePainter extends CustomPainter {
  final int selectedRow;
  final int selectedCol;
  final double cellSize;

  GuidelinePainter({
    required this.selectedRow,
    required this.selectedCol,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 대각선 그리기
    final selectedX = selectedCol * cellSize;
    final selectedY = selectedRow * cellSize;

    // 왼쪽 위에서 오른쪽 아래로
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );

    // 오른쪽 위에서 왼쪽 아래로
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}