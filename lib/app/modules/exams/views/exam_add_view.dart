import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/values/app_strings.dart'; // Import the AppStrings
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/custom_text_field.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/exams/controllers/exams_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExamAddView extends GetView<ExamsController> {
  const ExamAddView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String examId = args['examId'] ?? '';
    final bool isEditing = args['isEditing'] ?? false;

    if (isEditing && examId.isNotEmpty && controller.currentExamId.value != examId) {
      controller.loadExamData(examId);
    } else if (!isEditing && controller.currentExamId.value.isNotEmpty) {
      // Reset fields when creating a new exam
      controller.resetFields();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? AppStrings.editExam : AppStrings.addNewExam,
        showBackButton: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.deleteExam(examId),
              tooltip: AppStrings.deleteExam,
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildDateTimeSection(context),
              const SizedBox(height: 20),
              _buildNoteSelection(),
              const SizedBox(height: 20),
              _buildTagsSection(),
              const SizedBox(height: 20),
              _buildNotificationsSection(context),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? AppStrings.updateExam : AppStrings.saveExam,
                onPressed: controller.saveExam,
                isLoading: controller.isLoading.value,
                fullWidth: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.examTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.titleController,
          hintText: AppStrings.examTitle,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.examDescription,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.descriptionController,
          hintText: AppStrings.examDescription,
          maxLines: 3,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exam Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              controller.getFormattedDate(controller.selectedDate.value),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            width: 1,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exam Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              controller.getFormattedTime(controller.selectedTime.value),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectTime(picked);
    }
  }

  Widget _buildNoteSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.linkToNote,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedNoteId.value.isNotEmpty ? controller.selectedNoteId.value : null,
              hint: Text(AppStrings.selectNote),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(8),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(AppStrings.add),
                ),
                ...controller.notes.map((note) {
                  return DropdownMenuItem<String>(
                    value: note.id,
                    child: Text(
                      note.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ],
              onChanged: (String? noteId) {
                controller.selectNote(noteId ?? '');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.noteTags,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.tagController,
                hintText: AppStrings.addTags,
                maxLines: 1,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.addTag,
                ),
                onSubmitted: (_) => controller.addTag(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          return controller.selectedTags.isEmpty
              ? Text(
                  AppStrings.noTagsAddedYet,
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      labelStyle: TextStyle(color: Colors.amber.shade800),
                      deleteIconColor: Colors.amber.shade800,
                      onDeleted: () => controller.removeTag(tag),
                    );
                  }).toList(),
                );
        }),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.examReminders,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() {
              return Switch(
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
                activeColor: AppColors.primaryColor,
              );
            }),
          ],
        ),
        Obx(() {
          if (!controller.notificationsEnabled.value) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                AppStrings.notificationsDisabled,
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddReminderDialog(context),
                      icon: const Icon(Icons.add_alert),
                      label: const Text(AppStrings.addReminder),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showPresetRemindersDialog(context),
                      icon: const Icon(Icons.list),
                      label: Text(AppStrings.quickAdd),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRemindersList(),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRemindersList() {
    return Obx(() {
      if (controller.reminderTimes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            AppStrings.noRemindersSetYet,
            style: TextStyle(
              color: AppColors.secondaryTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.reminderTimes.length,
        itemBuilder: (context, index) {
          final reminderTime = controller.reminderTimes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            color: Colors.blue.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.blue.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.blue),
              title: Text(
                controller.getFormattedReminderTime(reminderTime),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _getReminderDescription(reminderTime),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.removeReminder(reminderTime),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              dense: true,
            ),
          );
        },
      );
    });
  }

  String _getReminderDescription(DateTime reminderTime) {
    final examDateTime = DateTime(
      controller.selectedDate.value.year,
      controller.selectedDate.value.month,
      controller.selectedDate.value.day,
      controller.selectedTime.value.hour,
      controller.selectedTime.value.minute,
    );

    final difference = examDateTime.difference(reminderTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} before exam';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} before exam';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} before exam';
    } else {
      return 'At exam time';
    }
  }

  Future<void> _showAddReminderDialog(BuildContext context) async {
    final examDateTime = DateTime(
      controller.selectedDate.value.year,
      controller.selectedDate.value.month,
      controller.selectedDate.value.day,
      controller.selectedTime.value.hour,
      controller.selectedTime.value.minute,
    );

    DateTime selectedReminderTime = examDateTime.subtract(const Duration(hours: 1));

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select when you want to be reminded:'),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedReminderTime,
                    firstDate: DateTime.now(),
                    lastDate: examDateTime,
                  );

                  if (pickedDate != null) {
                    selectedReminderTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      selectedReminderTime.hour,
                      selectedReminderTime.minute,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 12),
                      Text(DateFormat('MMM d, yyyy').format(selectedReminderTime)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedReminderTime),
                  );

                  if (pickedTime != null) {
                    selectedReminderTime = DateTime(
                      selectedReminderTime.year,
                      selectedReminderTime.month,
                      selectedReminderTime.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 12),
                      Text(DateFormat('h:mm a').format(selectedReminderTime)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedReminderTime.isBefore(examDateTime)) {
                  controller.addReminder(selectedReminderTime);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPresetRemindersDialog(BuildContext context) async {
    final presets = [
      {'name': '30 minutes before', 'days': 0, 'hours': 0, 'minutes': 30},
      {'name': '1 hour before', 'days': 0, 'hours': 1, 'minutes': 0},
      {'name': '3 hours before', 'days': 0, 'hours': 3, 'minutes': 0},
      {'name': '1 day before', 'days': 1, 'hours': 0, 'minutes': 0},
      {'name': '3 days before', 'days': 3, 'hours': 0, 'minutes': 0},
      {'name': '1 week before', 'days': 7, 'hours': 0, 'minutes': 0},
      {'name': '2 weeks before', 'days': 14, 'hours': 0, 'minutes': 0},
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quick Add Reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select preset reminder times:'),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return ListTile(
                      title: Text(preset['name'] as String),
                      leading: const Icon(Icons.alarm),
                      onTap: () {
                        final days = preset['days'] as int;
                        controller.addReminderDaysBeforeExam(days);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
