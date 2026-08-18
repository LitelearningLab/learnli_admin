import 'dart:convert';
import '../../utils/json_export_helper.dart';
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
    'Pre-requisite Concepts',
    'Industry Insights',
    'AI Learning Chips',
    'Plus Points Topics',
    'Quiz & Questions',
    'Pronunciation Lab',
    'Plus Point Question Bank',
  ];

  bool _isUploadingHtml = false;
  bool _isUploadingSimpleOverviewHtml = false;
  final Map<int, bool> _isUploadingDiagramHtmlMap = {};
  final Map<int, bool> _isUploadingDiagramThumbnailMap = {};

  Future<String?> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final name = result.files.single.name;

        final downloadUrl = await DatabaseService.uploadImageFile(name, bytes);
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'Editing content for '),
                                  TextSpan(
                                    text:
                                        'Grade ${adminProv.selectedGradeKey?.replaceAll('grade_', '')} > ${adminProv.selectedSubjectId?.toUpperCase()} > Ch ${adminProv.selectedChapterNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        '. Changes here apply to the selected chapter\'s lessons. Structural hierarchy changes are published using the bottom button.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            Tooltip(
                              message:
                                  'Publishes lesson content (Read Mode, Quizzes, etc.) for this chapter. Structure layout is published at the bottom.',
                              child: ElevatedButton.icon(
                                onPressed: adminProv.isLoadingContent
                                    ? null
                                    : () => _handleSave(adminProv),
                                icon: adminProv.isLoadingContent
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.cloud_done_outlined,
                                        size: 14,
                                      ),
                                label: Text(
                                  adminProv.isLoadingContent
                                      ? 'Publishing Content...'
                                      : 'Publish Lesson Content',
                                  style: const TextStyle(fontSize: 12),
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
                            ),
                            const SizedBox(width: 8),
                            // Delete Button
                            OutlinedButton.icon(
                              onPressed: adminProv.isLoadingContent
                                  ? null
                                  : () => _handleDelete(adminProv),
                              icon: const Icon(Icons.delete_outline, size: 14),
                              label: const Text(
                                'Clear Lesson Content',
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

  Future<String?> _showUploadModeDialog(
    BuildContext context,
    String sectionName,
    int incomingCount,
    int existingCount,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Bulk Upload - $sectionName',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are uploading $incomingCount items. There are currently $existingCount items in this section.',
                style: GoogleFonts.inter(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'How would you like to apply the uploaded data?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Replace: Clears all $existingCount existing items and imports only the $incomingCount uploaded items (useful for re-uploading edited files).',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '• Merge: Keeps the existing items and appends the $incomingCount new items to the end of the list.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('merge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Merge (Keep Existing)',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('replace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Replace Existing',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleBulkUpload({
    required BuildContext context,
    required AdminProvider prov,
    required ChapterContent content,
    required String sectionName,
    required String mapKey,
    required List<String> alternativeMapKeys,
    required int existingCount,
    required Function() onClear,
    required Function(List<dynamic>) onDataLoaded,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final rawText = utf8.decode(bytes);
        final decoded = json.decode(rawText);

        List<dynamic>? list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final possibleKeys = [mapKey, ...alternativeMapKeys, 'data', 'items'];
          for (var key in possibleKeys) {
            if (decoded.containsKey(key) && decoded[key] is List) {
              list = decoded[key] as List;
              break;
            }
          }
          if (list == null && decoded.containsKey('sub_topics') && decoded['sub_topics'] is List) {
            final subTopics = decoded['sub_topics'] as List;
            final flatList = <dynamic>[];
            for (var subTopic in subTopics) {
              if (subTopic is Map) {
                for (var key in possibleKeys) {
                  if (subTopic.containsKey(key) && subTopic[key] is List) {
                    flatList.addAll(subTopic[key] as List);
                    break;
                  }
                }
              }
            }
            if (flatList.isNotEmpty) {
              list = flatList;
            }
          }
        }

        if (list == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid JSON format. Expected a List or a Map containing a List under "$mapKey".',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        if (!context.mounted) return;

        final mode = await _showUploadModeDialog(
          context,
          sectionName,
          list.length,
          existingCount,
        );
        if (mode == null || mode == 'cancel') {
          return;
        }

        if (mode == 'replace') {
          onClear();
        }

        onDataLoaded(list);
        prov.updateActiveContent(content);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully ${mode == 'replace' ? 'replaced with' : 'merged'} ${list.length} items for $sectionName!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse JSON: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleExport({
    required BuildContext context,
    required List<dynamic> list,
    required String fileName,
  }) {
    try {
      final jsonList = list.map((item) {
        try {
          return (item as dynamic).toJson();
        } catch (_) {
          return item;
        }
      }).toList();

      final encoder = const JsonEncoder.withIndent('  ');
      final rawText = encoder.convert(jsonList);
      downloadJsonFile(rawText, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported successfully as $fileName'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getExportFileName(ChapterContent content, String sectionName) {
    final grade = content.metadata.grade;
    final subject = content.metadata.subject.replaceAll(' ', '_').toLowerCase();
    final chNum = content.metadata.chapterNumber.toString().padLeft(2, '0');
    return 'G${grade}_${subject}_CH${chNum}_$sectionName.json';
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
      case 2: // Pre-requisite
        return _buildPrerequisiteForm(prov, active);
      case 3: // Industry Insights
        return _buildIndustryForm(prov, active);
      case 4: // AI Chips
        return _buildChipsForm(prov, active);
      case 5: // Plus Points
        return _buildPlusPointsForm(prov, active);
      case 6: // Quiz
        return _buildQuizForm(prov, active);
      case 7: // Pronunciation Lab
        return _buildPronunciationForm(prov, active);
      case 8: // Plus Point QB
        return _buildPlusPointQBForm(prov, active);
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Interactive Diagrams (${(content.metadata.interactiveDiagrams ?? []).length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final list = content.metadata.interactiveDiagrams ?? [];
                int maxNum = 0;
                for (final d in list) {
                  final parts = d.id.split('_');
                  if (parts.length == 2) {
                    final num = int.tryParse(parts[1]);
                    if (num != null && num > maxNum) {
                      maxNum = num;
                    }
                  }
                }
                final newId =
                    'diagram_${(maxNum + 1).toString().padLeft(3, '0')}';
                list.add(
                  InteractiveDiagram(
                    id: newId,
                    title: 'New Diagram',
                    thumbnail: '',
                    url: '',
                  ),
                );
                content.metadata.interactiveDiagrams = list;
                prov.updateActiveContent(content);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Diagram'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (content.metadata.interactiveDiagrams != null &&
            content.metadata.interactiveDiagrams!.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: content.metadata.interactiveDiagrams!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final diagram = content.metadata.interactiveDiagrams![idx];
              return Container(
                padding: const EdgeInsets.all(16),
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
                          'Diagram #${idx + 1}',
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
                            content.metadata.interactiveDiagrams!.removeAt(idx);
                            prov.updateActiveContent(content);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFormField(
                      key: 'diagram_title_$idx',
                      label: 'Title',
                      value: diagram.title,
                      onChanged: (val) {
                        diagram.title = val.trim();
                        prov.updateActiveContent(content);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildUrlFormField(
                      key: 'diagram_thumb_$idx',
                      label: 'Thumbnail URL',
                      value: diagram.thumbnail,
                      isUploading:
                          _isUploadingDiagramThumbnailMap[idx] ?? false,
                      onChanged: (val) {
                        diagram.thumbnail = val.trim();
                        prov.updateActiveContent(content);
                      },
                      onUploadPressed: () async {
                        setState(() {
                          _isUploadingDiagramThumbnailMap[idx] = true;
                        });
                        try {
                          final fileUrl = await _pickAndUploadImage();
                          if (fileUrl != null) {
                            diagram.thumbnail = fileUrl;
                            prov.updateActiveContent(content);
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingDiagramThumbnailMap[idx] = false;
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildUrlFormField(
                      key: 'diagram_url_$idx',
                      label: 'Interactive HTML URL',
                      value: diagram.url,
                      isUploading: _isUploadingDiagramHtmlMap[idx] ?? false,
                      onChanged: (val) {
                        diagram.url = val.trim();
                        prov.updateActiveContent(content);
                      },
                      onUploadPressed: () async {
                        setState(() {
                          _isUploadingDiagramHtmlMap[idx] = true;
                        });
                        try {
                          final fileUrl = await _pickAndUploadHtml();
                          if (fileUrl != null) {
                            diagram.url = fileUrl;
                            prov.updateActiveContent(content);
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingDiagramHtmlMap[idx] = false;
                            });
                          }
                        }
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

  // 2. Simple Overview Form
  Widget _buildSimpleOverviewForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Simple Overview HTML File',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload an HTML file containing the simple overview of this chapter.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        _buildUrlFormField(
          key: 'simple_overview_html_url',
          label: 'Simple Overview HTML URL',
          value: content.simpleOverviewUrl ?? '',
          isUploading: _isUploadingSimpleOverviewHtml,
          onChanged: (val) {
            content.simpleOverviewUrl = val.trim().isEmpty ? null : val.trim();
            prov.updateActiveContent(content);
          },
          onUploadPressed: () async {
            setState(() {
              _isUploadingSimpleOverviewHtml = true;
            });
            try {
              final fileUrl = await _pickAndUploadHtml();
              if (fileUrl != null) {
                content.simpleOverviewUrl = fileUrl;
                prov.updateActiveContent(content);
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isUploadingSimpleOverviewHtml = false;
                });
              }
            }
          },
        ),
      ],
    );
  }

  // 3. Pre-requisite Form
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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
                ElevatedButton.icon(
                  onPressed: () => _handleBulkUpload(
                    context: context,
                    prov: prov,
                    content: content,
                    sectionName: 'Prerequisites',
                    mapKey: 'pre_requisite',
                    alternativeMapKeys: ['preRequisite', 'prerequisites'],
                    existingCount: content.preRequisite.length,
                    onClear: () => content.preRequisite.clear(),
                    onDataLoaded: (list) {
                      content.preRequisite.addAll(
                        list
                            .map(
                              (item) => PreRequisiteItem.fromJson(
                                Map<String, dynamic>.from(item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExport(
                    context: context,
                    list: content.preRequisite,
                    fileName: _getExportFileName(content, 'prerequisites'),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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

  // 4. Industry Insights Form
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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
                ElevatedButton.icon(
                  onPressed: () => _handleBulkUpload(
                    context: context,
                    prov: prov,
                    content: content,
                    sectionName: 'Industry Insights',
                    mapKey: 'industry_insights',
                    alternativeMapKeys: [
                      'industryInsights',
                      'industry_insights_list',
                    ],
                    existingCount: content.industryInsights.length,
                    onClear: () => content.industryInsights.clear(),
                    onDataLoaded: (list) {
                      content.industryInsights.addAll(
                        list
                            .map(
                              (item) => IndustryInsightItem.fromJson(
                                Map<String, dynamic>.from(item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExport(
                    context: context,
                    list: content.industryInsights,
                    fileName: _getExportFileName(content, 'industry_insights'),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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

  // 5. AI Learning Chips Form
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final idStr =
                        '${content.metadata.chapterNumber}_chip_${content.chips.length + 1}';
                    content.chips.add(
                      ChipItem(
                        id: idStr,
                        title: 'New Chip',
                        preview: '',
                        subtopics: [],
                        aiEnabled: true,
                        evaluationReady: true,
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
                ElevatedButton.icon(
                  onPressed: () => _handleBulkUpload(
                    context: context,
                    prov: prov,
                    content: content,
                    sectionName: 'AI Chips',
                    mapKey: 'chips',
                    alternativeMapKeys: ['ai_chips', 'aiChips', 'items'],
                    existingCount: content.chips.length,
                    onClear: () => content.chips.clear(),
                    onDataLoaded: (list) {
                      content.chips.addAll(
                        list
                            .map(
                              (item) => ChipItem.fromJson(
                                Map<String, dynamic>.from(item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExport(
                    context: context,
                    list: content.chips,
                    fileName: _getExportFileName(content, 'chips'),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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
                          const SizedBox(width: 12),
                          const Text(
                            'Eval Ready',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          Checkbox(
                            value: chip.evaluationReady,
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            onChanged: (val) {
                              chip.evaluationReady = val ?? true;
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
                  const Divider(color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtopics (${chip.subtopics.length})',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            chip.subtopics.add(
                              SubtopicItem(
                                id: '${chip.id}.${chip.subtopics.length + 1}',
                                title: 'New Subtopic',
                                explanation: SubtopicExplanation(paragraphs: [], keyPoints: []),
                                fillInTheBlanks: [],
                                patternBasedQuestions: [],
                              ),
                            );
                            prov.updateActiveContent(content);
                          },
                          icon: const Icon(Icons.add, size: 12),
                          label: const Text('Add Subtopic', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chip.subtopics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, sIdx) {
                      final subtopic = chip.subtopics[sIdx];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Subtopic #${sIdx + 1}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                                  onPressed: () {
                                    chip.subtopics.removeAt(sIdx);
                                    prov.updateActiveContent(content);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    key: 'subtopic_${subtopic.hashCode}_id',
                                    label: 'Subtopic ID',
                                    value: subtopic.id,
                                    onChanged: (val) {
                                      subtopic.id = val;
                                      prov.updateActiveContent(content);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFormField(
                                    key: 'subtopic_${subtopic.hashCode}_title',
                                    label: 'Subtopic Title',
                                    value: subtopic.title,
                                    onChanged: (val) {
                                      subtopic.title = val;
                                      prov.updateActiveContent(content);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            _buildFormField(
                              key: 'subtopic_${subtopic.hashCode}_paragraphs',
                              label: 'Detailed Paragraphs (One per line)',
                              value: subtopic.explanation.paragraphs.join('\n'),
                              maxLines: 3,
                              onChanged: (val) {
                                subtopic.explanation.paragraphs = val
                                    .split('\n')
                                    .where((line) => line.trim().isNotEmpty)
                                    .toList();
                                prov.updateActiveContent(content);
                              },
                            ),
                            _buildFormField(
                              key: 'subtopic_${subtopic.hashCode}_key_points',
                              label: 'Key Points (One per line)',
                              value: subtopic.explanation.keyPoints.join('\n'),
                              maxLines: 3,
                              onChanged: (val) {
                                subtopic.explanation.keyPoints = val
                                    .split('\n')
                                    .where((line) => line.trim().isNotEmpty)
                                    .toList();
                                prov.updateActiveContent(content);
                              },
                            ),
                            const Divider(color: AppColors.divider),
                            
                            // Fill-in-the-Blanks section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fill in the Blanks (${subtopic.fillInTheBlanks.length})',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    subtopic.fillInTheBlanks.add(
                                      FillInTheBlankItem(question: '', answer: ''),
                                    );
                                    prov.updateActiveContent(content);
                                  },
                                  icon: const Icon(Icons.add, size: 14),
                                  label: const Text('Add Blank', style: TextStyle(fontSize: 11)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: subtopic.fillInTheBlanks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, fibIdx) {
                                final fib = subtopic.fillInTheBlanks[fibIdx];
                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        key: ValueKey('subtopic_${subtopic.hashCode}_fib_q_$fibIdx'),
                                        initialValue: fib.question,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Question (Latex support e.g. \\int x^n\\,dx = ...)',
                                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onChanged: (val) {
                                          fib.question = val;
                                          prov.updateActiveContent(content);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        key: ValueKey('subtopic_${subtopic.hashCode}_fib_a_$fibIdx'),
                                        initialValue: fib.answer,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Answer (e.g. n+1)',
                                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onChanged: (val) {
                                          fib.answer = val;
                                          prov.updateActiveContent(content);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                                      onPressed: () {
                                        subtopic.fillInTheBlanks.removeAt(fibIdx);
                                        prov.updateActiveContent(content);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.divider),
                            
                            // Pattern-Based Questions section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pattern-Based Questions (${subtopic.patternBasedQuestions.length})',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    subtopic.patternBasedQuestions.add(
                                      PatternBasedQuestionItem(pattern: '', question: '', answer: ''),
                                    );
                                    prov.updateActiveContent(content);
                                  },
                                  icon: const Icon(Icons.add, size: 14),
                                  label: const Text('Add Pattern-Based', style: TextStyle(fontSize: 11)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: subtopic.patternBasedQuestions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, pbqIdx) {
                                final pbq = subtopic.patternBasedQuestions[pbqIdx];
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            key: ValueKey('subtopic_${subtopic.hashCode}_pbq_p_$pbqIdx'),
                                            initialValue: pbq.pattern,
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Pattern (e.g. Complete the calculation)',
                                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            onChanged: (val) {
                                              pbq.pattern = val;
                                              prov.updateActiveContent(content);
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                                          onPressed: () {
                                            subtopic.patternBasedQuestions.removeAt(pbqIdx);
                                            prov.updateActiveContent(content);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            key: ValueKey('subtopic_${subtopic.hashCode}_pbq_q_$pbqIdx'),
                                            initialValue: pbq.question,
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Question (Latex support)',
                                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            onChanged: (val) {
                                              pbq.question = val;
                                              prov.updateActiveContent(content);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            key: ValueKey('subtopic_${subtopic.hashCode}_pbq_a_$pbqIdx'),
                                            initialValue: pbq.answer,
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Answer (e.g. 4)',
                                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            onChanged: (val) {
                                              pbq.answer = val;
                                              prov.updateActiveContent(content);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 40), // Spacer matching the delete button width
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
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

  // 6. Plus Points Form
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final idStr =
                        '${content.metadata.chapterNumber}.${content.plusPoints.length + 1}';
                    content.plusPoints.add(
                      PlusPointTopic(
                        id: idStr,
                        title: 'New Topic',
                        keyFacts: [],
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
                ElevatedButton.icon(
                  onPressed: () => _handleBulkUpload(
                    context: context,
                    prov: prov,
                    content: content,
                    sectionName: 'Plus Points Topics',
                    mapKey: 'plus_points',
                    alternativeMapKeys: ['plusPoints', 'topics', 'items'],
                    existingCount: content.plusPoints.length,
                    onClear: () => content.plusPoints.clear(),
                    onDataLoaded: (list) {
                      content.plusPoints.addAll(
                        list
                            .map(
                              (item) => PlusPointTopic.fromJson(
                                Map<String, dynamic>.from(item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExport(
                    context: context,
                    list: content.plusPoints,
                    fileName: _getExportFileName(content, 'plus_points'),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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

                  // Key Facts / Checkpoints Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Key Facts / Checkpoints (${topic.keyFacts.length})',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            topic.keyFacts.add(KeyFact(title: ''));
                            prov.updateActiveContent(content);
                          },
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text(
                            'Add Checkpoint / Fact',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topic.keyFacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, fIdx) {
                      final fact = topic.keyFacts[fIdx];
                      return Row(
                        children: [
                          // ID Field
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              key: ValueKey('fact_${fact.hashCode}_id'),
                              initialValue: fact.id ?? '',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ID (e.g. 7.2.1)',
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                                filled: true,
                                fillColor: AppColors.card,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                fact.id = val.trim().isEmpty
                                    ? null
                                    : val.trim();
                                prov.updateActiveContent(content);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Title / Fact text field
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('fact_${fact.hashCode}_title'),
                              initialValue: fact.title,
                              maxLines: null,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Fact description / Title',
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                                filled: true,
                                fillColor: AppColors.card,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                fact.title = val;
                                prov.updateActiveContent(content);
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              topic.keyFacts.removeAt(fIdx);
                              prov.updateActiveContent(content);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 7. Quiz and Questions Form
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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
                ElevatedButton.icon(
                  onPressed: () => _handleBulkUpload(
                    context: context,
                    prov: prov,
                    content: content,
                    sectionName: 'Quiz Questions',
                    mapKey: 'questions',
                    alternativeMapKeys: ['quiz_questions', 'quizQuestions'],
                    existingCount: content.quiz.questions.length,
                    onClear: () => content.quiz.questions.clear(),
                    onDataLoaded: (list) {
                      content.quiz.questions.addAll(
                        list
                            .map(
                              (item) => QuizQuestion.fromJson(
                                Map<String, dynamic>.from(item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExport(
                    context: context,
                    list: content.quiz.questions,
                    fileName: _getExportFileName(content, 'quiz_questions'),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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

  // 8. Pronunciation Lab Form
  Widget _buildPronunciationForm(AdminProvider prov, ChapterContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vocabulary list (${content.pronunciationLab.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    content.pronunciationLab.insert(
                      0,
                      PronunciationWord(
                        text: 'newword',
                        pronun: '',
                        syllables: '',
                        sentenceSamples: [],
                        meaningSamples: [],
                      ),
                    );
                    prov.updateActiveContent(content);
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Vocabulary Word'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleBulkUpload(
                    context: context,
                    prov: prov,
                    content: content,
                    sectionName: 'Pronunciation Lab',
                    mapKey: 'pronunciation_lab',
                    alternativeMapKeys: ['pronunciationLab', 'words', 'items'],
                    existingCount: content.pronunciationLab.length,
                    onClear: () => content.pronunciationLab.clear(),
                    onDataLoaded: (list) {
                      content.pronunciationLab.addAll(
                        list
                            .map(
                              (item) => PronunciationWord.fromJson(
                                Map<String, dynamic>.from(item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExport(
                    context: context,
                    list: content.pronunciationLab,
                    fileName: _getExportFileName(content, 'pronunciation_lab'),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.pronunciationLab.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            final item = content.pronunciationLab[idx];
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
                        'Word #${idx + 1}',
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
                          content.pronunciationLab.removeAt(idx);
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
                          key: 'pron_${item.hashCode}_text',
                          label: 'Word',
                          value: item.text,
                          onChanged: (val) {
                            item.text = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          key: 'pron_${item.hashCode}_pronun',
                          label: 'Pronunciation Guide (Phonetic)',
                          value: item.pronun,
                          onChanged: (val) {
                            item.pronun = val;
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
                          key: 'pron_${item.hashCode}_syllables',
                          label:
                              'Syllables breakdown (hyphen-separated, e.g. nu-tri-tion)',
                          value: item.syllables,
                          onChanged: (val) {
                            item.syllables = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority Status',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value:
                                  item.isPriority == 'true' ||
                                      item.downloadStatus
                                  ? 'true'
                                  : 'false',
                              items: const [
                                DropdownMenuItem(
                                  value: 'false',
                                  child: Text('Regular Vocabulary'),
                                ),
                                DropdownMenuItem(
                                  value: 'true',
                                  child: Text('Priority (Starred)'),
                                ),
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.card,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                item.isPriority = val ?? 'false';
                                item.downloadStatus = val == 'true';
                                prov.updateActiveContent(content);
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    key: 'pron_${item.hashCode}_meanings',
                    label: 'Meanings (One meaning per line)',
                    value: item.meaningSamples.join('\n'),
                    maxLines: 3,
                    hint: 'Definition of the word...',
                    onChanged: (val) {
                      item.meaningSamples = val
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList();
                      prov.updateActiveContent(content);
                    },
                  ),
                  _buildFormField(
                    key: 'pron_${item.hashCode}_sentences',
                    label: 'Usage Examples / Sentences (One sentence per line)',
                    value: item.sentenceSamples.join('\n'),
                    maxLines: 3,
                    hint: 'Example sentence using the word...',
                    onChanged: (val) {
                      item.sentenceSamples = val
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

  // 9. Plus Point Question Bank Form
  Widget _buildPlusPointQBForm(AdminProvider prov, ChapterContent content) {
    final qb = content.plusPointQuestionBank;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Patterns list (${qb.patterns.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final nextPatternNum = (qb.patterns.length + 1)
                        .toString()
                        .padLeft(2, '0');
                    final newPatternId =
                        '${content.metadata.chapterNumber}.2.$nextPatternNum';
                    qb.patterns.add(
                      PlusPointPattern(
                        id: newPatternId,
                        conceptId: '${content.metadata.chapterNumber}.2',
                        conceptName: 'New Concept Name',
                        patternNumber: nextPatternNum,
                        patternName: 'New Pattern Name',
                        marks: 2,
                        questions: [],
                      ),
                    );
                    prov.updateActiveContent(content);
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Pattern'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleQBBulkUpload(context, prov, content),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleQBExport(context, content),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // List of Patterns
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: qb.patterns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 32),
          itemBuilder: (context, pIdx) {
            final pattern = qb.patterns[pIdx];
            return Container(
              key: ValueKey(pattern),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pattern header row
                  Row(
                    children: [
                      Text(
                        'Pattern #${pIdx + 1}: ${pattern.patternName.isNotEmpty ? pattern.patternName : "Unnamed Pattern"}${pattern.marks != null ? " (${pattern.marks} Marks)" : ""}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                          qb.patterns.removeAt(pIdx);
                          prov.updateActiveContent(content);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pattern input fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          key: 'pattern_id_$pIdx',
                          label: 'Pattern ID',
                          value: pattern.id,
                          onChanged: (val) {
                            pattern.id = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          key: 'pattern_concept_id_$pIdx',
                          label: 'Concept ID',
                          value: pattern.conceptId,
                          onChanged: (val) {
                            pattern.conceptId = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          key: 'pattern_number_$pIdx',
                          label: 'Pattern Number',
                          value: pattern.patternNumber,
                          onChanged: (val) {
                            pattern.patternNumber = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildFormField(
                          key: 'pattern_concept_name_$pIdx',
                          label: 'Concept Name',
                          value: pattern.conceptName,
                          onChanged: (val) {
                            pattern.conceptName = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildFormField(
                          key: 'pattern_name_$pIdx',
                          label: 'Pattern Name',
                          value: pattern.patternName,
                          onChanged: (val) {
                            pattern.patternName = val;
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildFormField(
                          key: 'pattern_marks_$pIdx',
                          label: 'Marks',
                          value: pattern.marks?.toString() ?? '',
                          isNumeric: true,
                          hint: 'e.g. 2, 5, 10',
                          onChanged: (val) {
                            pattern.marks = int.tryParse(val);
                            prov.updateActiveContent(content);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Questions Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions (${pattern.questions.length})',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          pattern.questions.add(
                            PlusPointQuestion(
                              questionNumber: pattern.questions.length + 1,
                              instruction: 'Find the antiderivative of',
                              equationLatex: '',
                              source: 'NCERT Textbook',
                            ),
                          );
                          prov.updateActiveContent(content);
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 14),
                        label: const Text(
                          'Add Question',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Questions List
                  if (pattern.questions.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        'No questions added to this pattern yet.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pattern.questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, qIdx) {
                        final question = pattern.questions[qIdx];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.15),
                                    child: Text(
                                      '${question.questionNumber}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Question Info',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.error,
                                      size: 16,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      pattern.questions.removeAt(qIdx);
                                      // Re-index question numbers
                                      for (
                                        int i = 0;
                                        i < pattern.questions.length;
                                        i++
                                      ) {
                                        pattern.questions[i].questionNumber =
                                            i + 1;
                                      }
                                      prov.updateActiveContent(content);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildFormField(
                                      key: 'pattern_${pIdx}_q_${qIdx}_num',
                                      label: 'Number',
                                      value: question.questionNumber.toString(),
                                      isNumeric: true,
                                      onChanged: (val) {
                                        question.questionNumber =
                                            int.tryParse(val) ??
                                            question.questionNumber;
                                        prov.updateActiveContent(content);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: _buildFormField(
                                      key: 'pattern_${pIdx}_q_${qIdx}_inst',
                                      label: 'Instruction',
                                      value: question.instruction,
                                      onChanged: (val) {
                                        question.instruction = val;
                                        prov.updateActiveContent(content);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildFormField(
                                      key: 'pattern_${pIdx}_q_${qIdx}_eq',
                                      label: 'Equation (LaTeX)',
                                      value: question.equationLatex,
                                      onChanged: (val) {
                                        question.equationLatex = val;
                                        prov.updateActiveContent(content);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: _buildFormField(
                                      key: 'pattern_${pIdx}_q_${qIdx}_src',
                                      label: 'Source',
                                      value: question.source,
                                      onChanged: (val) {
                                        question.source = val;
                                        prov.updateActiveContent(content);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
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

  Future<void> _handleQBBulkUpload(
    BuildContext context,
    AdminProvider prov,
    ChapterContent content,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final rawText = utf8.decode(bytes);
        final decoded = json.decode(rawText);

        if (decoded is! Map<String, dynamic>) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid JSON format. Expected a Map object.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        final incomingQB = PlusPointQuestionBank.fromJson(decoded);
        final incomingCount = incomingQB.patterns.length;
        final existingCount = content.plusPointQuestionBank.patterns.length;

        if (!context.mounted) return;

        final mode = await _showUploadModeDialog(
          context,
          'Plus Point Question Bank',
          incomingCount,
          existingCount,
        );
        if (mode == null || mode == 'cancel') {
          return;
        }

        if (mode == 'replace') {
          content.plusPointQuestionBank.chapterNumber =
              incomingQB.chapterNumber;
          content.plusPointQuestionBank.chapterName = incomingQB.chapterName;
          content.plusPointQuestionBank.patterns.clear();
        }

        content.plusPointQuestionBank.patterns.addAll(incomingQB.patterns);
        prov.updateActiveContent(content);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully ${mode == 'replace' ? 'replaced with' : 'merged'} ${incomingQB.patterns.length} patterns!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse JSON: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleQBExport(BuildContext context, ChapterContent content) {
    try {
      final qb = content.plusPointQuestionBank;
      final rawText = const JsonEncoder.withIndent('  ').convert(qb.toJson());
      downloadJsonFile(rawText, _getExportFileName(content, 'plus_point_qb'));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported successfully as ${_getExportFileName(content, 'plus_point_qb')}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
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
    _controller.removeListener(_onTextChanged);
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
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            tooltip: 'Clear URL',
                            onPressed: () {
                              _controller.clear();
                              widget.onChanged('');
                            },
                          )
                        : null,
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
