import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();

    // Load dashboard stats when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminCtrl.loadDashboardStats();
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        title: Obx(() => Text(
          'Admin - ${adminCtrl.getCurrentAdminName()}',
          style: const TextStyle(color: Colors.white),
        )),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          adminCtrl.logout();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  final stats = adminCtrl.dashboardStats.value;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              title: 'Total Users',
                              value: stats['total_users']?.toString() ?? '0',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.quiz,
                              title: 'Total Quizzes',
                              value: stats['total_quizzes']?.toString() ?? '0',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.book,
                              title: 'Courses',
                              value: stats['total_courses']?.toString() ?? '0',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.assessment,
                              title: 'Attempts',
                              value: stats['total_attempts']?.toString() ?? '0',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),

              // Menu Options
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView(
                    children: [
                      const Text(
                        'Admin Menu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quiz Management
                      _MenuCard(
                        icon: Icons.quiz,
                        title: 'Quiz Management',
                        subtitle: 'Create, edit, and delete quizzes',
                        color: Colors.indigo,
                        onTap: () => Get.toNamed('/admin/quiz-management'),
                      ),
                      const SizedBox(height: 12),

                      // User Progress
                      _MenuCard(
                        icon: Icons.analytics,
                        title: 'User Progress',
                        subtitle: 'Monitor user quiz results',
                        color: Colors.teal,
                        onTap: () => Get.toNamed('/admin/user-progress'),
                      ),
                      const SizedBox(height: 12),

                      // Course Management (placeholder)
                      _MenuCard(
                        icon: Icons.school,
                        title: 'Course Management',
                        subtitle: 'Manage courses (Coming soon)',
                        color: Colors.orange,
                        onTap: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Course management feature will be available soon',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // User Management (placeholder)
                      _MenuCard(
                        icon: Icons.people,
                        title: 'User Management',
                        subtitle: 'Manage user accounts (Coming soon)',
                        color: Colors.blue,
                        onTap: () {
                          Get.snackbar(
                            'Coming Soon',
                            'User management feature will be available soon',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Statistics Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Menu Card Widget
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}