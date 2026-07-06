class AppConstants {
  static const String appName = 'Kingdom';
  static const String appVersion = '1.0.0';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double xLargeSpacing = 32.0;

  // Border radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double xLargeRadius = 24.0;

  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double xLargeIconSize = 48.0;

  // Profile setup
  static const int maxPhotos = 6;
  static const int maxBioLength = 500;
  static const int minAge = 18;
  static const int maxAge = 100;

  // Interests categories
  static const List<String> interestCategories = [
    'Sports & Fitness',
    'Music',
    'Movies & TV',
    'Books',
    'Travel',
    'Food & Drinks',
    'Art & Culture',
    'Technology',
    'Gaming',
    'Fashion',
    'Photography',
    'Outdoors',
    'Pets',
    'Dancing',
    'Cooking',
    'Business',
  ];

  // Sample interests
  static const Map<String, List<String>> interests = {
    'Sports & Fitness': [
      'Gym', 'Running', 'Yoga', 'Swimming', 'Tennis', 'Basketball',
      'Football', 'Hiking', 'Cycling', 'Boxing', 'Martial Arts'
    ],
    'Music': [
      'Pop', 'Rock', 'Hip-Hop', 'Jazz', 'Classical', 'Electronic',
      'Country', 'R&B', 'Indie', 'Reggae', 'Blues'
    ],
    'Movies & TV': [
      'Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 'Romance',
      'Documentary', 'Thriller', 'Animation', 'Fantasy'
    ],
    'Books': [
      'Fiction', 'Non-Fiction', 'Mystery', 'Romance', 'Biography',
      'Self-Help', 'History', 'Science', 'Poetry', 'Fantasy'
    ],
    'Travel': [
      'Beach', 'Mountains', 'Cities', 'Adventure', 'Backpacking',
      'Luxury', 'Cultural', 'Road Trips', 'Cruises', 'Camping'
    ],
    'Food & Drinks': [
      'Cooking', 'Baking', 'Wine', 'Coffee', 'Cocktails', 'Vegan',
      'Italian', 'Asian', 'Mexican', 'BBQ', 'Desserts'
    ],
  };

  // Gender options
  static const List<String> genderOptions = [
    'Man',
    'Woman',
    'Prefer not to say',
  ];

  // Relationship preferences
  static const List<String> relationshipGoals = [
    'Casual dating',
    'Long-term relationship',
    'Marriage',
    'New friends',
    'Networking',
    "Don't know yet",
  ];
}