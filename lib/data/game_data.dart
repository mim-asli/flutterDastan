// اطلاعات ثابت بازی شامل ژانرها و کلاس‌های شخصیت

class CharacterClass {
  final String id;
  final String name;
  final String description;
  final String strengths;
  final String weaknesses;

  const CharacterClass({
    required this.id,
    required this.name,
    required this.description,
    required this.strengths,
    required this.weaknesses,
  });
}

class GameGenre {
  final String id;
  final String name;
  final List<CharacterClass> classes;

  const GameGenre({
    required this.id,
    required this.name,
    required this.classes,
  });
}

final List<GameGenre> gameGenres = [
  GameGenre(
    id: 'Fantasy',
    name: 'فانتزی (Fantasy)',
    classes: [
      CharacterClass(
        id: 'warrior',
        name: 'جنگجو (Warrior)',
        description: 'متخصص در نبرد تن‌به‌تن و استفاده از سلاح‌های سنگین.',
        strengths: 'سلامت بالا، دفاع قوی',
        weaknesses: 'مانا کم، سرعت پایین',
      ),
      CharacterClass(
        id: 'mage',
        name: 'جادوگر (Mage)',
        description: 'استاد هنرهای جادویی و عناصر طبیعی.',
        strengths: 'قدرت جادویی بالا، حملات از راه دور',
        weaknesses: 'سلامت کم، دفاع ضعیف',
      ),
      CharacterClass(
        id: 'rogue',
        name: 'دزد (Rogue)',
        description: 'سریع، چابک و متخصص در خفا.',
        strengths: 'سرعت بالا، انعطاف',
        weaknesses: 'دفاع متوسط، قدرت حمله محدود',
      ),
      CharacterClass(
        id: 'cleric',
        name: 'کشیش (Cleric)',
        description: 'خادم مقدس که قدرت شفا و پشتیبانی دارد.',
        strengths: 'توانایی شفا، پشتیبانی',
        weaknesses: 'حمله ضعیف، وابسته به مانا',
      ),
      CharacterClass(
        id: 'ranger',
        name: 'کماندار (Ranger)',
        description: 'شکارچی ماهر در طبیعت و تیراندازی.',
        strengths: 'دقت بالا، بقا در طبیعت',
        weaknesses: 'ضعیف در نبرد نزدیک',
      ),
      CharacterClass(
        id: 'paladin',
        name: 'پالادین (Paladin)',
        description: 'شوالیه مقدس که با تاریکی مبارزه می‌کند.',
        strengths: 'دفاع عالی، کاریزما',
        weaknesses: 'کندی، تعصب',
      ),
    ],
  ),
  GameGenre(
    id: 'Sci-Fi',
    name: 'علمی-تخیلی (Sci-Fi)',
    classes: [
      CharacterClass(
        id: 'soldier',
        name: 'سرباز فضایی (Space Marine)',
        description: 'نیروی نظامی آموزش دیده با سلاح‌های پیشرفته.',
        strengths: 'کار با سلاح گرم، تاکتیک',
        weaknesses: 'وابستگی به مهمات',
      ),
      CharacterClass(
        id: 'hacker',
        name: 'هکر (Netrunner)',
        description: 'متخصص نفوذ به سیستم‌های دیجیتال.',
        strengths: 'هک سیستم‌ها، اطلاعات',
        weaknesses: 'ضعیف در نبرد فیزیکی',
      ),
      CharacterClass(
        id: 'engineer',
        name: 'مهندس (Engineer)',
        description: 'سازنده و تعمیرکار ربات‌ها و تجهیزات.',
        strengths: 'تعمیرات، استفاده از گجت',
        weaknesses: 'نبرد مستقیم',
      ),
      CharacterClass(
        id: 'pilot',
        name: 'خلبان (Pilot)',
        description: 'استاد هدایت سفینه‌ها و وسایل نقلیه.',
        strengths: 'ناوبری، واکنش سریع',
        weaknesses: 'مبارزه پیاده',
      ),
      CharacterClass(
        id: 'medic',
        name: 'پزشک (Medic)',
        description: 'متخصص درمان با تکنولوژی‌های پیشرفته.',
        strengths: 'درمان، دانش زیستی',
        weaknesses: 'قدرت آتش کم',
      ),
      CharacterClass(
        id: 'cyborg',
        name: 'سایبورگ (Cyborg)',
        description: 'انسان تقویت شده با قطعات مکانیکی.',
        strengths: 'قدرت بدنی بالا، مقاومت',
        weaknesses: 'آسیب‌پذیری در برابر EMP',
      ),
    ],
  ),
  // سایر ژانرها را می‌توان بعداً اضافه کرد، فعلاً برای نمونه همین دو کافیست
  // یا می‌توان یک کلاس "عمومی" برای سایر ژانرها در نظر گرفت
];

// تابع کمکی برای دریافت کلاس‌های یک ژانر
List<CharacterClass> getClassesForGenre(String genreId) {
  final genre = gameGenres.firstWhere(
    (g) => g.id == genreId,
    orElse: () => gameGenres[0], // پیش‌فرض فانتزی
  );
  return genre.classes;
}

class GameItem {
  final String id;
  final String name;
  final String description;
  final String icon;

  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

final List<GameItem> startingItems = [
  GameItem(
      id: 'potion_health',
      name: 'معجون سلامتی',
      description: 'بازیابی مقداری از سلامتی',
      icon: '🧪'),
  GameItem(
      id: 'torch', name: 'مشعل', description: 'روشنایی در تاریکی', icon: '🔥'),
  GameItem(
      id: 'rope',
      name: 'طناب',
      description: 'برای بالا رفتن و بستن',
      icon: '🪢'),
  GameItem(
      id: 'map',
      name: 'نقشه قدیمی',
      description: 'نقشه‌ای از منطقه',
      icon: '🗺️'),
  GameItem(
      id: 'food',
      name: 'جیره غذایی',
      description: 'برای رفع گرسنگی',
      icon: '🍞'),
  GameItem(
      id: 'water', name: 'قمقمه آب', description: 'برای رفع تشنگی', icon: '💧'),
  GameItem(
      id: 'dagger',
      name: 'خنجر ساده',
      description: 'سلاحی کوچک برای دفاع',
      icon: '🗡️'),
  GameItem(
      id: 'shield',
      name: 'سپر چوبی',
      description: 'دفاع در برابر ضربات ضعیف',
      icon: '🛡️'),
];
