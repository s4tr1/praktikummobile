import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'manage_users.dart';
import 'manage_courses.dart';
import 'reports_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
                crossAxisC
