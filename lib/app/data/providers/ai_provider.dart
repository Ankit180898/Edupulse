import 'dart:convert';
import 'dart:math';

import 'package:edupulse/app/data/providers/supabase_provider.dart';
import 'package:edupulse/app/data/services/settings_service.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIProvider {
  // Reference to settings service
  final SettingsService _settingsService = Get.find<SettingsService>();

  // Check if we should use demo mode
  bool get _useDemoMode {
    try {
      final apiKey = _settingsService.geminiApiKey.value;
      return apiKey.isEmpty;
    } catch (e) {
      print('Error checking API key: $e');
      return true;
    }
  }

  // Get API key from settings service
  String get _apiKey => _settingsService.geminiApiKey.value;

  // Gemini model - lazy initialized
  GenerativeModel? _geminiModel;

  // Get the Gemini model, initializing if needed
  GenerativeModel? get geminiModel {
    if (_useDemoMode) return null;

    if (_geminiModel == null) {
      try {
        _geminiModel = GenerativeModel(
          model: 'gemini-1.0-pro',
          apiKey: _apiKey,
        );
      } catch (e) {
        print('Error initializing Gemini model: $e');
        return null;
      }
    }

    return _geminiModel;
  }

  // Track demo mode API calls to limit usage
  final SupabaseProvider _supabaseProvider = SupabaseProvider();

  // Summarize text
  Future<String> summarizeText(String text) async {
    // Check if we can use AI credits (whether demo mode or real API)
    final hasCredits = await _supabaseProvider.checkAndDecrementAICredits();
    if (!hasCredits) {
      throw Exception('You have used all your AI credits for today. Please upgrade your plan or try again tomorrow.');
    }

    if (!_useDemoMode) {
      try {
        // Create a prompt for Gemini
        final prompt = 'You are an educational assistant that creates concise summaries of academic content.\n\n'
            'Summarize the following text in a clear, concise manner. Highlight the key points and main ideas:\n\n$text';

        // Use Gemini model to generate content
        if (geminiModel == null) {
          throw Exception('Gemini model is not initialized');
        }
        final content = await geminiModel!.generateContent([Content.text(prompt)]);
        final response = content.text;

        if (response != null) {
          return response.trim();
        } else {
          throw Exception('Failed to generate summary: Empty response');
        }
      } catch (e) {
        throw Exception('Error summarizing text: $e');
      }
    } else {
      // Demo mode - generate a simple summary based on the text
      print('Demo mode: Generating a simulated summary');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay

      // Generate a simple summary by taking parts of the original text
      final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
      final selectedSentences = <String>[];

      // Take every 3rd sentence, or fewer if the text is short
      if (sentences.length <= 5) {
        selectedSentences.addAll(sentences);
      } else {
        for (int i = 0; i < sentences.length; i += 3) {
          if (i < sentences.length) {
            selectedSentences.add(sentences[i]);
          }
        }
        // Add one from the end if we didn't get it
        if (sentences.length > 3 && !selectedSentences.contains(sentences.last)) {
          selectedSentences.add(sentences.last);
        }
      }

      // Add a demo indicator
      return 'Summary (Demo Mode):\n\n${selectedSentences.join(' ')}\n\n(This is a simulated summary for demonstration purposes. Connect a Google Gemini API key for real AI-powered summaries.)';
    }
  }

  // Generate MCQs from text
  Future<List<Map<String, dynamic>>> generateMCQs(String text, int numberOfQuestions) async {
    // Check if we can use AI credits (whether demo mode or real API)
    final hasCredits = await _supabaseProvider.checkAndDecrementAICredits();
    if (!hasCredits) {
      throw Exception('You have used all your AI credits for today. Please upgrade your plan or try again tomorrow.');
    }

    if (!_useDemoMode) {
      try {
        // Create a prompt for Gemini
        final prompt =
            'You are an educational assistant that creates multiple-choice questions based on academic content.\n\n'
            'Create $numberOfQuestions multiple-choice questions based on the following text. Each question should have 4 options (A, B, C, D) with one correct answer.\n\n'
            'Format your response as a JSON array with objects containing "question", "options" (array of 4 strings), and "correctAnswer" (index of correct option, zero-based).\n\n'
            'Text: $text\n\n'
            'Return ONLY the JSON with no other text before or after.';

        // Use Gemini model to generate content
        if (geminiModel == null) {
          throw Exception('Gemini model is not initialized');
        }
final content = await geminiModel!.generateContent([Content.text(prompt)]);        final response = content.text;

        if (response != null) {
          // Extract JSON array from the response
          final RegExp jsonPattern = RegExp(r'\[[\s\S]*\]');
          final match = jsonPattern.firstMatch(response);

          if (match != null) {
            final jsonStr = match.group(0);
            final List<dynamic> jsonData = jsonDecode(jsonStr!);

            return jsonData
                .map<Map<String, dynamic>>((item) => {
                      'question': item['question'],
                      'options': List<String>.from(item['options']),
                      'correctAnswer': item['correctAnswer'],
                    })
                .toList();
          } else {
            throw Exception('Failed to parse MCQ data from response');
          }
        } else {
          throw Exception('Failed to generate MCQs: Empty response');
        }
      } catch (e) {
        throw Exception('Error generating MCQs: $e');
      }
    } else {
      // Demo mode - generate generic MCQs based on the text
      print('Demo mode: Generating simulated MCQs');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay

      // Extract words to use in our mock MCQs
      final words = text.split(RegExp(r'\s+')).where((word) => word.length > 4).toSet().toList();

      final random = Random();
      final result = <Map<String, dynamic>>[];

      // Create a limited number of questions with reasonable answers
      final questionCount = min(numberOfQuestions, 5); // Cap at 5 questions in demo mode

      // Demo questions
      final demoQuestions = [
        'What is the main topic of this text?',
        'Which concept is most emphasized in the text?',
        'According to the text, what is the most important factor to consider?',
        'Which of the following best describes the author\'s viewpoint?',
        'What can be inferred from the text?',
      ];

      for (int i = 0; i < questionCount; i++) {
        // Create random words to use as options
        final optionWords = <String>[];
        for (int j = 0; j < 10 && j < words.length; j++) {
          final randomIndex = random.nextInt(words.length);
          optionWords.add(words[randomIndex]);
        }

        final options = [
          'The ${optionWords[0]} of ${optionWords[1]}',
          'Understanding ${optionWords[2]} through ${optionWords[3]}',
          'The relationship between ${optionWords[4]} and ${optionWords[5]}',
          'How ${optionWords[6]} affects ${optionWords[7]}',
        ];

        final correctAnswer = random.nextInt(4);

        result.add({
          'question': '${demoQuestions[i % demoQuestions.length]} (Demo)',
          'options': options,
          'correctAnswer': correctAnswer,
        });
      }

      return result;
    }
  }

  // Generate flashcards from text
  Future<List<Map<String, dynamic>>> generateFlashcards(String text, int numberOfFlashcards) async {
    // Check if we can use AI credits (whether demo mode or real API)
    final hasCredits = await _supabaseProvider.checkAndDecrementAICredits();
    if (!hasCredits) {
      throw Exception('You have used all your AI credits for today. Please upgrade your plan or try again tomorrow.');
    }

    if (!_useDemoMode) {
      try {
        // Create a prompt for Gemini
        final prompt = 'You are an educational assistant that creates flashcards based on academic content.\n\n'
            'Create $numberOfFlashcards flashcards based on the following text. Each flashcard should have a question/concept on one side and the answer/explanation on the other.\n\n'
            'Format your response as a JSON array with objects containing "question" and "answer".\n\n'
            'Text: $text\n\n'
            'Return ONLY the JSON with no other text before or after.';

        // Use Gemini model to generate content
        if (geminiModel == null) {
          throw Exception('Gemini model is not initialized');
        }
        final content = await geminiModel!.generateContent([Content.text(prompt)]);
        final response = content.text;

        if (response != null) {
          // Extract JSON array from the response
          final RegExp jsonPattern = RegExp(r'\[[\s\S]*\]');
          final match = jsonPattern.firstMatch(response);

          if (match != null) {
            final jsonStr = match.group(0);
            final List<dynamic> jsonData = jsonDecode(jsonStr!);

            return jsonData
                .map<Map<String, dynamic>>((item) => {
                      'question': item['question'],
                      'answer': item['answer'],
                    })
                .toList();
          } else {
            throw Exception('Failed to parse flashcard data from response');
          }
        } else {
          throw Exception('Failed to generate flashcards: Empty response');
        }
      } catch (e) {
        throw Exception('Error generating flashcards: $e');
      }
    } else {
      // Demo mode - generate simple flashcards based on the text
      print('Demo mode: Generating simulated flashcards');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay

      // Extract sentences to create flashcard questions
      final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
      final random = Random();
      final result = <Map<String, dynamic>>[];

      // Create a limited number of flashcards with sample content
      final cardCount = min(numberOfFlashcards, 5); // Cap at 5 flashcards in demo mode

      // Demo flashcard prefixes
      final demoQuestions = [
        'Define: ',
        'Explain: ',
        'Describe: ',
        'What is ',
        'How does ',
      ];

      // Demo flashcard answer prefixes
      final demoAnswers = [
        'This refers to ',
        'The concept of ',
        'This describes ',
        'This is defined as ',
        'This involves ',
      ];

      for (int i = 0; i < cardCount; i++) {
        if (sentences.isEmpty) break;

        // Pick a random sentence and extract key terms
        final sentenceIndex = random.nextInt(sentences.length);
        final sentence = sentences[sentenceIndex];
        final words = sentence.split(RegExp(r'\s+')).where((word) => word.length > 4).toList();

        if (words.isEmpty) continue;

        // Create a question based on a term from the sentence
        final wordIndex = random.nextInt(words.length);
        final word = words[wordIndex].replaceAll(RegExp(r'[^\w\s]'), '');

        // Randomly select a question prefix
        final questionPrefix = demoQuestions[i % demoQuestions.length];
        final question = '$questionPrefix$word (Demo)';

        // Create an answer using parts of the sentence
        final answerPrefix = demoAnswers[i % demoAnswers.length];
        final answer = '$answerPrefix${sentence.substring(0, min(sentence.length, 100))}... (Demo answer)';

        result.add({
          'question': question,
          'answer': answer,
        });
      }

      // Add a note about demo mode if there are no flashcards
      if (result.isEmpty) {
        result.add({
          'question': 'Sample Flashcard (Demo)',
          'answer':
              'This is a sample flashcard in demo mode. Connect a Google Gemini API key for real AI-generated flashcards.',
        });
      }

      return result;
    }
  }

  // Extract key points from text
  Future<List<String>> extractKeyPoints(String text) async {
    // Check if we can use AI credits (whether demo mode or real API)
    final hasCredits = await _supabaseProvider.checkAndDecrementAICredits();
    if (!hasCredits) {
      throw Exception('You have used all your AI credits for today. Please upgrade your plan or try again tomorrow.');
    }

    if (!_useDemoMode) {
      try {
        // Create a prompt for Gemini
        final prompt = 'You are an educational assistant that extracts key points from academic content.\n\n'
            'Extract the 5-10 most important key points from the following text. Format the response as a JSON array of strings.\n\n'
            'Text: $text\n\n'
            'Return ONLY the JSON with no other text before or after.';

        // Use Gemini model to generate content
        if (geminiModel == null) {
          throw Exception('Gemini model is not initialized');
        }
        final content = await geminiModel!.generateContent([Content.text(prompt)]);
        final response = content.text;

        if (response != null) {
          // Extract JSON array from the response
          final RegExp jsonPattern = RegExp(r'\[[\s\S]*\]');
          final match = jsonPattern.firstMatch(response);

          if (match != null) {
            final jsonStr = match.group(0);
            final List<dynamic> jsonData = jsonDecode(jsonStr!);

            return List<String>.from(jsonData);
          } else {
            throw Exception('Failed to parse key points from response');
          }
        } else {
          throw Exception('Failed to extract key points: Empty response');
        }
      } catch (e) {
        throw Exception('Error extracting key points: $e');
      }
    } else {
      // Demo mode - generate key points by extracting sentences
      print('Demo mode: Generating simulated key points');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay

      // Split text into sentences
      final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
      final keyPoints = <String>[];

      // Select sentences to use as key points (first, middle, and last parts of text)
      if (sentences.length <= 5) {
        // For very short texts, just use all sentences
        for (int i = 0; i < sentences.length; i++) {
          keyPoints.add('${sentences[i]} (Demo key point)');
        }
      } else {
        // For longer texts, sample evenly from beginning, middle and end
        keyPoints.add('${sentences[0]} (Demo key point)');

        final quarterPoint = sentences.length ~/ 4;
        if (quarterPoint < sentences.length) {
          keyPoints.add('${sentences[quarterPoint]} (Demo key point)');
        }

        final midPoint = sentences.length ~/ 2;
        if (midPoint < sentences.length) {
          keyPoints.add('${sentences[midPoint]} (Demo key point)');
        }

        final threeQuarterPoint = (sentences.length * 3) ~/ 4;
        if (threeQuarterPoint < sentences.length) {
          keyPoints.add('${sentences[threeQuarterPoint]} (Demo key point)');
        }

        if (sentences.length > 1) {
          keyPoints.add('${sentences[sentences.length - 1]} (Demo key point)');
        }
      }

      // Ensure we have something even with short texts
      if (keyPoints.isEmpty) {
        keyPoints.add('This is a demo key point. Connect a Google Gemini API key for real AI analysis.');
      }

      return keyPoints;
    }
  }

  // Generate a study plan
  Future<String> generateStudyPlan(String subject, List<String> topics, int daysAvailable) async {
    // Check if we can use AI credits (whether demo mode or real API)
    final hasCredits = await _supabaseProvider.checkAndDecrementAICredits();
    if (!hasCredits) {
      throw Exception('You have used all your AI credits for today. Please upgrade your plan or try again tomorrow.');
    }

    if (!_useDemoMode) {
      try {
        // Create a prompt for Gemini
        final topicsText = topics.join(', ');
        final prompt = 'You are an educational assistant that creates personalized study plans.\n\n'
            'Create a detailed study plan for the subject "$subject" covering these topics: $topicsText.\n\n'
            'The study plan should be spread over $daysAvailable days, with daily goals, resource recommendations, and study techniques.\n\n'
            'Format the plan in markdown with clear headings, bullet points, and a daily breakdown.';

        // Use Gemini model to generate content
        if (geminiModel == null) {
          throw Exception('Gemini model is not initialized');
        }
        final content = await geminiModel!.generateContent([Content.text(prompt)]);
        final response = content.text;

        if (response != null) {
          return response.trim();
        } else {
          throw Exception('Failed to generate study plan: Empty response');
        }
      } catch (e) {
        throw Exception('Error generating study plan: $e');
      }
    } else {
      // Demo mode - generate a simple study plan
      print('Demo mode: Generating a simulated study plan');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay

      final random = Random();
      final studyPlan = StringBuffer();

      // Create a simple study plan header
      studyPlan.writeln('# Study Plan for $subject (Demo Mode)');
      studyPlan.writeln('\n## Overview');
      studyPlan.writeln('This is a $daysAvailable-day study plan to help you master $subject.');
      studyPlan.writeln('\n## Topics to Cover:');

      // List all topics
      for (final topic in topics) {
        studyPlan.writeln('- $topic');
      }

      // Create a day-by-day plan
      studyPlan.writeln('\n## Day-by-Day Schedule:');

      // Distribute topics across available days
      final topicsPerDay = (topics.length / daysAvailable).ceil();
      int topicIndex = 0;

      for (int day = 1; day <= daysAvailable; day++) {
        studyPlan.writeln('\n### Day $day:');

        // Add topics for this day
        studyPlan.writeln('\n**Focus Areas:**');
        for (int i = 0; i < topicsPerDay && topicIndex < topics.length; i++) {
          studyPlan.writeln('- ${topics[topicIndex]}');
          topicIndex++;
        }

        // Add study strategies
        final studyStrategies = [
          'Read textbook chapters related to today\'s topics',
          'Watch video lectures on the subject',
          'Create summary notes in your own words',
          'Practice with example problems or exercises',
          'Review previous day\'s material',
          'Create flashcards for key concepts',
          'Take a practice quiz or test',
          'Discuss concepts with study partners',
        ];

        studyPlan.writeln('\n**Study Activities:**');
        for (int i = 0; i < 3; i++) {
          final strategyIndex = random.nextInt(studyStrategies.length);
          studyPlan.writeln('- ${studyStrategies[strategyIndex]}');
        }
      }

      // Add a review day if there are enough days
      if (daysAvailable > 3) {
        studyPlan.writeln('\n### Day $daysAvailable (Final Review):');
        studyPlan.writeln('\n**Focus Areas:**');
        studyPlan.writeln('- Review all topics');
        studyPlan.writeln('- Practice with mock questions');
        studyPlan.writeln('- Identify and focus on weak areas');
      }

      // Add a demo mode disclaimer
      studyPlan.writeln('\n\n---');
      studyPlan.writeln(
          '*This is a simulated study plan generated in demo mode. For personalized AI-generated study plans, connect a Google Gemini API key in the settings.*');

      return studyPlan.toString();
    }
  }

  // Explain a concept in simple terms
  Future<String> explainConcept(String concept, String targetAgeGroup) async {
    // Check if we can use AI credits (whether demo mode or real API)
    final hasCredits = await _supabaseProvider.checkAndDecrementAICredits();
    if (!hasCredits) {
      throw Exception('You have used all your AI credits for today. Please upgrade your plan or try again tomorrow.');
    }

    if (!_useDemoMode) {
      try {
        // Create a prompt for Gemini
        final prompt = 'You are an educational assistant that explains complex concepts in simple terms.\n\n'
            'Explain the concept of "$concept" in terms that would be understood by someone in the $targetAgeGroup age group.\n\n'
            'Use simple language, analogies, and examples appropriate for the age group. Format your response in a clear, engaging manner.';

        // Use Gemini model to generate content
        if (geminiModel == null) {
          throw Exception('Gemini model is not initialized');
        }
        final content = await geminiModel!.generateContent([Content.text(prompt)]);
        final response = content.text;

        if (response != null) {
          return response.trim();
        } else {
          throw Exception('Failed to explain concept: Empty response');
        }
      } catch (e) {
        throw Exception('Error explaining concept: $e');
      }
    } else {
      // Demo mode - generate a simple explanation
      print('Demo mode: Generating a simulated explanation');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay

      final explanation = StringBuffer();

      // Create a simple explanation based on the target age group
      explanation.writeln('# Explaining "$concept" (Demo Mode)');

      // Different explanations based on age group
      if (targetAgeGroup.contains('elementary') ||
          targetAgeGroup.contains('6-10') ||
          targetAgeGroup.contains('child')) {
        explanation.writeln(
            '\nImagine you have a toy that does something special. $concept is like that toy, but for grown-ups!');
        explanation.writeln(
            '\nIt\'s like when you play with your friends and have to follow certain rules. That\'s how $concept works too.');
        explanation.writeln(
            '\nYou know how you learn new things at school every day? $concept is one of those interesting things that helps people solve problems and make life easier.');
      } else if (targetAgeGroup.contains('middle') ||
          targetAgeGroup.contains('11-14') ||
          targetAgeGroup.contains('teen')) {
        explanation.writeln(
            '\n$concept is a key idea that you\'ll encounter in your studies. Think of it as a tool that helps us understand how things work in the world.');
        explanation.writeln(
            '\nYou know how video games have rules that make the game work? $concept is like a set of rules that explain a part of our world.');
        explanation.writeln(
            '\nWhen you\'re solving problems in school, you often use different methods. $concept is one of those methods that helps in specific situations.');
      } else {
        explanation.writeln(
            '\n$concept represents a fundamental principle in its field. It provides a framework for understanding related phenomena and serves as a basis for more advanced concepts.');
        explanation.writeln(
            '\nThe application of $concept can be observed in various real-world scenarios, from everyday experiences to specialized contexts.');
        explanation.writeln(
            '\nUnderstanding $concept allows us to analyze situations more effectively and make informed decisions based on established principles.');
      }

      // Add a demo mode disclaimer
      explanation.writeln('\n\n---');
      explanation.writeln(
          '*This is a simulated explanation generated in demo mode. For accurate AI-generated explanations, connect a Google Gemini API key in the settings.*');

      return explanation.toString();
    }
  }
}
