import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final curriculum = adminProv.curriculum;

    int totalGrades = curriculum.length;
    int totalSubjects = 0;
    int totalChapters = 0;

    curriculum.forEach((_, grade) {
      totalSubjects += grade.subjects.length;
      for (var subject in grade.subjects) {
        totalChapters += subject.chapters.length;
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Banner Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF311042)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF312E81)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, Admin 👋',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage, add, and publish structured education material. Your changes sync in real-time to the student mobile app.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFC7D2FE),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.auto_stories,
                  size: 64,
                  color: Color(0xFF818CF8),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stat Metrics Row
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              _buildStatCard(
                title: 'Total Grades',
                value: totalGrades.toString(),
                icon: Icons.school_outlined,
                gradientColors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
              ),
              _buildStatCard(
                title: 'Total Subjects',
                value: totalSubjects.toString(),
                icon: Icons.menu_book_outlined,
                gradientColors: [const Color(0xFFA855F7), const Color(0xFF7C3AED)],
              ),
              _buildStatCard(
                title: 'Total Chapters',
                value: totalChapters.toString(),
                icon: Icons.collections_bookmark_outlined,
                gradientColors: [const Color(0xFF0EA5E9), const Color(0xFF2563EB)],
              ),
              _buildStatCard(
                title: 'Total Careers',
                value: adminProv.careers.length.toString(),
                icon: Icons.work_outline,
                gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Quick Summary of Structure
          Text(
            'Active Curriculum Summary',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (curriculum.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF131520),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Center(
                child: Text(
                  'No curriculum structure found in the database. Head over to Curriculum Editor to create one.',
                  style: GoogleFonts.inter(color: const Color(0xFF6C7194)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: curriculum.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final key = curriculum.keys.elementAt(idx);
                final grade = curriculum[key]!;
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF131520),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1C1E30)),
                  ),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(),
                    collapsedShape: const RoundedRectangleBorder(),
                    leading: Text(
                      grade.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      grade.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      grade.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6C7194),
                      ),
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      if (grade.subjects.isEmpty)
                        Text(
                          'No subjects defined.',
                          style: GoogleFonts.inter(color: const Color(0xFF555978), fontSize: 13),
                        )
                      else
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: grade.subjects.map((sub) {
                            return Container(
                              width: 320,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1D2C),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2C2F48),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        sub.emoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          sub.name,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _parseHexColor(sub.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${sub.chapters.length} Chapters registered:',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF8C91B2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (sub.chapters.isEmpty)
                                    Text(
                                      'No chapters created.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF555978),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  else
                                    ...sub.chapters.take(3).map((ch) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Ch ${ch.number}: ${ch.title}',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF6C7194),
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }),
                                  if (sub.chapters.length > 3)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        '+ ${sub.chapters.length - 3} more...',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF6366F1),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF131520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1C1E30),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8C91B2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }
}
