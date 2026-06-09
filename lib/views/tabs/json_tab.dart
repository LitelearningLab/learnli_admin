import 'dart:convert';
import 'dart:html' as html; // Safe since the user requested Flutter Web exclusively
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../constants/app_colors.dart';

class JsonTab extends StatefulWidget {
  const JsonTab({super.key});

  @override
  State<JsonTab> createState() => _JsonTabState();
}

class _JsonTabState extends State<JsonTab> {
  final _textController = TextEditingController();
  String? _validationError;
  bool _isValidated = false;
  bool _isUploading = false;
  bool _isBulkSeedJson = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickJsonFile(AdminProvider prov) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final content = utf8.decode(bytes);
        
        setState(() {
          _textController.text = content;
          _isValidated = false;
          _validationError = null;
        });

        prov.updateJsonString(content);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${result.files.single.name} successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to read file'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _validateJson(AdminProvider prov) {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) {
      setState(() {
        _validationError = 'JSON string cannot be empty.';
        _isValidated = false;
        _isBulkSeedJson = false;
      });
      return;
    }

    // Check if it's a bulk backup JSON containing careers or content key
    try {
      final decoded = json.decode(rawText);
      if (decoded is Map<String, dynamic> &&
          (decoded.containsKey('careers') || decoded.containsKey('content'))) {
        setState(() {
          _validationError = null;
          _isValidated = true;
          _isBulkSeedJson = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bulk Database JSON validated successfully! Ready to seed.'),
            backgroundColor: AppColors.success,
          ),
        );
        return;
      }
    } catch (_) {
      // Ignore exception here and fallback to regular chapter content validation
    }

    final error = prov.validateAndImportJson(rawText);
    setState(() {
      _isBulkSeedJson = false;
      if (error != null) {
        _validationError = error;
        _isValidated = false;
      } else {
        _validationError = null;
        _isValidated = true;
        // Format text with indent
        _textController.text = prov.jsonString;
      }
    });

    if (_isValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON validated and loaded successfully! Ready to save.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _downloadJsonFile(AdminProvider prov) {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) return;

    final fileName = 'G${prov.selectedGradeKey?.replaceAll('grade_', '')}_${prov.selectedSubjectId}_CH${prov.selectedChapterNumber.toString().padLeft(2, '0')}.json';
    
    try {
      final bytes = utf8.encode(rawText);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported file: $fileName'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download file'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _uploadToFirebase(AdminProvider prov) async {
    // Force a validation check first
    _validateJson(prov);
    if (!_isValidated) return;

    setState(() {
      _isUploading = true;
    });

    try {
      if (_isBulkSeedJson) {
        final rawText = _textController.text.trim();
        final decoded = json.decode(rawText) as Map<String, dynamic>;
        await prov.seedDatabase(decoded);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database seeded successfully (Careers & Chapter Contents)!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        await prov.saveChapterContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chapter content successfully published to Firebase Realtime DB!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save to Firebase: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final curriculum = adminProv.curriculum;
    
    // Sync text area when chapter selection triggers load
    if (adminProv.selectedChapterNumber != null && 
        adminProv.jsonString.isNotEmpty && 
        _textController.text != adminProv.jsonString &&
        !_isValidated && _validationError == null) {
      _textController.text = adminProv.jsonString;
    }

    // Dropdown options
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
        // Dropdown selection panel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider,
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
                    Text('Select Grade', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: adminProv.selectedGradeKey,
                          hint: const Text('Choose Grade', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          dropdownColor: AppColors.card,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
                              _isValidated = false;
                              _validationError = null;
                              _textController.clear();
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
                    Text('Select Subject', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: adminProv.selectedSubjectId,
                          hint: const Text('Choose Subject', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          dropdownColor: AppColors.card,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          items: subjectsList.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.emoji} ${s.name}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            adminProv.selectSubject(val);
                            setState(() {
                              _isValidated = false;
                              _validationError = null;
                              _textController.clear();
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
                    Text('Select Chapter', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: adminProv.selectedChapterNumber,
                          hint: const Text('Choose Chapter', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          dropdownColor: AppColors.card,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          items: chaptersList.map((c) {
                            return DropdownMenuItem(
                              value: c.number,
                              child: Text('Ch ${c.number}: ${c.title}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            adminProv.selectChapter(val);
                            setState(() {
                              _isValidated = false;
                              _validationError = null;
                              _textController.clear();
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

        // Main Editor Pane
        Expanded(
          child: adminProv.selectedChapterNumber == null
              ? _buildEmptyState()
              : adminProv.isLoadingContent
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Downloading chapter payload from DB...', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Toolbar Actions
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickJsonFile(adminProv),
                                icon: const Icon(Icons.file_upload_outlined, size: 16),
                                label: const Text('Upload local JSON File'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () => _downloadJsonFile(adminProv),
                                icon: const Icon(Icons.file_download_outlined, size: 16),
                                label: const Text('Export / Download JSON'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _validateJson(adminProv),
                                icon: const Icon(Icons.spellcheck, size: 16),
                                label: const Text('Validate & Format'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _isUploading ? null : () => _uploadToFirebase(adminProv),
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.cloud_upload_outlined, size: 16),
                                label: Text(_isUploading ? 'Uploading...' : (_isBulkSeedJson ? 'Seed Firebase Database' : 'Save to Firebase DB')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Error Panel
                          if (_validationError != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _validationError!,
                                      style: GoogleFonts.inter(color: AppColors.error, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Large Raw JSON Editor TextArea
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: TextFormField(
                                controller: _textController,
                                maxLines: null,
                                minLines: null,
                                keyboardType: TextInputType.multiline,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 13,
                                  color: AppColors.success,
                                  height: 1.5,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(24),
                                  border: InputBorder.none,
                                  hintText: '{\n  "metadata": { ... },\n  "sections": { ... }\n}',
                                  hintStyle: TextStyle(color: AppColors.textMuted),
                                ),
                                onChanged: (val) {
                                  adminProv.updateJsonString(val);
                                  setState(() {
                                    _isValidated = false;
                                    _validationError = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
              Icons.code,
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
              'Select a Grade, Subject, and Chapter to open the JSON Editor and import/export raw files.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
