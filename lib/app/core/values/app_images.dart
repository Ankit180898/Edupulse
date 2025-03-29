class AppImages {
  // Logo and Icons
  static const String logo = 'assets/images/logo.svg';
  static const String placeholder = 'assets/images/placeholder.svg';
  
  // Stock photos - Study Materials
  static const String studyMaterials1 = 'https://images.unsplash.com/photo-1518775946895-f4b56f17d79c';
  static const String studyMaterials2 = 'https://images.unsplash.com/photo-1732304719443-c3c04003bf25';
  static const String studyMaterials3 = 'https://images.unsplash.com/photo-1471107191679-f26174d2d41e';
  static const String studyMaterials4 = 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf';
  static const String studyMaterials5 = 'https://images.unsplash.com/photo-1488998427799-e3362cec87c3';
  static const String studyMaterials6 = 'https://images.unsplash.com/photo-1519389950473-47ba0277781c';

  // Stock photos - Students Studying
  static const String studentsStudying1 = 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173';
  static const String studentsStudying2 = 'https://images.unsplash.com/photo-1514369118554-e20d93546b30';
  static const String studentsStudying3 = 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f';
  static const String studentsStudying4 = 'https://images.unsplash.com/photo-1531545514256-b1400bc00f31';

  // Stock photos - Education App Screenshots
  static const String educationApp1 = 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6';
  static const String educationApp2 = 'https://images.unsplash.com/photo-1519452575417-564c1401ecc0';
  static const String educationApp3 = 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b';
  static const String educationApp4 = 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d';

  // Feature illustrations
  static const String notesSvg = 'assets/images/notes.svg';
  static const String flashcardsSvg = 'assets/images/flashcards.svg';
  static const String mcqSvg = 'assets/images/mcq.svg';
  static const String examsSvg = 'assets/images/exams.svg';
  static const String aiSvg = 'assets/images/ai.svg';
  static const String subscriptionSvg = 'assets/images/subscription.svg';
  static const String emptyNotesSvg = 'assets/images/empty_notes.svg';
  static const String emptyFlashcardsSvg = 'assets/images/empty_flashcards.svg';
  static const String emptyMcqSvg = 'assets/images/empty_mcq.svg';
  static const String emptyExamsSvg = 'assets/images/empty_exams.svg';
  static const String successSvg = 'assets/images/success.svg';
  
  // Get images for home carousel
  static List<String> getHomeCarouselImages() {
    return [
      studyMaterials1,
      studentsStudying1,
      educationApp1,
      studyMaterials3,
      studentsStudying3,
    ];
  }
  
  // Get random study material image
  static String getRandomStudyMaterialImage() {
    final images = [
      studyMaterials1,
      studyMaterials2,
      studyMaterials3,
      studyMaterials4,
      studyMaterials5,
      studyMaterials6,
    ];
    
    final index = DateTime.now().millisecondsSinceEpoch % images.length;
    return images[index];
  }
  
  // Get random student studying image
  static String getRandomStudentStudyingImage() {
    final images = [
      studentsStudying1,
      studentsStudying2,
      studentsStudying3,
      studentsStudying4,
    ];
    
    final index = DateTime.now().millisecondsSinceEpoch % images.length;
    return images[index];
  }
  
  // Get random education app image
  static String getRandomEducationAppImage() {
    final images = [
      educationApp1,
      educationApp2,
      educationApp3,
      educationApp4,
    ];
    
    final index = DateTime.now().millisecondsSinceEpoch % images.length;
    return images[index];
  }
}
