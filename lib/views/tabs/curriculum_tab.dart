import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/curriculum_models.dart';
import '../../models/chapter_content_model.dart';
import '../../constants/app_colors.dart';
import 'chapter_content_editor.dart';

class CurriculumTab extends StatefulWidget {
  const CurriculumTab({super.key});

  @override
  State<CurriculumTab> createState() => _CurriculumTabState();
}

class _CurriculumTabState extends State<CurriculumTab> {
  // Tree selection state
  String? _activeGradeKey;
  String? _activeSubjectId;
  int? _activeChapterNumber;
  String _selectedNodeType = ''; // 'grade', 'subject', 'chapter', ''

  // Form Controllers
  final _gradeNameController = TextEditingController();
  final _gradeDescController = TextEditingController();
  final _gradeEmojiController = TextEditingController();

  final _subjectIdController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final _subjectEmojiController = TextEditingController();
  final _subjectColorController = TextEditingController();

  final _chapterNumberController = TextEditingController();
  final _chapterTitleController = TextEditingController();

  bool _isSavingToDb = false;

  @override
  void dispose() {
    _gradeNameController.dispose();
    _gradeDescController.dispose();
    _gradeEmojiController.dispose();
    _subjectIdController.dispose();
    _subjectNameController.dispose();
    _subjectEmojiController.dispose();
    _subjectColorController.dispose();
    _chapterNumberController.dispose();
    _chapterTitleController.dispose();
    super.dispose();
  }

  void _selectGradeNode(String key, Grade grade) {
    setState(() {
      _activeGradeKey = key;
      _activeSubjectId = null;
      _activeChapterNumber = null;
      _selectedNodeType = 'grade';

      _gradeNameController.text = grade.name;
      _gradeDescController.text = grade.description;
      _gradeEmojiController.text = grade.emoji;
    });
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    adminProv.selectGrade(key);
  }

  void _selectSubjectNode(String gradeKey, Subject subject) {
    setState(() {
      _activeGradeKey = gradeKey;
      _activeSubjectId = subject.id;
      _activeChapterNumber = null;
      _selectedNodeType = 'subject';

      _subjectIdController.text = subject.id;
      _subjectNameController.text = subject.name;
      _subjectEmojiController.text = subject.emoji;
      _subjectColorController.text = subject.color;
    });
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    adminProv.selectGrade(gradeKey);
    adminProv.selectSubject(subject.id);
  }

  void _selectChapterNode(String gradeKey, String subjectId, Chapter chapter) {
    setState(() {
      _activeGradeKey = gradeKey;
      _activeSubjectId = subjectId;
      _activeChapterNumber = chapter.number;
      _selectedNodeType = 'chapter';

      _chapterNumberController.text = chapter.number.toString();
      _chapterTitleController.text = chapter.title;
    });
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    adminProv.selectGrade(gradeKey);
    adminProv.selectSubject(subjectId);
    adminProv.selectChapter(chapter.number);
  }

  void _clearSelection() {
    setState(() {
      _activeGradeKey = null;
      _activeSubjectId = null;
      _activeChapterNumber = null;
      _selectedNodeType = '';
    });
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    adminProv.selectGrade(null);
  }

