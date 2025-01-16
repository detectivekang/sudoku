import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'ranking_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 스도쿠 그리드 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: SudokuBackgroundPainter(),
            ),
          ),
          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.95),
                  const Color(0xFF0D47A1).withOpacity(0.90),
                ],
              ),
            ),
          ),
          // 메인 콘텐츠
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 컨테이너
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.grid_on,
                            size: 72,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '스도쿠',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildMainButton(
                    text: '게임 시작',
                    onPressed: () => _showDifficultyDialog(context),
                    icon: Icons.play_arrow,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMainButton(
                    text: '랭킹',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RankingScreen(),
                        ),
                      );
                    },
                    icon: Icons.emoji_events,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMainButton(
                    text: '도움말',
                    onPressed: () => _showHelpDialog(context),
                    icon: Icons.help_outline,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '난이도 선택',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton(context, '쉬움', 35, Colors.green),
            const SizedBox(height: 12),
            _buildDifficultyButton(context, '보통', 45, Colors.orange),
            const SizedBox(height: 12),
            _buildDifficultyButton(context, '어려움', 55, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, int difficulty, Color color) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(difficulty: difficulty),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      width: 220,
      height: 65,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.help_outline, color: Colors.purple),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '게임 설명',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildHelpSection(
                  icon: Icons.grid_on,
                  title: '게임 규칙',
                  content: '스도쿠는 9x9 격자를 1부터 9까지의 숫자로 채우는 게임입니다.\n'
                      '- 같은 행에 같은 숫자가 있으면 안 됩니다\n'
                      '- 같은 열에 같은 숫자가 있으면 안 됩니다\n'
                      '- 3x3 박스 안에 같은 숫자가 있으면 안 됩니다',
                ),
                const Divider(height: 32),
                _buildHelpSection(
                  icon: Icons.touch_app,
                  title: '조작 방법',
                  content: '1. 빈 칸을 터치하여 선택합니다\n'
                      '2. 하단의 숫자 패드에서 입력할 숫자를 선택합니다\n'
                      '3. 이미 9번 사용된 숫자는 비활성화됩니다',
                ),
                const Divider(height: 32),
                _buildHelpSection(
                  icon: Icons.lightbulb_outline,
                  title: '힌트 시스템',
                  content: '- 게임당 1번의 힌트를 사용할 수 있습니다\n'
                      '- 힌트를 사용하면 선택한 칸에 올바른 숫자가 입력됩니다\n'
                      '- 힌트는 신중하게 사용하세요!',
                ),
                const Divider(height: 32),
                _buildHelpSection(
                  icon: Icons.error_outline,
                  title: '게임 오버',
                  content: '- 3번의 오류가 발생하면 게임이 종료됩니다\n'
                      '- 잘못된 숫자를 입력하면 오류 카운트가 증가합니다\n'
                      '- 남은 기회는 상단에서 확인할 수 있습니다',
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.purple[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// 배경 스도쿠 그리드를 그리는 CustomPainter
class SudokuBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final boldPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cellSize = 50.0;
    final width = size.width;
    final height = size.height;

    // 가로 선
    for (var i = 0; i <= height / cellSize; i++) {
      final y = i * cellSize;
      final useBoldPaint = i % 3 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        useBoldPaint ? boldPaint : paint,
      );
    }

    // 세로 선
    for (var i = 0; i <= width / cellSize; i++) {
      final x = i * cellSize;
      final useBoldPaint = i % 3 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        useBoldPaint ? boldPaint : paint,
      );
    }

    // 랜덤한 숫자 그리기
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < 10; i++) {
      final x = (i * 3 * cellSize + cellSize / 2) % width;
      final y = (i * 4 * cellSize + cellSize / 2) % height;
      
      textPainter.text = TextSpan(
        text: '${(i % 9) + 1}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.1),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 