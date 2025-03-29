import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/empty_state_widget.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/exams/controllers/exams_controller.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ExamsView extends GetView<ExamsController> {
  const ExamsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Exams & Reminders',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        } else if (controller.exams.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.event_note,
            title: 'No Exams Yet',
            message: 'Add your first exam to get reminders',
            buttonText: 'Add Exam',
            onButtonPressed: () => Get.toNamed(Routes.EXAM_ADD),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchExams,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUpcomingExamsSection(),
                if (controller.pastExams.isNotEmpty) _buildPastExamsSection(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.EXAM_ADD),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingExamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.event_available, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Upcoming Exams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${controller.upcomingExams.length} ${controller.upcomingExams.length == 1 ? 'exam' : 'exams'}',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        if (controller.upcomingExams.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No upcoming exams',
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          )
        else
          _buildExamTimeline(controller.upcomingExams),
      ],
    );
  }

  Widget _buildPastExamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.event_busy, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Past Exams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${controller.pastExams.length} ${controller.pastExams.length == 1 ? 'exam' : 'exams'}',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        _buildExamTimeline(controller.pastExams, isPast: true),
      ],
    );
  }

  Widget _buildExamTimeline(List<dynamic> exams, {bool isPast = false}) {
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          final isFirst = index == 0;
          final isLast = index == exams.length - 1;
          final timelineColor = isPast ? Colors.grey : controller.getTimelineColor(exam);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  isFirst: isFirst,
                  isLast: isLast,
                  indicatorStyle: IndicatorStyle(
                    width: 20,
                    color: timelineColor,
                    padding: const EdgeInsets.all(6),
                  ),
                  endChild: _buildExamCard(exam, isPast),
                  beforeLineStyle: LineStyle(
                    color: timelineColor,
                    thickness: 2,
                  ),
                  afterLineStyle: LineStyle(
                    color: index < exams.length - 1
                        ? (isPast ? Colors.grey : controller.getTimelineColor(exams[index + 1]))
                        : timelineColor,
                    thickness: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamCard(dynamic exam, bool isPast) {
    final Color cardColor = isPast ? Colors.grey.shade100 : Colors.white;
    final Color textColor = isPast ? Colors.grey : AppColors.primaryTextColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: isPast ? 0 : 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPast ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => Get.toNamed(
            Routes.EXAM_ADD,
            arguments: {'examId': exam.id, 'isEditing': true},
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exam.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            Get.toNamed(
                              Routes.EXAM_ADD,
                              arguments: {'examId': exam.id, 'isEditing': true},
                            );
                            break;
                          case 'delete':
                            controller.deleteExam(exam.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isPast ? Colors.grey : AppColors.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exam.formattedExamDate,
                      style: TextStyle(
                        color: isPast ? Colors.grey : AppColors.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isPast ? Colors.grey : AppColors.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exam.formattedExamTime,
                      style: TextStyle(
                        color: isPast ? Colors.grey : AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                if (exam.description != null && exam.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    exam.description!,
                    style: TextStyle(
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPast ? Colors.grey.shade300 : controller.getTimelineColor(exam).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPast ? Icons.check_circle : Icons.timelapse,
                            size: 14,
                            color: isPast ? Colors.grey : controller.getTimelineColor(exam),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPast ? 'Completed' : controller.getRemainingDays(exam),
                            style: TextStyle(
                              fontSize: 12,
                              color: isPast ? Colors.grey : controller.getTimelineColor(exam),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (exam.notificationsEnabled && !isPast)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Reminders On',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (exam.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exam.tags.map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPast ? Colors.grey.shade200 : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: isPast ? Colors.grey : Colors.amber.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    searchController.text = controller.searchQuery.value;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Exams'),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by title, description, or tags',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: controller.updateSearchQuery,
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.updateSearchQuery('');
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
