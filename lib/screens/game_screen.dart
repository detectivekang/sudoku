import 'package:flutter/material.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../models/sudoku_generator.dart';
import '../models/ranking_record.dart';
import '../services/ranking_manager.dart';
import 'dart:async';
import '../services/ad_manager.dart';
import '../services/nickname_manager.dart';

class GameScreen extends StatefulWidget {
  final int difficulty;

  const GameScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<int>> board;
  late List<List<int>> originalBoard;
  final SudokuGenerator _generator = SudokuGenerator();
  int selectedRow = -1;
  int selectedCol = -1;
  int errorCount = 0;
  static const int maxErrors = 3;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeDisplay = '00:00';
  bool isHintAvailable = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    AdManager.dispose();
    super.dispose();
  }

  void _startTimer() {
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeDisplay = _formatDuration(_stopwatch.elapsed);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _initializeGame() {
    board = _generator.generate(difficulty: widget.difficulty);
    originalBoard = List.generate(
      9,
      (i) => List.generate(9, (j) => board[i][j]),
    );
    errorCount = 0;
    isHintAvailable = true;
  }

  void onCellTap(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void onNumberSelected(int number) {
    if (selectedRow == -1 || selectedCol == -1) return;
    // 원본 보드에서 이미 채워진 셀은 숫자 입력 불가
    if (originalBoard[selectedRow][selectedCol] != 0) return;
    
    if (_generator.isValidMove(board, selectedRow, selectedCol, number)) {
      setState(() {
        board[selectedRow][selectedCol] = number;
      });
      
      if (_isGameComplete()) {
        _showGameCompleteDialog();
      }
    } else {
      setState(() {
        errorCount++;
        if (errorCount >= maxErrors) {
          _showGameOverDialog();
        }
      });
    }
  }

  bool _isGameComplete() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == 0) return false;
      }
    }
    return true;
  }

  void _showGameCompleteDialog() async {
    final completionTime = _stopwatch.elapsed;
    _stopwatch.stop();
    _timer.cancel();

    // 광고 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final adShown = await AdManager.showRewardedAd();
    final nickname = await NicknameManager.instance.getNickname() ?? 'Unknown';
    
    if (!mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: FutureBuilder<List<RankingRecord>>(
          future: RankingManager.instance.getRecords(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final records = snapshot.data!
                .where((r) => r.difficulty == _getDifficultyString(widget.difficulty))
                .toList()
              ..sort((a, b) => a.time.compareTo(b.time));

            int rank = records.isEmpty ? 1 : 
                records.indexWhere((r) => completionTime <= r.time) + 1;
            if (rank == 0) rank = records.length + 1;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '축하합니다!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '난이도: ${_getDifficultyString(widget.difficulty)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatDuration(completionTime),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$rank위',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: rank <= 3 ? Colors.orange[700] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final record = RankingRecord(
                            difficulty: _getDifficultyString(widget.difficulty),
                            time: completionTime,
                            date: DateTime.now(),
                            nickname: nickname,
                          );
                          await RankingManager.instance.addRecord(record);
                          
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('메인으로'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _initializeGame();
                            selectedRow = -1;
                            selectedCol = -1;
                            _startTimer();
                          });
                        },
                        child: const Text('새 게임'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getDifficultyString(int difficulty) {
    if (difficulty <= 35) return '쉬움';
    if (difficulty <= 45) return '보통';
    return '어려움';
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('게임 오버'),
        content: const Text('3번의 기회를 모두 사용했습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initializeGame();
                selectedRow = -1;
                selectedCol = -1;
                errorCount = 0;
              });
            },
            child: const Text('새 게임'),
          ),
        ],
      ),
    );
  }

  void _useHint() {
    if (!isHintAvailable || selectedRow == -1 || selectedCol == -1) return;

    // 선택된 셀의 정답 찾기
    for (int num = 1; num <= 9; num++) {
      if (_generator.isValidMove(board, selectedRow, selectedCol, num)) {
        bool isCorrectAnswer = true;
        
        // 임시로 숫자를 넣어보고 게임을 완성할 수 있는지 확인
        board[selectedRow][selectedCol] = num;
        
        // 여기서는 간단히 처리하지만, 실제로는 더 복잡한 검증이 필요할 수 있습니다
        for (int i = 0; i < 9 && isCorrectAnswer; i++) {
          for (int j = 0; j < 9; j++) {
            if (board[i][j] != 0) continue;
            bool hasPossibleNumber = false;
            for (int n = 1; n <= 9; n++) {
              if (_generator.isValidMove(board, i, j, n)) {
                hasPossibleNumber = true;
                break;
              }
            }
            if (!hasPossibleNumber) {
              isCorrectAnswer = false;
              break;
            }
          }
        }
        
        // 원래 상태로 되돌리기
        board[selectedRow][selectedCol] = 0;
        
        if (isCorrectAnswer) {
          setState(() {
            board[selectedRow][selectedCol] = num;
            isHintAvailable = false;
            
            if (_isGameComplete()) {
              _showGameCompleteDialog();
            }
          });
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스도쿠'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _timeDisplay,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '오류: $errorCount/$maxErrors',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initializeGame();
                selectedRow = -1;
                selectedCol = -1;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout();
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SudokuGrid(
          board: board,
          originalBoard: originalBoard,
          selectedRow: selectedRow,
          selectedCol: selectedCol,
          onCellTap: onCellTap,
        ),
        NumberPad(
          onNumberSelected: onNumberSelected,
          onHintPressed: _useHint,
          isHintAvailable: isHintAvailable,
          board: board,
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 3,
          child: SudokuGrid(
            board: board,
            originalBoard: originalBoard,
            selectedRow: selectedRow,
            selectedCol: selectedCol,
            onCellTap: onCellTap,
          ),
        ),
        Expanded(
          flex: 2,
          child: NumberPad(
            onNumberSelected: onNumberSelected,
            onHintPressed: _useHint,
            isHintAvailable: isHintAvailable,
            board: board,
          ),
        ),
      ],
    );
  }
}
