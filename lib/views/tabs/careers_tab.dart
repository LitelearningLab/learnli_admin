import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/career_models.dart';
import '../../constants/app_colors.dart';

class CareersTab extends StatefulWidget {
  const CareersTab({super.key});

  @override
  State<CareersTab> createState() => _CareersTabState();
}

class _CareersTabState extends State<CareersTab> {
  String _searchQuery = '';
  int _activeStepIndex = 0;
  bool _isSavingToDb = false;

  void _showAddCareerDialog(AdminProvider prov) {
    final idController = TextEditingController();
    final titleController = TextEditingController();
    final iconController = TextEditingController(text: '💼');
    final subtitleController = TextEditingController();
    final colorController = TextEditingController(text: '#4E7FFF');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Create New Career Pathway',
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(idController, 'Unique ID (lowercase, e.g. astronaut)', 'astronaut'),
                const SizedBox(height: 12),
                _buildDialogTextField(titleController, 'Title (e.g. Astronaut)', 'Astronaut'),
                const SizedBox(height: 12),
                _buildDialogTextField(subtitleController, 'Subtitle (e.g. Your Journey to Space)', 'Your Journey to Space'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDialogTextField(iconController, 'Icon Emoji', '🚀')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDialogTextField(colorController, 'Theme Color (Hex)', '#4E7FFF')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final id = idController.text.trim().toLowerCase();
                if (id.isEmpty || titleController.text.isEmpty) return;

                // Create placeholder steps
                final defaultSteps = [
                  CareerStep(
                    id: 'current',
                    title: 'YOU ARE HERE 📍',
                    icon: '📍',
                    color: '#4E7FFF',
                    bgColor: '#E8F0FF',
                    data: {'description': 'Dream big! Start your journey today.'},
                  ),
                  CareerStep(
                    id: 'dream',
                    title: '🎯 YOUR DREAM ACHIEVED! 🎉',
                    icon: '🎉',
                    color: '#FFD700',
                    bgColor: '#FFF9E6',
                    data: {
                      'dreamIcon': iconController.text,
                      'dreamTitle': titleController.text,
                      'dreamSubtitle': subtitleController.text,
                      'dreamQuote': 'The journey of a thousand miles begins with a single step.',
                    },
                  ),
                ];

                final newCareer = Career(
                  id: id,
                  title: titleController.text,
                  icon: iconController.text,
                  subtitle: subtitleController.text,
                  color: colorController.text,
                  steps: defaultSteps,
                );

                prov.addCareer(id, newCareer);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Career created locally! Remember to save changes.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges(AdminProvider prov) async {
    setState(() {
      _isSavingToDb = true;
    });

    try {
      await prov.saveCareers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Careers successfully published to Firebase Realtime DB!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save careers: $e'),
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

  void _showDeleteConfirm(AdminProvider prov, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Delete Career Pathway?', style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            'Are you sure you want to permanently delete "$id"? This will remove it from Firebase DB immediately.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await prov.deleteCareer(id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Career deleted successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete career: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final careersMap = adminProv.careers;

    // Filtered list of careers based on search
    final filteredKeys = careersMap.keys.where((k) {
      final title = careersMap[k]!.title.toLowerCase();
      final sub = careersMap[k]!.subtitle.toLowerCase();
      final id = k.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || sub.contains(query) || id.contains(query);
    }).toList();

    final activeCareer = adminProv.selectedCareer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Panel: list of Careers
        Container(
          width: 320,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColors.divider, width: 1.5),
            ),
          ),
          child: Column(
            children: [
              // Search and add bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search career pathways...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddCareerDialog(adminProv),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Career Pathway'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),

              // Careers list
              Expanded(
                child: adminProv.isLoadingCareers
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : filteredKeys.isEmpty
                        ? const Center(
                            child: Text(
                              'No career pathways found',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredKeys.length,
                            itemBuilder: (context, index) {
                              final key = filteredKeys[index];
                              final career = careersMap[key]!;
                              final isSelected = adminProv.selectedCareerId == key;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: ListTile(
                                  onTap: () {
                                    adminProv.selectCareer(key);
                                    setState(() {
                                      _activeStepIndex = 0;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  tileColor: isSelected ? AppColors.primaryHighlight : Colors.transparent,
                                  leading: Text(career.icon, style: const TextStyle(fontSize: 22)),
                                  title: Text(
                                    career.title,
                                    style: GoogleFonts.inter(
                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  subtitle: Text(
                                    career.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11.5),
                                  ),
                                  trailing: isSelected
                                      ? Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _parseHexColor(career.color),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),

        // Right Panel: Form Editor
        Expanded(
          child: activeCareer == null
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Top header for Active Career Actions
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1.5)),
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
                              Text(activeCareer.icon, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeCareer.title,
                                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    'ID: ${activeCareer.id}',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Commit Button
                              ElevatedButton.icon(
                                onPressed: _isSavingToDb ? null : () => _saveChanges(adminProv),
                                icon: _isSavingToDb
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.cloud_done_outlined, size: 16),
                                label: const Text('Save to Firebase DB'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Delete Button
                              OutlinedButton.icon(
                                onPressed: () => _showDeleteConfirm(adminProv, activeCareer.id),
                                icon: const Icon(Icons.delete_forever, size: 16),
                                label: const Text('Delete Pathway'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Main Form scroll area
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Steps timeline list
                          Container(
                            width: 250,
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: AppColors.divider, width: 1.5)),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('TIMELINE STEPS', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                                        tooltip: 'Insert Step',
                                        onPressed: () => _insertStep(adminProv, activeCareer),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    itemCount: activeCareer.steps.length,
                                    itemBuilder: (context, index) {
                                      final step = activeCareer.steps[index];
                                      final isSelected = _activeStepIndex == index;

                                      final stepColor = _parseHexColor(step.color);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: ListTile(
                                          onTap: () {
                                            setState(() {
                                              _activeStepIndex = index;
                                            });
                                          },
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          tileColor: isSelected ? stepColor.withOpacity(0.12) : Colors.transparent,
                                          leading: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: _parseHexColor(step.bgColor),
                                            child: Text(
                                              step.icon,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          title: Text(
                                            step.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              color: isSelected ? stepColor : AppColors.textSecondary,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 12,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Type: ${step.id}',
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                          ),
                                          trailing: isSelected
                                              ? IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, size: 14, color: AppColors.error),
                                                  onPressed: () => _removeStep(adminProv, activeCareer, index),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                )
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Step Detail Editor
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // General Career Metadata if step index is 0/Overview, or let's show it at the top of everything
                                  _buildCareerMetadataForm(adminProv, activeCareer),
                                  const SizedBox(height: 24),
                                  const Divider(height: 1, color: AppColors.divider),
                                  const SizedBox(height: 24),

                                  if (activeCareer.steps.isNotEmpty && _activeStepIndex < activeCareer.steps.length) ...[
                                    Row(
                                      children: [
                                        Text('Step #${_activeStepIndex + 1} Properties', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                        const Spacer(),
                                        // Reorder Up/Down
                                        IconButton(
                                          icon: const Icon(Icons.arrow_upward, size: 16, color: AppColors.textSecondary),
                                          onPressed: _activeStepIndex > 0 ? () => _reorderStep(adminProv, activeCareer, _activeStepIndex, -1) : null,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_downward, size: 16, color: AppColors.textSecondary),
                                          onPressed: _activeStepIndex < activeCareer.steps.length - 1 ? () => _reorderStep(adminProv, activeCareer, _activeStepIndex, 1) : null,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStepPropertiesForm(adminProv, activeCareer, activeCareer.steps[_activeStepIndex]),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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
          const Icon(Icons.work_outline, size: 80, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            'No Career Pathway Selected',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a pathway from the left sidebar to edit, or create a new one.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CAREER PROPERTIES FORM
  // ==========================================

  Widget _buildCareerMetadataForm(AdminProvider prov, Career career) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GENERAL CAREER PROPERTIES', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildFormField(
                key: '${career.id}_title',
                label: 'Career Title',
                value: career.title,
                onChanged: (val) {
                  final updated = Career(
                    id: career.id,
                    title: val,
                    icon: career.icon,
                    subtitle: career.subtitle,
                    color: career.color,
                    steps: career.steps,
                  );
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildFormField(
                key: '${career.id}_icon',
                label: 'Emoji Icon',
                value: career.icon,
                onChanged: (val) {
                  final updated = Career(
                    id: career.id,
                    title: career.title,
                    icon: val,
                    subtitle: career.subtitle,
                    color: career.color,
                    steps: career.steps,
                  );
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildFormField(
                key: '${career.id}_color',
                label: 'Theme Color (HEX)',
                value: career.color,
                onChanged: (val) {
                  final updated = Career(
                    id: career.id,
                    title: career.title,
                    icon: career.icon,
                    subtitle: career.subtitle,
                    color: val,
                    steps: career.steps,
                  );
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
          ],
        ),
        _buildFormField(
          key: '${career.id}_subtitle',
          label: 'Subtitle Description',
          value: career.subtitle,
          onChanged: (val) {
            final updated = Career(
              id: career.id,
              title: career.title,
              icon: career.icon,
              subtitle: val,
              color: career.color,
              steps: career.steps,
            );
            prov.updateCareer(career.id, updated);
          },
        ),
      ],
    );
  }

  // ==========================================
  // TIMELINE STEPS REORDER / ADD / REMOVE
  // ==========================================

  void _insertStep(AdminProvider prov, Career career) {
    final nextStep = CareerStep(
      id: 'preparation',
      title: 'NEW TIMELINE PHASE',
      icon: '🎯',
      color: '#4E7FFF',
      bgColor: '#E8F0FF',
      data: {'duration': 'Grades 7-12 • 6 years', 'subjects': []},
    );

    final updatedSteps = List<CareerStep>.from(career.steps)..insert(_activeStepIndex + 1, nextStep);
    final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: updatedSteps);
    prov.updateCareer(career.id, updated);
    setState(() {
      _activeStepIndex = _activeStepIndex + 1;
    });
  }

  void _removeStep(AdminProvider prov, Career career, int index) {
    if (career.steps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove the last step! A career must have at least one step.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final updatedSteps = List<CareerStep>.from(career.steps)..removeAt(index);
    final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: updatedSteps);
    prov.updateCareer(career.id, updated);

    setState(() {
      if (_activeStepIndex >= updatedSteps.length) {
        _activeStepIndex = updatedSteps.length - 1;
      }
    });
  }

  void _reorderStep(AdminProvider prov, Career career, int index, int offset) {
    final targetIdx = index + offset;
    if (targetIdx < 0 || targetIdx >= career.steps.length) return;

    final steps = List<CareerStep>.from(career.steps);
    final temp = steps[index];
    steps[index] = steps[targetIdx];
    steps[targetIdx] = temp;

    final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: steps);
    prov.updateCareer(career.id, updated);
    setState(() {
      _activeStepIndex = targetIdx;
    });
  }

  // ==========================================
  // DYNAMIC STEP PROPERTIES FORM
  // ==========================================

  Widget _buildStepPropertiesForm(AdminProvider prov, Career career, CareerStep step) {
    final stepTypes = ['current', 'preparation', 'exams', 'colleges', 'education', 'career', 'abroad', 'dream'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standard fields
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step Type ID', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
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
                        value: stepTypes.contains(step.id) ? step.id : 'current',
                        dropdownColor: AppColors.card,
                        isExpanded: true,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        items: stepTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final updatedStep = CareerStep(
                            id: val,
                            title: step.title,
                            icon: step.icon,
                            color: step.color,
                            bgColor: step.bgColor,
                            data: _getDefaultDataForStepType(val, step.data),
                          );
                          final steps = List<CareerStep>.from(career.steps);
                          steps[_activeStepIndex] = updatedStep;
                          final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: steps);
                          prov.updateCareer(career.id, updated);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_step_title',
                label: 'Step Display Title',
                value: step.title,
                onChanged: (val) {
                  final updatedStep = CareerStep(id: step.id, title: val, icon: step.icon, color: step.color, bgColor: step.bgColor, data: step.data);
                  final steps = List<CareerStep>.from(career.steps);
                  steps[_activeStepIndex] = updatedStep;
                  final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: steps);
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_step_icon',
                label: 'Step Icon Emoji',
                value: step.icon,
                onChanged: (val) {
                  final updatedStep = CareerStep(id: step.id, title: step.title, icon: val, color: step.color, bgColor: step.bgColor, data: step.data);
                  final steps = List<CareerStep>.from(career.steps);
                  steps[_activeStepIndex] = updatedStep;
                  final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: steps);
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_step_color',
                label: 'Icon Color (HEX)',
                value: step.color,
                onChanged: (val) {
                  final updatedStep = CareerStep(id: step.id, title: step.title, icon: step.icon, color: val, bgColor: step.bgColor, data: step.data);
                  final steps = List<CareerStep>.from(career.steps);
                  steps[_activeStepIndex] = updatedStep;
                  final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: steps);
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_step_bgcolor',
                label: 'Background Color (HEX)',
                value: step.bgColor,
                onChanged: (val) {
                  final updatedStep = CareerStep(id: step.id, title: step.title, icon: step.icon, color: step.color, bgColor: val, data: step.data);
                  final steps = List<CareerStep>.from(career.steps);
                  steps[_activeStepIndex] = updatedStep;
                  final updated = Career(id: career.id, title: career.title, icon: career.icon, subtitle: career.subtitle, color: career.color, steps: steps);
                  prov.updateCareer(career.id, updated);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Text('PHASE-SPECIFIC DATA FIELDS', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Sub-form editor depending on step type
        _buildStepDataSubForm(prov, career, step),
      ],
    );
  }

  Map<String, dynamic> _getDefaultDataForStepType(String type, Map<String, dynamic> currentData) {
    switch (type) {
      case 'current':
        return {'description': currentData['description'] ?? 'YOU ARE HERE'};
      case 'preparation':
        return {'duration': currentData['duration'] ?? 'Grades 7-12 • 6 years', 'subjects': currentData['subjects'] ?? []};
      case 'exams':
        return {'duration': currentData['duration'] ?? 'After Grade 12', 'exams': currentData['exams'] ?? []};
      case 'colleges':
        return {'colleges': currentData['colleges'] ?? []};
      case 'education':
        return {
          'duration': currentData['duration'] ?? '4 years Degree',
          'education': currentData['education'] ?? {'courseDuration': 'BTech', 'totalCost': '5 lakhs', 'costNote': '', 'specialization': []}
        };
      case 'career':
        return {'opportunities': currentData['opportunities'] ?? currentData['career'] ?? []};
      case 'abroad':
        return {'abroad': currentData['abroad'] ?? []};
      case 'dream':
        return {
          'dreamIcon': currentData['dreamIcon'] ?? '🎉',
          'dreamTitle': currentData['dreamTitle'] ?? 'Acheived!',
          'dreamSubtitle': currentData['dreamSubtitle'] ?? 'Goal Completed',
          'dreamQuote': currentData['dreamQuote'] ?? 'Awesome work!'
        };
      default:
        return {};
    }
  }

  Widget _buildStepDataSubForm(AdminProvider prov, Career career, CareerStep step) {
    switch (step.id) {
      case 'current':
        return _buildCurrentStepForm(prov, career, step);
      case 'preparation':
        return _buildPreparationStepForm(prov, career, step);
      case 'exams':
        return _buildExamsStepForm(prov, career, step);
      case 'colleges':
        return _buildCollegesStepForm(prov, career, step);
      case 'education':
        return _buildEducationStepForm(prov, career, step);
      case 'career':
        return _buildCareerOpportunitiesStepForm(prov, career, step);
      case 'abroad':
        return _buildAbroadStepForm(prov, career, step);
      case 'dream':
        return _buildDreamStepForm(prov, career, step);
      default:
        return const Text('Unknown step type', style: TextStyle(color: Colors.red));
    }
  }

  // 1. Current Step Form
  Widget _buildCurrentStepForm(AdminProvider prov, Career career, CareerStep step) {
    return _buildFormField(
      key: '${career.id}_${step.id}_desc',
      label: 'Description / Message',
      value: step.data['description'] ?? '',
      maxLines: 3,
      onChanged: (val) {
        step.data['description'] = val;
        prov.updateCareer(career.id, career);
      },
    );
  }

  // 2. Preparation Step Form
  Widget _buildPreparationStepForm(AdminProvider prov, Career career, CareerStep step) {
    final List subjects = step.data['subjects'] is List ? step.data['subjects'] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(
          key: '${career.id}_${step.id}_duration',
          label: 'Phase Duration String',
          value: step.data['duration'] ?? '',
          onChanged: (val) {
            step.data['duration'] = val;
            prov.updateCareer(career.id, career);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subjects & Focus Areas', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                subjects.add({'name': 'New Subject', 'importance': 3});
                step.data['subjects'] = subjects;
                prov.updateCareer(career.id, career);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Add Subject', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final sub = subjects[idx] is Map ? Map<String, dynamic>.from(subjects[idx] as Map) : {'name': '', 'importance': 3};
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_sub_${idx}_name'),
                      initialValue: sub['name'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Subject Name', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                      onChanged: (val) {
                        sub['name'] = val;
                        subjects[idx] = sub;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        const Text('Importance:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Expanded(
                          child: Slider(
                            value: (sub['importance'] ?? 3).toDouble(),
                            min: 1,
                            max: 3,
                            divisions: 2,
                            activeColor: AppColors.secondary,
                            onChanged: (val) {
                              setState(() {
                                sub['importance'] = val.toInt();
                                subjects[idx] = sub;
                                prov.updateCareer(career.id, career);
                              });
                            },
                          ),
                        ),
                        Text('${sub['importance'] ?? 3}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                    onPressed: () {
                      subjects.removeAt(idx);
                      step.data['subjects'] = subjects;
                      prov.updateCareer(career.id, career);
                      setState(() {});
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

  // 3. Exams Step Form
  Widget _buildExamsStepForm(AdminProvider prov, Career career, CareerStep step) {
    final List exams = step.data['exams'] is List ? step.data['exams'] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(
          key: '${career.id}_${step.id}_duration',
          label: 'Phase Duration String',
          value: step.data['duration'] ?? '',
          onChanged: (val) {
            step.data['duration'] = val;
            prov.updateCareer(career.id, career);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Entrance Exams', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                exams.add({'name': 'Exam Name', 'fullName': '', 'totalMarks': '', 'requiredScore': '', 'duration': '', 'subjects': ''});
                step.data['exams'] = exams;
                prov.updateCareer(career.id, career);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Add Exam', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, idx) {
            final ex = exams[idx] is Map ? Map<String, dynamic>.from(exams[idx] as Map) : <String, dynamic>{};
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Exam #${idx + 1}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                        onPressed: () {
                          exams.removeAt(idx);
                          step.data['exams'] = exams;
                          prov.updateCareer(career.id, career);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          key: '${career.id}_${step.id}_ex_${idx}_name',
                          label: 'Short Name',
                          value: ex['name'] ?? '',
                          onChanged: (val) {
                            ex['name'] = val;
                            exams[idx] = ex;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          key: '${career.id}_${step.id}_ex_${idx}_fullname',
                          label: 'Full Name / Description',
                          value: ex['fullName'] ?? '',
                          onChanged: (val) {
                            ex['fullName'] = val;
                            exams[idx] = ex;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          key: '${career.id}_${step.id}_ex_${idx}_marks',
                          label: 'Total Marks',
                          value: ex['totalMarks'] ?? '',
                          onChanged: (val) {
                            ex['totalMarks'] = val;
                            exams[idx] = ex;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          key: '${career.id}_${step.id}_ex_${idx}_score',
                          label: 'Required Score',
                          value: ex['requiredScore'] ?? '',
                          onChanged: (val) {
                            ex['requiredScore'] = val;
                            exams[idx] = ex;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          key: '${career.id}_${step.id}_ex_${idx}_dur',
                          label: 'Exam Duration',
                          value: ex['duration'] ?? '',
                          onChanged: (val) {
                            ex['duration'] = val;
                            exams[idx] = ex;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          key: '${career.id}_${step.id}_ex_${idx}_subs',
                          label: 'Exam Subjects (e.g. PCM)',
                          value: ex['subjects'] ?? '',
                          onChanged: (val) {
                            ex['subjects'] = val;
                            exams[idx] = ex;
                            prov.updateCareer(career.id, career);
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
    );
  }

  // 4. Colleges Step Form
  Widget _buildCollegesStepForm(AdminProvider prov, Career career, CareerStep step) {
    final List colleges = step.data['colleges'] is List ? step.data['colleges'] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Target Universities / Colleges', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                colleges.add({'name': 'College Name', 'fees': '₹5 lakhs/year', 'rank': colleges.length + 1});
                step.data['colleges'] = colleges;
                prov.updateCareer(career.id, career);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Add College', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: colleges.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final col = colleges[idx] is Map ? Map<String, dynamic>.from(colleges[idx] as Map) : {'name': '', 'fees': '', 'rank': 1};
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_col_${idx}_rank'),
                      initialValue: (col['rank'] ?? 1).toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Rank', border: InputBorder.none, labelText: 'Rank', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        col['rank'] = int.tryParse(val) ?? 1;
                        colleges[idx] = col;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_col_${idx}_name'),
                      initialValue: col['name'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'College Name', border: InputBorder.none, labelText: 'Name', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        col['name'] = val;
                        colleges[idx] = col;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_col_${idx}_fees'),
                      initialValue: col['fees'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: '₹8-10 lakhs', border: InputBorder.none, labelText: 'Fees Details', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        col['fees'] = val;
                        colleges[idx] = col;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                    onPressed: () {
                      colleges.removeAt(idx);
                      step.data['colleges'] = colleges;
                      prov.updateCareer(career.id, career);
                      setState(() {});
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

  // 5. Education Step Form
  Widget _buildEducationStepForm(AdminProvider prov, Career career, CareerStep step) {
    final eduMap = step.data['education'] is Map
        ? Map<String, dynamic>.from(step.data['education'] as Map)
        : {'courseDuration': 'BTech', 'totalCost': '5 lakhs', 'costNote': '', 'specialization': []};

    final List specList = eduMap['specialization'] is List ? eduMap['specialization'] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(
          key: '${career.id}_${step.id}_dur',
          label: 'Overview Duration String',
          value: step.data['duration'] ?? '',
          onChanged: (val) {
            step.data['duration'] = val;
            prov.updateCareer(career.id, career);
          },
        ),
        _buildFormField(
          key: '${career.id}_${step.id}_edu_course',
          label: 'Primary Course / Degree Title',
          value: eduMap['courseDuration'] ?? '',
          onChanged: (val) {
            eduMap['courseDuration'] = val;
            step.data['education'] = eduMap;
            prov.updateCareer(career.id, career);
          },
        ),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_edu_cost',
                label: 'Total Fees / Cost String',
                value: eduMap['totalCost'] ?? '',
                onChanged: (val) {
                  eduMap['totalCost'] = val;
                  step.data['education'] = eduMap;
                  prov.updateCareer(career.id, career);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_edu_costnote',
                label: 'Scholarship / Fees Note',
                value: eduMap['costNote'] ?? '',
                onChanged: (val) {
                  eduMap['costNote'] = val;
                  step.data['education'] = eduMap;
                  prov.updateCareer(career.id, career);
                },
              ),
            ),
          ],
        ),
        if (step.data.containsKey('education') && step.data['education'] is Map && step.data['education'].containsKey('internship'))
          _buildFormField(
            key: '${career.id}_${step.id}_edu_internship',
            label: 'Internship Duration (Optional)',
            value: eduMap['internship'] ?? '',
            onChanged: (val) {
              eduMap['internship'] = val;
              step.data['education'] = eduMap;
              prov.updateCareer(career.id, career);
            },
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Specializations & Training Milestones', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                specList.add({'name': 'IAF Pilot Training', 'duration': '3-4 years'});
                eduMap['specialization'] = specList;
                step.data['education'] = eduMap;
                prov.updateCareer(career.id, career);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Add Milestone', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final spec = specList[idx] is Map ? Map<String, dynamic>.from(specList[idx] as Map) : {'name': '', 'duration': ''};
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_spec_${idx}_name'),
                      initialValue: spec['name'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Specialization Name', border: InputBorder.none, labelText: 'Milestone Name', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        spec['name'] = val;
                        specList[idx] = spec;
                        eduMap['specialization'] = specList;
                        step.data['education'] = eduMap;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_spec_${idx}_dur'),
                      initialValue: spec['duration'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'e.g. 2 years', border: InputBorder.none, labelText: 'Duration', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        spec['duration'] = val;
                        specList[idx] = spec;
                        eduMap['specialization'] = specList;
                        step.data['education'] = eduMap;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                    onPressed: () {
                      specList.removeAt(idx);
                      eduMap['specialization'] = specList;
                      step.data['education'] = eduMap;
                      prov.updateCareer(career.id, career);
                      setState(() {});
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

  // 6. Career / Opportunities Step Form
  Widget _buildCareerOpportunitiesStepForm(AdminProvider prov, Career career, CareerStep step) {
    final List opportunities = step.data['opportunities'] is List
        ? step.data['opportunities']
        : (step.data['career'] is List ? step.data['career'] : []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Job Roles & Salary Levels', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                opportunities.add({'role': 'Software Engineer', 'icon': '💻', 'salary': '₹6-30 LPA'});
                step.data['opportunities'] = opportunities;
                prov.updateCareer(career.id, career);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Add Role', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: opportunities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final opp = opportunities[idx] is Map ? Map<String, dynamic>.from(opportunities[idx] as Map) : {'role': '', 'icon': '💼', 'salary': ''};
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_opp_${idx}_icon'),
                      initialValue: opp['icon'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Emoji', border: InputBorder.none, labelText: 'Icon', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        opp['icon'] = val;
                        opportunities[idx] = opp;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_opp_${idx}_role'),
                      initialValue: opp['role'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Role Title', border: InputBorder.none, labelText: 'Job Title', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        opp['role'] = val;
                        opportunities[idx] = opp;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: ValueKey('${career.id}_${step.id}_opp_${idx}_sal'),
                      initialValue: opp['salary'],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Salary Range', border: InputBorder.none, labelText: 'Income Package', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      onChanged: (val) {
                        opp['salary'] = val;
                        opportunities[idx] = opp;
                        prov.updateCareer(career.id, career);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                    onPressed: () {
                      opportunities.removeAt(idx);
                      step.data['opportunities'] = opportunities;
                      prov.updateCareer(career.id, career);
                      setState(() {});
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

  // 7. Abroad Step Form
  Widget _buildAbroadStepForm(AdminProvider prov, Career career, CareerStep step) {
    final List abroad = step.data['abroad'] is List ? step.data['abroad'] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Global Opportunities', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                abroad.add({'country': 'USA', 'flag': '🇺🇸', 'exam': 'GRE/MS', 'salary': r'$80k/year'});
                step.data['abroad'] = abroad;
                prov.updateCareer(career.id, career);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Add Abroad Info', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: abroad.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final ab = abroad[idx] is Map ? Map<String, dynamic>.from(abroad[idx] as Map) : {'country': '', 'flag': '🇺🇸', 'exam': '', 'salary': ''};
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(ab['flag'] ?? '🇺🇸', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text('Country Option #${idx + 1}: ${ab['country']}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                        onPressed: () {
                          abroad.removeAt(idx);
                          step.data['abroad'] = abroad;
                          prov.updateCareer(career.id, career);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('${career.id}_${step.id}_ab_${idx}_country'),
                          initialValue: ab['country'],
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(hintText: 'USA', labelText: 'Country Name', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          onChanged: (val) {
                            ab['country'] = val;
                            abroad[idx] = ab;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('${career.id}_${step.id}_ab_${idx}_flag'),
                          initialValue: ab['flag'],
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(hintText: '🇺🇸', labelText: 'Flag Emoji', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          onChanged: (val) {
                            ab['flag'] = val;
                            abroad[idx] = ab;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('${career.id}_${step.id}_ab_${idx}_exam'),
                          initialValue: ab['exam'],
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(hintText: 'USMLE / GRE', labelText: 'Required Exams', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          onChanged: (val) {
                            ab['exam'] = val;
                            abroad[idx] = ab;
                            prov.updateCareer(career.id, career);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('${career.id}_${step.id}_ab_${idx}_salary'),
                          initialValue: ab['salary'],
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(hintText: r'$100k/year', labelText: 'Salary Range', labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          onChanged: (val) {
                            ab['salary'] = val;
                            abroad[idx] = ab;
                            prov.updateCareer(career.id, career);
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
    );
  }

  // 8. Dream Step Form
  Widget _buildDreamStepForm(AdminProvider prov, Career career, CareerStep step) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_dreamtitle',
                label: 'Achieved Title',
                value: step.data['dreamTitle'] ?? '',
                onChanged: (val) {
                  step.data['dreamTitle'] = val;
                  prov.updateCareer(career.id, career);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormField(
                key: '${career.id}_${step.id}_dreamicon',
                label: 'Dream Icon Emoji',
                value: step.data['dreamIcon'] ?? '',
                onChanged: (val) {
                  step.data['dreamIcon'] = val;
                  prov.updateCareer(career.id, career);
                },
              ),
            ),
          ],
        ),
        _buildFormField(
          key: '${career.id}_${step.id}_dreamsub',
          label: 'Achieved Subtitle',
          value: step.data['dreamSubtitle'] ?? '',
          onChanged: (val) {
            step.data['dreamSubtitle'] = val;
            prov.updateCareer(career.id, career);
          },
        ),
        _buildFormField(
          key: '${career.id}_${step.id}_dreamquote',
          label: 'Achieved Motivational Quote',
          value: step.data['dreamQuote'] ?? '',
          maxLines: 3,
          onChanged: (val) {
            step.data['dreamQuote'] = val;
            prov.updateCareer(career.id, career);
          },
        ),
      ],
    );
  }

  // Form Fields Builders
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
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey(key),
            initialValue: value,
            maxLines: maxLines,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            onChanged: onChanged,
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
