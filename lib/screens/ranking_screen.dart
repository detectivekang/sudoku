import 'package:flutter/material.dart';
import '../models/ranking_record.dart';
import '../services/ranking_manager.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('랭킹'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '쉬움'),
              Tab(text: '보통'),
              Tab(text: '어려움'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RankingList(difficulty: '쉬움'),
            _RankingList(difficulty: '보통'),
            _RankingList(difficulty: '어려움'),
          ],
        ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final String difficulty;

  const _RankingList({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RankingRecord>>(
      future: RankingManager.instance.getRecords(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data!
            .where((record) => record.difficulty == difficulty)
            .toList()
          ..sort((a, b) => a.time.compareTo(b.time));

        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '아직 기록이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final minutes = record.time.inMinutes;
            final seconds = record.time.inSeconds % 60;
            final formattedTime = 
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
            final date = record.date;
            final formattedDate = 
                '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: index == 0
                        ? [Colors.amber[300]!, Colors.amber[100]!]
                        : index == 1
                            ? [Colors.grey[300]!, Colors.grey[100]!]
                            : index == 2
                                ? [Colors.brown[300]!, Colors.brown[100]!]
                                : [Colors.blue[100]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: index < 3 ? Colors.transparent : Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: index < 3
                          ? Icon(
                              Icons.emoji_events,
                              color: index == 0
                                  ? Colors.amber[800]
                                  : index == 1
                                      ? Colors.grey[700]
                                      : Colors.brown[700],
                              size: 28,
                            )
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        record.nickname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 