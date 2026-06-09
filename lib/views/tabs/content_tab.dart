import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/chapter_content_model.dart';

class ContentTab extends StatefulWidget {
  const ContentTab({super.key});

  @override
  State<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<ContentTab> {
  int _activeSectionIndex = 0;
  final List<String> _sections = [
    'General Metadata',
    'Simple Overview',
    'Read Mode',
    'Must Know Terms',
    'Good to Know Insights',
    'Pre-requisite Concepts',
    'Industry Insights',
    'AI Learning Chips',
    'Plus Points Topics',
    'Quiz & Questions',
  ];

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final curriculum = adminProv.curriculum;
    
    // Build selections
    final gradesList = curriculum.keys.toList();
    final currentGrade = adminProv.selectedGradeKey != null && curriculum.containsKey(adminProv.selectedGradeKey)
        ? curriculum[adminProv.selectedGradeKey]
        : null;

    final subjectsList = currentGrade?.subjects ?? [];
    final currentSubject = adminProv.selectedSubjectId != null
        ? subjectsList.where((s) => s.id == adminProv.selectedSubjectId).firstOrNull
        : null;

    final chaptersList = currentSubject?.chapters ?? [];

    return Column(
      children: [
        // Top Selection Dropdowns Panel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0E101A),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF1C1E30),
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Grade Select
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Grade', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF555978), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131520),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1C1E30)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: adminProv.selectedGradeKey,
                          hint: const Text('Choose Grade', style: TextStyle(color: Color(0xFF555978), fontSize: 13)),
                          dropdownColor: const Color(0xFF131520),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: gradesList.map((key) {
                            final g = curriculum[key]!;
                            return DropdownMenuItem(
                              value: key,
                              child: Text('${g.emoji} ${g.name}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            adminProv.selectGrade(val);
                            setState(() {
                              _activeSectionIndex = 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Subject Select
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Subject', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF555978), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131520),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1C1E30)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: adminProv.selectedSubjectId,
                          hint: const Text('Choose Subject', style: TextStyle(color: Color(0xFF555978), fontSize: 13)),
                          dropdownColor: const Color(0xFF131520),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: subjectsList.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.emoji} ${s.name}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            adminProv.selectSubject(val);
                            setState(() {
                              _activeSectionIndex = 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Chapter Select
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Chapter', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF555978), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131520),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1C1E30)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: adminProv.selectedChapterNumber,
                          hint: const Text('Choose Chapter', style: TextStyle(color: Color(0xFF555978), fontSize: 13)),
                          dropdownColor: const Color(0xFF131520),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: chaptersList.map((c) {
                            return DropdownMenuItem(
                              value: c.number,
                              child: Text('Ch ${c.number}: ${c.title}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            adminProv.selectChapter(val);
                            setState(() {
                              _activeSectionIndex = 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body Content forms split panel
        Expanded(
          child: adminProv.selectedChapterNumber == null
              ? _buildEmptyState()
              : adminProv.isLoadingContent
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF6366F1)),
                          SizedBox(height: 16),
                          Text('Downloading chapter payload from DB...', style: TextStyle(color: Color(0xFF6C7194))),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left sidebar: categories selector
                        Container(
                          width: 250,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFF1C1E30), width: 1.5),
                            ),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                            itemCount: _sections.length,
                            itemBuilder: (context, idx) {
                              final isActive = _activeSectionIndex == idx;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _activeSectionIndex = idx;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  dense: true,
                                  tileColor: isActive ? const Color(0xFF6366F1).withOpacity(0.12) : Colors.transparent,
                                  title: Text(
                                    _sections[idx],
                                    style: GoogleFonts.inter(
                                      color: isActive ? Colors.white : const Color(0xFF8C91B2),
                                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Right sidebar: editing forms
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Heading
                                Row(
                                  children: [
                                    Text(
                                      _sections[_activeSectionIndex],
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Save Button
                                    ElevatedButton.icon(
                                      onPressed: () => _handleSave(adminProv),
                                      icon: const Icon(Icons.cloud_done_outlined, size: 16),
                                      label: const Text('Save Chapter Content'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Delete Button
                                    OutlinedButton.icon(
                                      onPressed: () => _handleDelete(adminProv),
                                      icon: const Icon(Icons.delete_forever, size: 16),
                                      label: const Text('Delete Payload'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFEF4444),
                                        side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(height: 1, color: Color(0xFF1C1E30)),
                                const SizedBox(height: 24),

                                // Render Active Section form
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _buildFormBody(adminProv),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.playlist_add_check,
              size: 80,
              color: Color(0xFF23263B),
            ),
            const SizedBox(height: 16),
            Text(
              'No Chapter Selected',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8C91B2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a Grade, Subject, and Chapter to load the content payload from the database.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF555978),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW RENDERER FOR FORMS
  // ==========================================

  Widget _buildFormBody(AdminProvider prov) {
    final active = prov.activeContent;
    if (active == null) return const Text('No content found');

    switch (_activeSectionIndex) {
      case 0: // Metadata
        return _buildMetadataForm(prov, active);
      case 1: // Simple Overview
        return _buildSimpleOverviewForm(prov, active);
      case 2: // Read Mode
        return _buildReadModeForm(prov, active);
      case 3: // Must Know
        return _buildMustKnowForm(prov, active);
      case 4: // Good to Know
        return _buildGoodToKnowForm(prov, active);
      case 5: // Pre-requisite
        return _buildPrerequisiteForm(prov, active);
      case 6: // Industry Insights
        return _buildIndustryForm(prov, active);
      case 7: // AI Chips
        return _buildChipsForm(prov, active);
      case 8: // Plus Points
        return _buildPlusPointsForm(prov, active);
      case 9: // Quiz
        return _buildQuizForm(prov, active);
      default:
        return const Text('Form Index Error');
    }
  }

  // Forms Fields Helpers
  Widget _buildFormField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    String hint = '',
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB4B9D6), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            maxLines: maxLines,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF555978)),
              filled: true,
              fillColor: const Color(0xFF131520),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1C1E30)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1C1E30)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // 1. Metadata Form
  Widget _buildMetadataForm(AdminProvider prov, ChapterContent content) {
    return Column(
      children: [
        _buildFormField(
          label: 'Chapter Code / ID',
          value: content.metadata.chapterId,
          onChanged: (val) {
            content.metadata.chapterId = val;
            prov.updateActiveContent(content);
          },
        ),
        _buildFormField(
          label: 'Chapter Name',
          value: content.metadata.chapterName,
          onChanged: (val) {
            content.metadata.chapterName = val;
            prov.updateActiveContent(content);
          },
        ),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Grade Level',
                value: content.metadata.grade.toString(),
                isNumeric: true,
                onChanged: (val) {
                  content.metadata.grade = int.tryParse(val) ?? 7;
                  prov.updateActiveContent(content);
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFormField(
                label: 'Chapter Number',
                value: content.metadata.chapterNumber.toString(),
                isNumeric: true,
                onChanged: (val) {
                  content.metadata.chapterNumber = int.tryParse(val) ?? 1;
                  prov.updateActiveContent(content);
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Format Version',
                value: content.metadata.formatVersion,
                onChanged: (val) {
                  content.metadata.formatVersion = val;
                  prov.updateActiveContent(content);
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFormField(
                label: 'Output Type',
                value: content.metadata.outputType,
                onChanged: (val) {
                  content.metadata.outputType = val;
                  prov.updateActiveContent(content);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Simple Overview Form
  Widget _buildSimpleOverviewForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Concepts list (${content.simpleOverview.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                content.simpleOverview.add(ConceptItem(title: 'New Concept', explanation: ''));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Concept'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.simpleOverview.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final item = content.simpleOverview[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Concept #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.simpleOverview.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    label: 'Concept Title',
                    value: item.title,
                    onChanged: (val) {
                      item.title = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Explanation',
                    value: item.explanation,
                    maxLines: 3,
                    onChanged: (val) {
                      item.explanation = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 3. Read Mode Form
  Widget _buildReadModeForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sections list (${content.readMode.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                content.readMode.add(ReadModeSection(heading: 'New Section', paragraphs: [], keyPoints: [], example: ''));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Section'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.readMode.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final sec = content.readMode[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Section #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.readMode.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    label: 'Heading',
                    value: sec.heading,
                    onChanged: (val) {
                      sec.heading = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Paragraphs (One paragraph per line)',
                    value: sec.paragraphs.join('\n'),
                    maxLines: 4,
                    hint: 'First paragraph...\nSecond paragraph...',
                    onChanged: (val) {
                      sec.paragraphs = val.split('\n').where((line) => line.trim().isNotEmpty).toList();
                    },
                  ),
                  _buildFormField(
                    label: 'Key Points (One point per line)',
                    value: sec.keyPoints.join('\n'),
                    maxLines: 4,
                    hint: 'First key point...\nSecond key point...',
                    onChanged: (val) {
                      sec.keyPoints = val.split('\n').where((line) => line.trim().isNotEmpty).toList();
                    },
                  ),
                  _buildFormField(
                    label: 'Example / Connection Case',
                    value: sec.example,
                    maxLines: 2,
                    onChanged: (val) {
                      sec.example = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 4. Must Know Terms Form
  Widget _buildMustKnowForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Terms list (${content.mustKnow.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                content.mustKnow.add(MustKnowTerm(term: '', definition: '', importance: ''));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Term'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.mustKnow.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final item = content.mustKnow[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Term #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.mustKnow.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    label: 'Term / Vocabulary Name',
                    value: item.term,
                    onChanged: (val) {
                      item.term = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Definition',
                    value: item.definition,
                    maxLines: 2,
                    onChanged: (val) {
                      item.definition = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Why is this Important / Exam Value',
                    value: item.importance,
                    maxLines: 2,
                    onChanged: (val) {
                      item.importance = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 5. Good to Know Insights Form
  Widget _buildGoodToKnowForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Insights list (${content.goodToKnow.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                content.goodToKnow.add(GoodToKnowInsight(title: '', content: '', connection: ''));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Insight'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.goodToKnow.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final item = content.goodToKnow[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Insight #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.goodToKnow.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    label: 'Insight Title',
                    value: item.title,
                    onChanged: (val) {
                      item.title = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Insight Content / Description',
                    value: item.content,
                    maxLines: 3,
                    onChanged: (val) {
                      item.content = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Ecosystem Connection',
                    value: item.connection,
                    maxLines: 2,
                    onChanged: (val) {
                      item.connection = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 6. Pre-requisite Form
  Widget _buildPrerequisiteForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Prerequisites list (${content.preRequisite.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                content.preRequisite.add(PreRequisiteItem(concept: '', explanation: '', connection: ''));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Prerequisite'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.preRequisite.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final item = content.preRequisite[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Prerequisite #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.preRequisite.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    label: 'Concept / Foundation name',
                    value: item.concept,
                    onChanged: (val) {
                      item.concept = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Brief explanation',
                    value: item.explanation,
                    maxLines: 2,
                    onChanged: (val) {
                      item.explanation = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Connection to this Chapter',
                    value: item.connection,
                    maxLines: 2,
                    onChanged: (val) {
                      item.connection = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 7. Industry Insights Form
  Widget _buildIndustryForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Industry Applications list (${content.industryInsights.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                content.industryInsights.add(IndustryInsightItem(field: '', application: '', exampleRole: ''));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Application'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.industryInsights.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final item = content.industryInsights[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Application #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.industryInsights.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    label: 'Field / Industry Sector',
                    value: item.field,
                    onChanged: (val) {
                      item.field = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Real-world Application description',
                    value: item.application,
                    maxLines: 2,
                    onChanged: (val) {
                      item.application = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Example Professional Role',
                    value: item.exampleRole,
                    onChanged: (val) {
                      item.exampleRole = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 8. AI Learning Chips Form
  Widget _buildChipsForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chips List (${content.chips.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                final idStr = '${content.metadata.chapterNumber}_chip_${content.chips.length + 1}';
                content.chips.add(ChipItem(id: idStr, title: 'New Chip', preview: '', paragraphs: [], keyPoints: [], aiEnabled: true));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Chip'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.chips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final chip = content.chips[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Chip #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('AI Enabled', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Checkbox(
                            value: chip.aiEnabled,
                            activeColor: const Color(0xFF6366F1),
                            checkColor: Colors.white,
                            onChanged: (val) {
                              chip.aiEnabled = val ?? true;
                              prov.updateActiveContent(content);
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.chips.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Unique ID',
                          value: chip.id,
                          onChanged: (val) {
                            chip.id = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Chip Title',
                          value: chip.title,
                          onChanged: (val) {
                            chip.title = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    label: 'Preview text',
                    value: chip.preview,
                    maxLines: 2,
                    onChanged: (val) {
                      chip.preview = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Detailed Paragraphs (One per line)',
                    value: chip.paragraphs.join('\n'),
                    maxLines: 4,
                    onChanged: (val) {
                      chip.paragraphs = val.split('\n').where((line) => line.trim().isNotEmpty).toList();
                    },
                  ),
                  _buildFormField(
                    label: 'Key points summary (One per line)',
                    value: chip.keyPoints.join('\n'),
                    maxLines: 4,
                    onChanged: (val) {
                      chip.keyPoints = val.split('\n').where((line) => line.trim().isNotEmpty).toList();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 9. Plus Points Form
  Widget _buildPlusPointsForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Topics list (${content.plusPoints.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                final idStr = '${content.metadata.chapterNumber}.${content.plusPoints.length + 1}';
                content.plusPoints.add(PlusPointTopic(id: idStr, title: 'New Topic', summary: '', keyFacts: [], commonMistake: '', aiEnabled: true, evaluationReady: true));
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Topic'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.plusPoints.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final topic = content.plusPoints[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Topic #${idx + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('AI Mode', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Checkbox(
                            value: topic.aiEnabled,
                            activeColor: const Color(0xFF6366F1),
                            onChanged: (val) {
                              topic.aiEnabled = val ?? true;
                              prov.updateActiveContent(content);
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text('Eval Ready', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Checkbox(
                            value: topic.evaluationReady,
                            activeColor: const Color(0xFF6366F1),
                            onChanged: (val) {
                              topic.evaluationReady = val ?? true;
                              prov.updateActiveContent(content);
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.plusPoints.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Unique Section Code ID',
                          value: topic.id,
                          onChanged: (val) {
                            topic.id = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Topic Title',
                          value: topic.title,
                          onChanged: (val) {
                            topic.title = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    label: 'Summary explanation',
                    value: topic.summary,
                    maxLines: 2,
                    onChanged: (val) {
                      topic.summary = val;
                    },
                  ),
                  _buildFormField(
                    label: 'Key Facts / Checkpoints (One per line)',
                    value: topic.keyFacts.join('\n'),
                    maxLines: 4,
                    onChanged: (val) {
                      topic.keyFacts = val.split('\n').where((line) => line.trim().isNotEmpty).toList();
                    },
                  ),
                  _buildFormField(
                    label: 'Common Student Mistakes / Pitfalls',
                    value: topic.commonMistake,
                    maxLines: 2,
                    onChanged: (val) {
                      topic.commonMistake = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 10. Quiz and Questions Form
  Widget _buildQuizForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Quiz Settings
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF312E81)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Quiz Settings', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: 'Quiz Title',
                      value: content.quiz.title,
                      onChanged: (val) {
                        content.quiz.title = val;
                        prov.updateActiveContent(content);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: 'Passing score (%)',
                      value: content.quiz.passingScore.toString(),
                      isNumeric: true,
                      onChanged: (val) {
                        content.quiz.passingScore = int.tryParse(val) ?? 60;
                        prov.updateActiveContent(content);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: 'Time limit (Minutes)',
                      value: content.quiz.timeLimitMinutes.toString(),
                      isNumeric: true,
                      onChanged: (val) {
                        content.quiz.timeLimitMinutes = int.tryParse(val) ?? 15;
                        prov.updateActiveContent(content);
                      },
                    ),
                  ),
                ],
              ),
              _buildFormField(
                label: 'Instructions',
                value: content.quiz.instructions,
                onChanged: (val) {
                  content.quiz.instructions = val;
                  prov.updateActiveContent(content);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Questions List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Questions list (${content.quiz.questions.length})', style: const TextStyle(color: Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                final newQ = QuizQuestion(
                  id: content.quiz.questions.length + 1,
                  questionText: 'New Question',
                  options: [
                    QuizOption(key: 'A', text: ''),
                    QuizOption(key: 'B', text: ''),
                    QuizOption(key: 'C', text: ''),
                    QuizOption(key: 'D', text: ''),
                  ],
                  correctAnswer: 'A',
                  explanation: '',
                  difficulty: 'easy',
                  concept: '',
                );
                content.quiz.questions.add(newQ);
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add MCQ Question'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.quiz.questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final q = content.quiz.questions[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F101A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1C1E30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('Question #${idx + 1} (ID: ${q.id})', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                        onPressed: () {
                          content.quiz.questions.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Question ID (Number)',
                          value: q.id.toString(),
                          isNumeric: true,
                          onChanged: (val) {
                            q.id = int.tryParse(val) ?? q.id;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Tested Concept name',
                          value: q.concept,
                          onChanged: (val) {
                            q.concept = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Difficulty', style: TextStyle(color: Color(0xFFB4B9D6), fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131520),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF1C1E30)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: q.difficulty,
                                  dropdownColor: const Color(0xFF131520),
                                  isExpanded: true,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  items: ['easy', 'medium', 'hard'].map((d) {
                                    return DropdownMenuItem(value: d, child: Text(d.toUpperCase()));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      q.difficulty = val;
                                      prov.updateActiveContent(content);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    label: 'Question Text',
                    value: q.questionText,
                    maxLines: 2,
                    onChanged: (val) {
                      q.questionText = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Answers Options & Correct Choice', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8C91B2), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Render options A, B, C, D fields
                  ...q.options.map((opt) {
                    return Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: q.correctAnswer == opt.key
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1C1E30),
                          ),
                          child: Text(opt.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFormField(
                            label: 'Option ${opt.key} Text',
                            value: opt.text,
                            onChanged: (val) {
                              opt.text = val;
                            },
                          ),
                        ),
                        Radio<String>(
                          value: opt.key,
                          groupValue: q.correctAnswer,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            if (val != null) {
                              q.correctAnswer = val;
                              prov.updateActiveContent(content);
                            }
                          },
                        ),
                      ],
                    );
                  }),
                  _buildFormField(
                    label: 'Explanation on Correct Option',
                    value: q.explanation,
                    maxLines: 2,
                    onChanged: (val) {
                      q.explanation = val;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // LOGIC ACTIONS
  // ==========================================

  Future<void> _handleSave(AdminProvider prov) async {
    try {
      await prov.saveChapterContent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chapter content successfully published to Firebase RTDB!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish content: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(AdminProvider prov) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131520),
          title: Text('Confirm Database Deletion', style: GoogleFonts.outfit(color: Colors.white)),
          content: Text('Are you sure you want to permanently delete the content payload for Chapter ${prov.selectedChapterNumber} from Firebase? This action cannot be undone.', style: GoogleFonts.inter(color: const Color(0xFF8C91B2))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6C7194))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await prov.deleteActiveChapterContent();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chapter content deleted from Firebase.'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete content: $e'),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }
}