  Future<void> _commitCurriculumChanges() async {
    setState(() {
      _isSavingToDb = true;
    });

    try {
      final prov = Provider.of<AdminProvider>(context, listen: false);
      await prov.saveCurriculum();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Curriculum updated successfully in Firebase!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingToDb = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final curriculum = adminProv.curriculum;

    return Column(
      children: [
        // Main Editor Area
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tree structure navigation pane
              Container(
                width: 340,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.divider, width: 1.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tree Header Actions
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Add new grade dialog / setup
                          _showAddGradeDialog();
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(
                          'Add Grade Level',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    // Tree list body
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        itemCount: curriculum.length,
                        itemBuilder: (context, index) {
                          final gradeKey = curriculum.keys.elementAt(index);
                          final grade = curriculum[gradeKey]!;
                          final isGradeSelected =
                              _selectedNodeType == 'grade' &&
                              _activeGradeKey == gradeKey;

                          return ExpansionTile(
                            initiallyExpanded: false,
                            shape: const RoundedRectangleBorder(),
                            collapsedShape: const RoundedRectangleBorder(),
                            iconColor: AppColors.primary,
                            collapsedIconColor: AppColors.textMuted,
                            title: InkWell(
                              onTap: () => _selectGradeNode(gradeKey, grade),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isGradeSelected
                                      ? AppColors.primaryHighlight
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      grade.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        grade.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: isGradeSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isGradeSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () =>
                                          _showAddSubjectDialog(gradeKey),
                                      tooltip: 'Add Subject',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            children: grade.subjects.map((subject) {
                              final isSubjectSelected =
                                  _selectedNodeType == 'subject' &&
                                  _activeGradeKey == gradeKey &&
                                  _activeSubjectId == subject.id;

                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ExpansionTile(
                                  initiallyExpanded: false,
                                  shape: const RoundedRectangleBorder(),
                                  collapsedShape:
                                      const RoundedRectangleBorder(),
                                  title: InkWell(
                                    onTap: () =>
                                        _selectSubjectNode(gradeKey, subject),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSubjectSelected
                                            ? AppColors.primaryHighlight
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            subject.emoji,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              subject.name,
                                              style: GoogleFonts.inter(
                                                fontWeight: isSubjectSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSubjectSelected
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.post_add_outlined,
                                              size: 16,
                                              color: AppColors.secondary,
                                            ),
                                            onPressed: () =>
                                                _showAddChapterDialog(
                                                  gradeKey,
                                                  subject.id,
                                                ),
                                            tooltip: 'Add Chapter',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  children: subject.chapters.map((chapter) {
                                    final isChapterSelected =
                                        _selectedNodeType == 'chapter' &&
                                        _activeGradeKey == gradeKey &&
                                        _activeSubjectId == subject.id &&
                                        _activeChapterNumber == chapter.number;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32.0,
                                        bottom: 4.0,
                                      ),
                                      child: ListTile(
                                        onTap: () => _selectChapterNode(
                                          gradeKey,
                                          subject.id,
                                          chapter,
                                        ),
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        tileColor: isChapterSelected
                                            ? AppColors.primaryHighlight
                                            : Colors.transparent,
                                        leading: const Icon(
                                          Icons.bookmark_outline,
                                          size: 14,
                                          color: AppColors.textMuted,
                                        ),
                                        title: Text(
                                          'Ch ${chapter.number}: ${chapter.title}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: isChapterSelected
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                            fontWeight: isChapterSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Form Details editing pane
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Active Node Card header
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
                          Icon(
                            _getNodeIcon(),
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getNodeTitle(),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedNodeType.isNotEmpty)
                            TextButton.icon(
                              onPressed: _clearSelection,
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Cancel Select'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Form Body based on selected node
                      Expanded(child: _buildEditingForm(adminProv)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Commit Action bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1.5),
            ),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Structure Draft: Tree changes (Grades/Subjects/Chapters) are saved locally. Click "Publish Layout Changes" to sync. Chapter details (quizzes, read mode) are published independently above.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      adminProv.loadCurriculum();
                      _clearSelection();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Discard Layout Changes'),
                  ),
                  const SizedBox(width: 16),
                  Tooltip(
                    message:
                        "Publishes the Grades, Subjects, and Chapters hierarchy. This does not modify chapter lesson contents.",
                    child: ElevatedButton.icon(
                      onPressed: _isSavingToDb
                          ? null
                          : _commitCurriculumChanges,
                      icon: _isSavingToDb
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
                        _isSavingToDb
                            ? 'Publishing Layout...'
                            : 'Publish Layout Changes',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW BUILDERS
  // ==========================================

  Widget _buildEditingForm(AdminProvider prov) {
    switch (_selectedNodeType) {
      case 'grade':
        return SingleChildScrollView(child: _buildGradeForm(prov));
      case 'subject':
        return SingleChildScrollView(child: _buildSubjectForm(prov));
      case 'chapter':
        return _buildChapterForm(prov);
      default:
        return SingleChildScrollView(child: _buildEmptyState());
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          const Icon(
            Icons.account_tree_outlined,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            'No Element Selected',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a Grade, Subject, or Chapter from the tree sidebar to edit its properties, or create new elements.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _autoUpdateGrade(AdminProvider prov) {
    if (_activeGradeKey == null) return;
    prov.updateGrade(
      _activeGradeKey!,
      Grade(
        name: _gradeNameController.text.isEmpty
            ? 'Unnamed Grade'
            : _gradeNameController.text,
        description: _gradeDescController.text,
        emoji: _gradeEmojiController.text.isEmpty
            ? '🎓'
            : _gradeEmojiController.text,
        subjects: prov.curriculum[_activeGradeKey!]?.subjects ?? [],
      ),
    );
  }

  void _autoUpdateSubject(AdminProvider prov) {
    if (_activeGradeKey == null || _activeSubjectId == null) return;
    final grade = prov.curriculum[_activeGradeKey!];
    final oldSub = grade?.subjects.firstWhere((s) => s.id == _activeSubjectId);

    prov.updateSubject(
      _activeGradeKey!,
      _activeSubjectId!,
      Subject(
        id: _activeSubjectId!,
        name: _subjectNameController.text.isEmpty
            ? 'Unnamed Subject'
            : _subjectNameController.text,
        emoji: _subjectEmojiController.text.isEmpty
            ? '📚'
            : _subjectEmojiController.text,
        color: _subjectColorController.text.isEmpty
            ? '#4E7FFF'
            : _subjectColorController.text,
        chapters: oldSub?.chapters ?? [],
      ),
    );
  }

  void _autoUpdateChapter(AdminProvider prov) {
    if (_activeGradeKey == null ||
        _activeSubjectId == null ||
        _activeChapterNumber == null)
      return;
    final chNum = int.tryParse(_chapterNumberController.text);
    if (chNum == null || _chapterTitleController.text.isEmpty) return;

    final grade = prov.curriculum[_activeGradeKey!];
    final subject = grade?.subjects.firstWhere((s) => s.id == _activeSubjectId);
    final oldCh = subject?.chapters.firstWhere(
      (c) => c.number == _activeChapterNumber,
    );
    final existingUrl = oldCh?.interactiveLessonUrl;
    final existingDiagrams = oldCh?.interactiveDiagrams;

    prov.updateChapter(
      _activeGradeKey!,
      _activeSubjectId!,
      _activeChapterNumber!,
      Chapter(
        number: chNum,
        title: _chapterTitleController.text,
        interactiveLessonUrl: existingUrl,
        interactiveDiagrams: existingDiagrams
            ?.map(
              (d) => InteractiveDiagram(
                id: d.id,
                title: d.title,
                thumbnail: d.thumbnail,
                url: d.url,
              ),
            )
            .toList(),
      ),
    );

    if (chNum != _activeChapterNumber) {
      setState(() {
        _activeChapterNumber = chNum;
      });
      prov.selectChapter(chNum);
    }
  }

  Widget _buildGradeForm(AdminProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _gradeEmojiController,
          label: 'Emoji Icon',
          hint: '🎓',
          onChanged: (_) => _autoUpdateGrade(prov),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _gradeNameController,
          label: 'Grade Level Name',
          hint: 'Grade 7',
          onChanged: (_) => _autoUpdateGrade(prov),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _gradeDescController,
          label: 'Curriculum Description',
          hint: 'CBSE (NCERT Syllabus)',
          maxLines: 3,
          onChanged: (_) => _autoUpdateGrade(prov),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                _showDeleteConfirmDialog('Grade Level', () {
                  prov.removeGrade(_activeGradeKey!);
                  _clearSelection();
                });
              },
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete Grade Level'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectForm(AdminProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _subjectEmojiController,
                    label: 'Emoji Icon',
                    hint: '🧬',
                    onChanged: (_) => _autoUpdateSubject(prov),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick Presets:',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildEmojiPresetChip(
                        '🔬',
                        'Science',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '🧬',
                        'Science',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '🧮',
                        'Maths',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '📐',
                        'Maths',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '🇬🇧',
                        'English',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '📚',
                        'English',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '🌍',
                        'Social',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                      _buildEmojiPresetChip(
                        '🗺️',
                        'Social',
                        _subjectEmojiController,
                        () => _autoUpdateSubject(prov),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTextField(
                controller: _subjectColorController,
                label: 'Subject Color (HEX)',
                hint: '#4E7FFF',
                onChanged: (_) => _autoUpdateSubject(prov),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _subjectIdController,
          label: 'Subject Unique ID (Code)',
          hint: 'science',
          enabled:
              false, // Don't let users edit ID after creation as it forms the database folder structure
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _subjectNameController,
          label: 'Subject Name',
          hint: 'Science',
          onChanged: (_) => _autoUpdateSubject(prov),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                _showDeleteConfirmDialog('Subject', () {
                  prov.removeSubject(_activeGradeKey!, _activeSubjectId!);
                  _clearSelection();
                });
              },
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete Subject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChapterForm(AdminProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 100,
                child: _buildTextField(
                  controller: _chapterNumberController,
                  label: 'Ch. Number',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _autoUpdateChapter(prov),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _chapterTitleController,
                  label: 'Chapter Title',
                  hint: 'Nutrition in Plants',
                  onChanged: (_) => _autoUpdateChapter(prov),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _showDeleteConfirmDialog('Chapter', () {
                    prov.removeChapter(
                      _activeGradeKey!,
                      _activeSubjectId!,
                      _activeChapterNumber!,
                    );
                    _clearSelection();
                  });
                },
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text(
                  'Delete Chapter',
                  style: TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),
        const Expanded(child: ChapterContentEditor()),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
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
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiPresetChip(
    String emoji,
    String label,
    TextEditingController controller, [
    VoidCallback? onSelected,
    bool enabled = true,
  ]) {
    return InkWell(
      onTap: enabled
          ? () {
              setState(() {
                controller.text = emoji;
              });
              if (onSelected != null) {
                onSelected();
              }
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNodeIcon() {
    switch (_selectedNodeType) {
      case 'grade':
        return Icons.school_outlined;
      case 'subject':
        return Icons.menu_book_outlined;
      case 'chapter':
        return Icons.bookmark_outline;
      default:
        return Icons.edit;
    }
  }

  String _getNodeTitle() {
    switch (_selectedNodeType) {
      case 'grade':
        return 'Edit Grade Level Properties';
      case 'subject':
        return 'Edit Subject Properties';
      case 'chapter':
        return 'Edit Chapter Properties';
      default:
        return 'Selection Details';
    }
  }

  // ==========================================
  // DIALOG BUILDERS
  // ==========================================

  void _showAddGradeDialog() {
    final keyCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Add Grade Level',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Database Key (e.g. grade_7)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Grade Name (e.g. Grade 7)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emojiCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Emoji Icon',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
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
              onPressed: () {
                if (keyCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                Provider.of<AdminProvider>(context, listen: false).addGrade(
                  keyCtrl.text.trim(),
                  Grade(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    emoji: emojiCtrl.text.trim().isEmpty
                        ? '🎓'
                        : emojiCtrl.text.trim(),
                    subjects: [],
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddSubjectDialog(String gradeKey) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final Map<String, Map<String, String>> defaultPresets = {
      'science': {
        'id': 'science',
        'name': 'Science',
        'emoji': '🔬',
        'color': '#D1FAE5',
      },
      'math': {
        'id': 'math',
        'name': 'Maths',
        'emoji': '🧮',
        'color': '#DBEAFE',
      },
      'english': {
        'id': 'english',
        'name': 'English',
        'emoji': '🇬🇧',
        'color': '#FEF3C7',
      },
      'social': {
        'id': 'social',
        'name': 'Social Studies',
        'emoji': '🌍',
        'color': '#FCE7F3',
      },
      'hindi': {
        'id': 'hindi',
        'name': 'Hindi',
        'emoji': '🇮🇳',
        'color': '#FFF2E2',
      },
      'computer': {
        'id': 'computer',
        'name': 'Computer',
        'emoji': '💻',
        'color': '#E0F2FE',
      },
    };

    final Map<String, Map<String, String>> presets = {
      ...defaultPresets,
      ...adminProvider.customPresets,
      ...adminProvider.getAllCurriculumSubjects(),
    };

    // Safely determine initial preset
    String selectedPreset = presets.containsKey('science')
        ? 'science'
        : presets.keys.first;
    final initialPreset = presets[selectedPreset]!;

    final idCtrl = TextEditingController(text: initialPreset['id']);
    final nameCtrl = TextEditingController(text: initialPreset['name']);
    final emojiCtrl = TextEditingController(text: initialPreset['emoji']);
    final colorCtrl = TextEditingController(text: initialPreset['color']);

    bool isIdExistingPreset = false;
    VoidCallback? dialogUpdater;

    idCtrl.addListener(() {
      final idVal = idCtrl.text.trim().toLowerCase();
      if (selectedPreset == 'custom') {
        final hasKey = presets.containsKey(idVal);
        if (hasKey) {
          final preset = presets[idVal]!;
          if (nameCtrl.text != preset['name']) nameCtrl.text = preset['name']!;
          if (emojiCtrl.text != preset['emoji'])
            emojiCtrl.text = preset['emoji']!;
          if (colorCtrl.text != preset['color'])
            colorCtrl.text = preset['color']!;
          if (!isIdExistingPreset) {
            isIdExistingPreset = true;
            if (dialogUpdater != null) dialogUpdater!();
          }
        } else {
          if (isIdExistingPreset) {
            isIdExistingPreset = false;
            if (dialogUpdater != null) dialogUpdater!();
          }
        }
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogUpdater = () => setDialogState(() {});
            final bool isReadOnly =
                (selectedPreset != 'custom') || isIdExistingPreset;

            return AlertDialog(
              backgroundColor: AppColors.card,
              title: Text(
                'Add Subject',
                style: GoogleFonts.outfit(color: AppColors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Subject ID',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.card,
                      initialValue: selectedPreset,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: [
                        ...presets.entries.map((entry) {
                          final preset = entry.value;
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text('${preset['name']} (${preset['id']})'),
                          );
                        }),
                        const DropdownMenuItem<String>(
                          value: 'custom',
                          child: Text('Custom Subject...'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedPreset = val;
                            if (val != 'custom' && presets.containsKey(val)) {
                              final preset = presets[val]!;
                              idCtrl.text = preset['id']!;
                              nameCtrl.text = preset['name']!;
                              emojiCtrl.text = preset['emoji']!;
                              colorCtrl.text = preset['color']!;
                            } else {
                              idCtrl.text = '';
                              nameCtrl.text = '';
                              emojiCtrl.text = '📚';
                              colorCtrl.text = '#4E7FFF';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    if (selectedPreset == 'custom') ...[
                      TextField(
                        controller: idCtrl,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Subject ID/Code (e.g. science, math)',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextField(
                      controller: nameCtrl,
                      readOnly: isReadOnly,
                      style: TextStyle(
                        color: isReadOnly
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: emojiCtrl,
                      readOnly: isReadOnly,
                      style: TextStyle(
                        color: isReadOnly
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Emoji Icon',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quick Presets:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildEmojiPresetChip(
                          '🔬',
                          'Science',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '🧬',
                          'Science',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '🧮',
                          'Maths',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '📐',
                          'Maths',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '🇬🇧',
                          'English',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '📚',
                          'English',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '🌍',
                          'Social',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                        _buildEmojiPresetChip(
                          '🗺️',
                          'Social',
                          emojiCtrl,
                          () => setDialogState(() {}),
                          !isReadOnly,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: colorCtrl,
                      readOnly: isReadOnly,
                      style: TextStyle(
                        color: isReadOnly
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Hex Color code',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
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
                  onPressed: () {
                    final idVal = idCtrl.text.trim();
                    if (idVal.isEmpty || nameCtrl.text.isEmpty) return;

                    if (selectedPreset == 'custom') {
                      final idLower = idVal.toLowerCase();
                      if (!presets.containsKey(idLower)) {
                        adminProvider.saveCustomPreset(
                          idVal,
                          nameCtrl.text.trim(),
                          emojiCtrl.text.trim().isEmpty
                              ? '📚'
                              : emojiCtrl.text.trim(),
                          colorCtrl.text.trim(),
                        );
                      }
                    }

                    Provider.of<AdminProvider>(
                      context,
                      listen: false,
                    ).addSubject(
                      gradeKey,
                      Subject(
                        id: idVal,
                        name: nameCtrl.text.trim(),
                        emoji: emojiCtrl.text.trim().isEmpty
                            ? '📚'
                            : emojiCtrl.text.trim(),
                        color: colorCtrl.text.trim(),
                        chapters: [],
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddChapterDialog(String gradeKey, String subjectId) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final grade = adminProvider.curriculum[gradeKey];
    final subject = grade?.subjects.where((s) => s.id == subjectId).firstOrNull;

    int nextNum = 1;
    if (subject != null && subject.chapters.isNotEmpty) {
      final maxNum = subject.chapters
          .map((c) => c.number)
          .reduce((a, b) => a > b ? a : b);
      nextNum = maxNum + 1;
    }

    final formKey = GlobalKey<FormState>();
    final numCtrl = TextEditingController(text: '$nextNum');
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Add Chapter',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: numCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Chapter Number',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter chapter number';
                    }
                    if (int.tryParse(val.trim()) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Chapter Title',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter chapter title';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final chNum = int.tryParse(numCtrl.text.trim());
                final title = titleCtrl.text.trim();

                if (chNum == null || title.isEmpty) return;

                final newChapter = Chapter(number: chNum, title: title);
                adminProvider.addChapter(
                  gradeKey,
                  subjectId,
                  newChapter,
                );

                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String type, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Confirm Deletion',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete this $type? This will remove all nested items as well in the local tree view.',
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
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
