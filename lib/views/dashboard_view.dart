import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'tabs/overview_tab.dart';
import 'tabs/curriculum_tab.dart';
import 'tabs/content_tab.dart';
import 'tabs/json_tab.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _activeTabIndex = 0;

  final List<String> _tabTitles = [
    'Overview Dashboard',
    'Curriculum Structuring',
    'Chapter Content Editor',
    'JSON Structural Import/Export',
  ];

  Widget _buildActiveTab(int index) {
    switch (index) {
      case 0:
        return const OverviewTab();
      case 1:
        return const CurriculumTab();
      case 2:
        return const ContentTab();
      case 3:
        return const JsonTab();
      default:
        return const OverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      body: Row(
        children: [
          // Sidebar Left
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF0E101A),
              border: Border(
                right: BorderSide(
                  color: Color(0xFF1C1E30),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LearnLi Panel',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Content Management',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF555978),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF1C1E30)),
                const SizedBox(height: 24),

                // Navigation Items
                _buildSidebarItem(
                  index: 0,
                  label: 'Overview',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                ),
                _buildSidebarItem(
                  index: 1,
                  label: 'Curriculum Editor',
                  icon: Icons.account_tree_outlined,
                  activeIcon: Icons.account_tree,
                ),
                _buildSidebarItem(
                  index: 2,
                  label: 'Chapter Content',
                  icon: Icons.edit_note_outlined,
                  activeIcon: Icons.edit_note,
                ),
                _buildSidebarItem(
                  index: 3,
                  label: 'JSON Import/Export',
                  icon: Icons.code_outlined,
                  activeIcon: Icons.code,
                ),

                const Spacer(),

                // User Info & Sign Out
                const Divider(height: 1, color: Color(0xFF1C1E30)),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF6366F1),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'admin@gmail.com',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF6C7194),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => adminProv.logout(),
                          icon: const Icon(Icons.logout, size: 16),
                          label: Text(
                            'Logout',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Screen Right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Panel
                Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C0E17),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF1C1E30),
                        width: 1.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Text(
                        _tabTitles[_activeTabIndex],
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Firebase Database Online Status Dot
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Firebase Connected',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Tab Body
                Expanded(
                  child: adminProv.isLoadingCurriculum
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF6366F1),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading curriculum structure from Firebase...',
                                style: TextStyle(color: Color(0xFF6C7194)),
                              )
                            ],
                          ),
                        )
                      : _buildActiveTab(_activeTabIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = _activeTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _activeTabIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF6366F1).withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? const Color(0xFF6366F1) : const Color(0xFF555978),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? Colors.white : const Color(0xFF8C91B2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
