import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/empty_state_widget.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/flashcards/controllers/flashcards_controller.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class FlashcardsView extends GetView<FlashcardsController> {
  const FlashcardsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Flashcards',
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
        
        if (controller.flashcards.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.flip,
            title: 'No Flashcards Yet',
            message: 'Create your first flashcard to get started',
            buttonText: 'Create Flashcard',
            onButtonPressed: () => Get.toNamed(Routes.FLASHCARD_ADD),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.fetchFlashcards,
          child: Column(
            children: [
              _buildActionButtons(),
              _buildTagsFilter(),
              Expanded(
                child: _buildFlashcardsList(),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.FLASHCARD_ADD),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Study All',
              onPressed: controller.flashcards.isNotEmpty
                  ? controller.startStudySession
                  : null,
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.play_arrow, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Review Due',
              onPressed: controller.flashcardsForReview.isNotEmpty
                  ? controller.startReviewSession
                  : null,
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.replay, size: 18),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildTagsFilter() {
  return Obx(() {
    if (controller.allTags.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: controller.filterTag.isEmpty,
              onSelected: (_) => controller.setFilterTag(''),
              backgroundColor: Colors.grey.shade200,
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColors.primaryColor,
            ),
          ),
          ...controller.allTags.map((tag) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag),
              selected: controller.filterTag.value == tag,
              onSelected: (_) => controller.setFilterTag(tag),
              backgroundColor: Colors.grey.shade200,
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColors.primaryColor,
            ),
          )).toList(),
        ],
      ),
    );
  });
}

  Widget _buildFlashcardsList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = controller.flashcards[index];
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
                      Routes.FLASHCARD_DETAIL,
                      arguments: {'flashcardId': flashcard.id},
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
                                  color: Colors.purple.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flip,
                                  color: Colors.purple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getFamiliarityColor(flashcard.familiarity),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Level ${flashcard.familiarity}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (flashcard.needsReview)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Review',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      flashcard.question,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to view answer',
                                      style: TextStyle(
                                        color: AppColors.secondaryTextColor,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
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
                                        Routes.FLASHCARD_ADD,
                                        arguments: {'flashcardId': flashcard.id, 'isEditing': true},
                                      );
                                      break;
                                    case 'delete':
                                      controller.deleteFlashcard(flashcard.id);
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
                          if (flashcard.lastReviewed != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: AppColors.secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Last reviewed: ${DateFormat('MMM d, yyyy').format(flashcard.lastReviewed!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (flashcard.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: flashcard.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple,
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
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getFamiliarityColor(int familiarity) {
    switch (familiarity) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    searchController.text = controller.searchQuery.value;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Flashcards'),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by question, answer, or tags',
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
