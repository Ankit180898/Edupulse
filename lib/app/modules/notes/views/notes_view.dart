import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/empty_state_widget.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/notes/controllers/notes_controller.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Notes',
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
        }
        
        if (controller.notes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.note_alt_outlined,
            title: 'No Notes Yet',
            message: 'Add your first note to get started',
            buttonText: 'Add Note',
            onButtonPressed: () => Get.toNamed(Routes.NOTE_ADD),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.fetchNotes,
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.notes.length,
              itemBuilder: (context, index) {
                final note = controller.notes[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            Routes.NOTE_DETAIL,
                            arguments: {'noteId': note.id},
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        note.hasFile ? Icons.file_present : Icons.note,
                                        color: AppColors.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('MMM d, yyyy').format(note.updatedAt),
                                            style: TextStyle(
                                              color: AppColors.secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            Get.toNamed(
                                              Routes.NOTE_ADD,
                                              arguments: {'noteId': note.id, 'isEditing': true},
                                            );
                                            break;
                                          case 'delete':
                                            controller.deleteNote(note.id);
                                            break;
                                          case 'summarize':
                                            controller.generateSummary(note.id);
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
                                          value: 'summarize',
                                          child: ListTile(
                                            leading: Icon(Icons.auto_awesome),
                                            title: Text('Summarize'),
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
                                Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                                if (note.tags.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: note.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.accentColor,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                if (note.summary != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 16,
                                        color: AppColors.accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'AI Summary Available',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.accentColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.NOTE_ADD),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
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
          title: const Text('Search Notes'),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by title, content, or tags',
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
