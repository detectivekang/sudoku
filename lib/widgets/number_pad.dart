import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onHintPressed;
  final bool isHintAvailable;
  final List<List<int>> board;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
    required this.onHintPressed,
    required this.isHintAvailable,
    required this.board,
  });

  bool _isNumberAvailable(int number) {
    int count = 0;
    for (var row in board) {
      count += row.where((cell) => cell == number).length;
    }
    return count < 9;
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = ResponsiveSize.getNumberPadButtonSize(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          if (index == 9) {
            return SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                onPressed: isHintAvailable ? onHintPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHintAvailable ? Colors.orange : Colors.grey,
                ),
                child: const Icon(Icons.lightbulb),
              ),
            );
          }
          final number = index + 1;
          final isAvailable = _isNumberAvailable(number);
          return SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: ElevatedButton(
              onPressed: isAvailable ? () => onNumberSelected(number) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? null : Colors.grey[300],
              ),
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 24,
                  color: isAvailable ? null : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 