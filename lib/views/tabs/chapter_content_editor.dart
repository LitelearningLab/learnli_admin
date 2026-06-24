import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/chapter_content_model.dart';
import '../../constants/app_colors.dart';
import '../../services/database_service.dart';

class ChapterContentEditor extends StatefulWidget {
  const ChapterContentEditor({super.key});

  @override
  State<ChapterContentEditor> createState() => _ChapterContentEditorState();
}

class _ChapterContentEditorState extends State<ChapterContentEditor> {
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

  bool _isUploadingHtml = false;

  Future<String?> _pickAndUploadHtml() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final name = result.files.single.name;

        final downloadUrl = await DatabaseService.uploadHtmlFile(name, bytes);
        if (downloadUrl != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded $name successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return downloadUrl;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    return null;
  }

  Widget _buildUrlFormField({
    required String key,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    required VoidCallback onUploadPressed,
    bool isUploading = false,
  }) {
    return UrlUploadField(
      label: label,
      value: value,
      onChanged: onChanged,
      onUploadPressed: onUploadPressed,
      isUploading: isUploading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);

    return adminProv.selectedChapterNumber == null
        ? _buildEmptyState()
        : adminProv.isLoadingContent
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Downloading chapter payload from DB...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Horizontal scrollable categories selector
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sections.length,
                  itemBuilder: (context, idx) {
                    final label = _sections[idx];
                    final isActive = _activeSectionIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          label,
                          style: GoogleFonts.inter(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                        selected: isActive,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.transparent,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activeSectionIndex = idx;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Main form area below
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading and publish action row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _sections[_activeSectionIndex],
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Save Button
                            ElevatedButton.icon(
                              onPressed: () => _handleSave(adminProv),
                              icon: const Icon(
                                Icons.cloud_done_outlined,
                                size: 14,
                              ),
                              label: const Text(
                                'Save Content',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete Button
                            OutlinedButton.icon(
                              onPressed: () => _handleDelete(adminProv),
                              icon: const Icon(Icons.delete_forever, size: 14),
                              label: const Text(
                                'Delete Payload',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withOpacity(0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),

                    // Render Active Section form
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildFormBody(adminProv),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.playlist_add_check,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            'No Chapter Selected',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a Grade, Subject, and Chapter to load the content payload from the database.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
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
    required String key,
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
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey(key),
            initialValue: value,
            maxLines: maxLines,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 13.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
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
          key: 'meta_chapter_id',
          label: 'Chapter Code / ID',
          value: content.metadata.chapterId,
          onChanged: (val) {
            content.metadata.chapterId = val;
            prov.updateActiveContent(content);
          },
        ),
        _buildFormField(
          key: 'meta_chapter_name',
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
                key: 'meta_grade',
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
                key: 'meta_chapter_number',
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
                key: 'meta_format_version',
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
                key: 'meta_output_type',
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
        _buildUrlFormField(
          key: 'meta_interactive_url',
          label: 'Interactive Web Lesson URL (Optional)',
          value: content.metadata.interactiveLessonUrl ?? '',
          isUploading: _isUploadingHtml,
          onChanged: (val) {
            content.metadata.interactiveLessonUrl = val.trim().isEmpty
                ? null
                : val.trim();
            prov.updateActiveContent(content);
          },
          onUploadPressed: () async {
            setState(() {
              _isUploadingHtml = true;
            });
            try {
              final fileUrl = await _pickAndUploadHtml();
              if (fileUrl != null) {
                content.metadata.interactiveLessonUrl = fileUrl;
                prov.updateActiveContent(content);
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isUploadingHtml = false;
                });
              }
            }
          },
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
            Text(
              'Concepts list (${content.simpleOverview.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                content.simpleOverview.add(
                  ConceptItem(title: 'New Concept', explanation: ''),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Concept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(item),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Concept #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          content.simpleOverview.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    key: 'concept_${item.hashCode}_title',
                    label: 'Concept Title',
                    value: item.title,
                    onChanged: (val) {
                      item.title = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'concept_${item.hashCode}_explanation',
                    label: 'Explanation',
                    value: item.explanation,
                    maxLines: 3,
                    onChanged: (val) {
                      item.explanation = val;
                      prov.updateActiveContent(content);
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
            Text(
              'Sections list (${content.readMode.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                content.readMode.add(
                  ReadModeSection(
                    heading: 'New Section',
                    paragraphs: [],
                    keyPoints: [],
                    example: '',
                  ),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Section'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(sec),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Section #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          content.readMode.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    key: 'read_${sec.hashCode}_heading',
                    label: 'Heading',
                    value: sec.heading,
                    onChanged: (val) {
                      sec.heading = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'read_${sec.hashCode}_paragraphs',
                    label: 'Paragraphs (One paragraph per line)',
                    value: sec.paragraphs.join('\n'),
                    maxLines: 4,
                    hint: 'First paragraph...\nSecond paragraph...',
                    onChanged: (val) {
                      sec.paragraphs = val
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList();
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'read_${sec.hashCode}_key_points',
                    label: 'Key Points (One point per line)',
                    value: sec.keyPoints.join('\n'),
                    maxLines: 4,
                    hint: 'First key point...\nSecond key point...',
                    onChanged: (val) {
                      sec.keyPoints = val
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList();
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'read_${sec.hashCode}_example',
                    label: 'Example / Connection Case',
                    value: sec.example,
                    maxLines: 2,
                    onChanged: (val) {
                      sec.example = val;
                      prov.updateActiveContent(content);
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
            Text(
              'Terms list (${content.mustKnow.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                content.mustKnow.add(
                  MustKnowTerm(term: '', definition: '', importance: ''),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Term'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(item),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Term #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          content.mustKnow.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    key: 'must_${item.hashCode}_term',
                    label: 'Term / Vocabulary Name',
                    value: item.term,
                    onChanged: (val) {
                      item.term = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'must_${item.hashCode}_definition',
                    label: 'Definition',
                    value: item.definition,
                    maxLines: 2,
                    onChanged: (val) {
                      item.definition = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'must_${item.hashCode}_importance',
                    label: 'Why is this Important / Exam Value',
                    value: item.importance,
                    maxLines: 2,
                    onChanged: (val) {
                      item.importance = val;
                      prov.updateActiveContent(content);
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
            Text(
              'Insights list (${content.goodToKnow.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                content.goodToKnow.add(
                  GoodToKnowInsight(title: '', content: '', connection: ''),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Insight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(item),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Insight #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          content.goodToKnow.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    key: 'good_${item.hashCode}_title',
                    label: 'Insight Title',
                    value: item.title,
                    onChanged: (val) {
                      item.title = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'good_${item.hashCode}_content',
                    label: 'Insight Content / Description',
                    value: item.content,
                    maxLines: 3,
                    onChanged: (val) {
                      item.content = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'good_${item.hashCode}_connection',
                    label: 'Ecosystem Connection',
                    value: item.connection,
                    maxLines: 2,
                    onChanged: (val) {
                      item.connection = val;
                      prov.updateActiveContent(content);
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
            Text(
              'Prerequisites list (${content.preRequisite.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                content.preRequisite.add(
                  PreRequisiteItem(
                    concept: '',
                    explanation: '',
                    connection: '',
                  ),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Prerequisite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(item),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Prerequisite #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          content.preRequisite.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    key: 'pre_${item.hashCode}_concept',
                    label: 'Concept / Foundation name',
                    value: item.concept,
                    onChanged: (val) {
                      item.concept = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'pre_${item.hashCode}_explanation',
                    label: 'Brief explanation',
                    value: item.explanation,
                    maxLines: 2,
                    onChanged: (val) {
                      item.explanation = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'pre_${item.hashCode}_connection',
                    label: 'Connection to this Chapter',
                    value: item.connection,
                    maxLines: 2,
                    onChanged: (val) {
                      item.connection = val;
                      prov.updateActiveContent(content);
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
            Text(
              'Industry Applications list (${content.industryInsights.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                content.industryInsights.add(
                  IndustryInsightItem(
                    field: '',
                    application: '',
                    exampleRole: '',
                  ),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Application'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(item),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Application #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          content.industryInsights.removeAt(idx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormField(
                    key: 'ind_${item.hashCode}_field',
                    label: 'Field / Industry Sector',
                    value: item.field,
                    onChanged: (val) {
                      item.field = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'ind_${item.hashCode}_application',
                    label: 'Real-world Application description',
                    value: item.application,
                    maxLines: 2,
                    onChanged: (val) {
                      item.application = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'ind_${item.hashCode}_example_role',
                    label: 'Example Professional Role',
                    value: item.exampleRole,
                    onChanged: (val) {
                      item.exampleRole = val;
                      prov.updateActiveContent(content);
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
            Text(
              'Chips List (${content.chips.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final idStr =
                    '${content.metadata.chapterNumber}_chip_${content.chips.length + 1}';
                content.chips.add(
                  ChipItem(
                    id: idStr,
                    title: 'New Chip',
                    preview: '',
                    paragraphs: [],
                    keyPoints: [],
                    aiEnabled: true,
                  ),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Chip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(chip),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Chip #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'AI Enabled',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          Checkbox(
                            value: chip.aiEnabled,
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            onChanged: (val) {
                              chip.aiEnabled = val ?? true;
                              prov.updateActiveContent(content);
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
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
                          key: 'chip_${chip.hashCode}_id',
                          label: 'Unique ID',
                          value: chip.id,
                          onChanged: (val) {
                            chip.id = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          key: 'chip_${chip.hashCode}_title',
                          label: 'Chip Title',
                          value: chip.title,
                          onChanged: (val) {
                            chip.title = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    key: 'chip_${chip.hashCode}_preview',
                    label: 'Preview text',
                    value: chip.preview,
                    maxLines: 2,
                    onChanged: (val) {
                      chip.preview = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'chip_${chip.hashCode}_paragraphs',
                    label: 'Detailed Paragraphs (One per line)',
                    value: chip.paragraphs.join('\n'),
                    maxLines: 4,
                    onChanged: (val) {
                      chip.paragraphs = val
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList();
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'chip_${chip.hashCode}_key_points',
                    label: 'Key points summary (One per line)',
                    value: chip.keyPoints.join('\n'),
                    maxLines: 4,
                    onChanged: (val) {
                      chip.keyPoints = val
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList();
                      prov.updateActiveContent(content);
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
            Text(
              'Topics list (${content.plusPoints.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final idStr =
                    '${content.metadata.chapterNumber}.${content.plusPoints.length + 1}';
                content.plusPoints.add(
                  PlusPointTopic(
                    id: idStr,
                    title: 'New Topic',
                    summary: '',
                    keyFacts: [],
                    commonMistake: '',
                    aiEnabled: true,
                    evaluationReady: true,
                  ),
                );
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Topic'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(topic),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Topic #${idx + 1}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'AI Mode',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          Checkbox(
                            value: topic.aiEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              topic.aiEnabled = val ?? true;
                              prov.updateActiveContent(content);
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Eval Ready',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          Checkbox(
                            value: topic.evaluationReady,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              topic.evaluationReady = val ?? true;
                              prov.updateActiveContent(content);
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
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
                          key: 'plus_${topic.hashCode}_id',
                          label: 'Unique Section Code ID',
                          value: topic.id,
                          onChanged: (val) {
                            topic.id = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          key: 'plus_${topic.hashCode}_title',
                          label: 'Topic Title',
                          value: topic.title,
                          onChanged: (val) {
                            topic.title = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    key: 'plus_${topic.hashCode}_summary',
                    label: 'Summary explanation',
                    value: topic.summary,
                    maxLines: 2,
                    onChanged: (val) {
                      topic.summary = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'plus_${topic.hashCode}_key_facts',
                    label: 'Key Facts / Checkpoints (One per line)',
                    value: topic.keyFacts.join('\n'),
                    maxLines: 4,
                    onChanged: (val) {
                      topic.keyFacts = val
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList();
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'plus_${topic.hashCode}_common_mistake',
                    label: 'Common Student Mistakes / Pitfalls',
                    value: topic.commonMistake,
                    maxLines: 2,
                    onChanged: (val) {
                      topic.commonMistake = val;
                      prov.updateActiveContent(content);
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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quiz Settings',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      key: 'quiz_settings_title',
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
                      key: 'quiz_settings_passing_score',
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
                      key: 'quiz_settings_time_limit',
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
                key: 'quiz_settings_instructions',
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
            Text(
              'Questions list (${content.quiz.questions.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              key: ValueKey(q),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Question #${idx + 1} (ID: ${q.id})',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.error,
                          size: 18,
                        ),
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
                          key: 'quiz_${q.hashCode}_question_id',
                          label: 'Question ID (Number)',
                          value: q.id.toString(),
                          isNumeric: true,
                          onChanged: (val) {
                            q.id = int.tryParse(val) ?? q.id;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          key: 'quiz_${q.hashCode}_concept',
                          label: 'Tested Concept name',
                          value: q.concept,
                          onChanged: (val) {
                            q.concept = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Difficulty',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: q.difficulty,
                                  dropdownColor: AppColors.card,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                  items: ['easy', 'medium', 'hard'].map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(d.toUpperCase()),
                                    );
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
                    key: 'quiz_${q.hashCode}_question_text',
                    label: 'Question Text',
                    value: q.questionText,
                    maxLines: 2,
                    onChanged: (val) {
                      q.questionText = val;
                      prov.updateActiveContent(content);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Answers Options & Correct Choice',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                                ? AppColors.success
                                : AppColors.divider,
                          ),
                          child: Text(
                            opt.key,
                            style: TextStyle(
                              color: q.correctAnswer == opt.key
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFormField(
                            key: 'quiz_${q.hashCode}_option_${opt.key}',
                            label: 'Option ${opt.key} Text',
                            value: opt.text,
                            onChanged: (val) {
                              opt.text = val;
                              prov.updateActiveContent(content);
                            },
                          ),
                        ),
                        Radio<String>(
                          value: opt.key,
                          groupValue: q.correctAnswer,
                          activeColor: AppColors.success,
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
                    key: 'quiz_${q.hashCode}_explanation',
                    label: 'Explanation on Correct Option',
                    value: q.explanation,
                    maxLines: 2,
                    onChanged: (val) {
                      q.explanation = val;
                      prov.updateActiveContent(content);
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
            content: Text(
              'Chapter content successfully published to Firebase RTDB!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish content: $e'),
            backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.card,
          title: Text(
            'Confirm Database Deletion',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to permanently delete the content payload for Chapter ${prov.selectedChapterNumber} from Firebase? This action cannot be undone.',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
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
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete content: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }
}

class UrlUploadField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onUploadPressed;
  final bool isUploading;

  const UrlUploadField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onUploadPressed,
    required this.isUploading,
  });

  @override
  State<UrlUploadField> createState() => _UrlUploadFieldState();
}

class _UrlUploadFieldState extends State<UrlUploadField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant UrlUploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'https://h5p.org/h5p/embed/123456',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: widget.isUploading ? null : widget.onUploadPressed,
                icon: widget.isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined, size: 16),
                label: Text(
                  widget.isUploading ? 'Uploading...' : 'Upload HTML',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
