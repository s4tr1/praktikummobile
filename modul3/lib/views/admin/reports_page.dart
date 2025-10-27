import 'package:flutter/material.dart';
import '../../database/progress_dao.dart';
import '../../utils/app_colors.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ProgressDAO dao = ProgressDAO();
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final data = await dao.getAllProgressRaw();
    setState(() => reports = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Progress Belajar'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text('User ID: ${r['user_id']}'),
            subtitle: Text('Kursus ID: ${r['course_id']} | Nilai: ${r['score'] ?? '-'}'),
          );
        },
      ),
    );
  }
}
