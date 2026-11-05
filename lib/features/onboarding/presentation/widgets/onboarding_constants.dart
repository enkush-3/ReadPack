class OnboardingConstants {
  OnboardingConstants._();

  static const List<Map<String, String>> mnGoals = [
    {
      'title': 'Хувь хүний хөгжил',
      'desc': 'Сахилга бат, бүтээмж, шинэ дадал зуршил суулгах',
      'icon': '🚀',
    },
    {
      'title': 'Карьер & Бизнес',
      'desc': 'Мэргэжлийн ур чадвар, манлайлал ба стартап менежмент',
      'icon': '💼',
    },
    {
      'title': 'Сэтгэл зүй & Төвлөрөл',
      'desc': 'Стрессээс ангижрах, дотоод тайвшрал ба эерэг хандлага',
      'icon': '🧠',
    },
    {
      'title': 'Санхүүгийн эрх чөлөө',
      'desc': 'Хөрөнгө оруулалт, мөнгөний сэтгэлгээ ба санхүүгийн сахилга',
      'icon': '💰',
    },
    {
      'title': 'Ертөнцийг танин мэдэх',
      'desc': 'Дэлхийн түүх, гүн ухаан, шинжлэх ухаан ба сонгодог зохиол',
      'icon': '🌍',
    },
  ];

  static const List<Map<String, String>> enGoals = [
    {
      'title': 'Personal Growth',
      'desc': 'Discipline, productivity & building lifelong habits',
      'icon': '🚀',
    },
    {
      'title': 'Career & Business',
      'desc': 'Professional skills, leadership & startup management',
      'icon': '💼',
    },
    {
      'title': 'Psychology & Focus',
      'desc': 'Relieve stress, cultivate calm and mental clarity',
      'icon': '🧠',
    },
    {
      'title': 'Financial Freedom',
      'desc': 'Investing, wealth mindset & financial discipline',
      'icon': '💰',
    },
    {
      'title': 'Exploring the World',
      'desc': 'World history, philosophy, science & classics',
      'icon': '🌍',
    },
  ];

  static const List<String> mnGenres = [
    'Бизнес',
    'Хувь хүний хөгжил',
    'Сэтгэл зүй',
    'Түүх',
    'Уран зөгнөлт',
    'Шинжлэх ухаан',
    'Сонгодог зохиол',
    'Гүн ухаан',
    'Эрүүл мэнд',
    'Манлайлал',
    'Роман',
    'Адал явдал',
  ];

  static const List<String> enGenres = [
    'Business',
    'Personal Growth',
    'Psychology',
    'History',
    'Sci-Fi',
    'Science',
    'Classics',
    'Philosophy',
    'Health',
    'Leadership',
    'Romance',
    'Adventure',
  ];

  static List<Map<String, String>> goals(bool isEn) => isEn ? enGoals : mnGoals;
  static List<String> genres(bool isEn) => isEn ? enGenres : mnGenres;
}
