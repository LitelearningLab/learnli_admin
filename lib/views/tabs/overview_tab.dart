import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../constants/app_colors.dart';

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
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.auto_stories,
                  size: 64,
                  color: AppColors.background,
                ),
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
                gradientColors: [AppColors.primary, const Color(0xFF2563EB)],
              ),
              _buildStatCard(
                title: 'Total Subjects',
                value: totalSubjects.toString(),
                icon: Icons.menu_book_outlined,
                gradientColors: [AppColors.secondary, const Color(0xFF059669)],
              ),
              _buildStatCard(
                title: 'Total Chapters',
                value: totalChapters.toString(),
                icon: Icons.collections_bookmark_outlined,
                gradientColors: [
                  const Color(0xFF0EA5E9),
                  const Color(0xFF2563EB),
                ],
              ),
              _buildStatCard(
                title: 'Total Careers',
                value: adminProv.careers.length.toString(),
                icon: Icons.work_outline,
                gradientColors: [AppColors.warning, const Color(0xFFD97706)],
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
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  'No curriculum structure found in the database. Head over to Curriculum Editor to create one.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
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
                final colors = [
                  AppColors.primary,
                  AppColors.secondary,
                  const Color(0xFF8B5CF6), // Purple
                  const Color(0xFFEC4899), // Pink
                  const Color(0xFFF59E0B), // Orange
                ];
                final accentColor = colors[idx % colors.length];

                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height:
                            120, // Approximate height to align left border accent visually
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(),
                          collapsedShape: const RoundedRectangleBorder(),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              grade.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          title: Text(
                            grade.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            grade.description,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.all(16),
                          children: [
                            if (grade.subjects.isEmpty)
                              Text(
                                'No subjects defined.',
                                style: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: grade.subjects.map((sub) {
                                  final subjectColor = _parseHexColor(
                                    sub.color,
                                  );
                                  return IntrinsicHeight(
                                    child: Container(
                                      width: 320,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            width: 4,
                                            decoration: BoxDecoration(
                                              color: subjectColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      12,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      12,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        sub.emoji,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          sub.name,
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .textPrimary,
                                                              ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  subjectColor,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    '${sub.chapters.length} Chapters registered:',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if (sub.chapters.isEmpty)
                                                    Text(
                                                      'No chapters created.',
                                                      style: GoogleFonts.inter(
                                                        color:
                                                            AppColors.textMuted,
                                                        fontSize: 12,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    )
                                                  else
                                                    ...sub.chapters.take(3).map((
                                                      ch,
                                                    ) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4.0,
                                                            ),
                                                        child: Text(
                                                          'Ch ${ch.number}: ${ch.title}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts.inter(
                                                            color: AppColors
                                                                .textSecondary,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  if (sub.chapters.length > 3)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 4.0,
                                                          ),
                                                      child: Text(
                                                        '+ ${sub.chapters.length - 3} more...',
                                                        style:
                                                            GoogleFonts.inter(
                                                              color: AppColors
                                                                  .primary,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
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
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
            child: Icon(icon, color: Colors.white, size: 28),
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
