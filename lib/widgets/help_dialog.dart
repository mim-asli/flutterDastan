import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// دیالوگ راهنما با طراحی جدید
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF1E1E1E), // رنگ پس‌زمینه تیره
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(20), width: 1),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // هدر دیالوگ
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'راهنمای بازی داستان',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'بستن',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'پاسخ به سوالات متداول در مورد این بازی نقش‌آفرینی مبتنی بر هوش مصنوعی.',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white10),

              // محتوای اسکرول‌خور (سوالات متداول)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildExpansionTile(
                      title: '«داستان» چیست؟',
                      content:
                          '«داستان» یک بازی نقش‌آفرینی متنی (Text-Based RPG) است که توسط هوش مصنوعی (AI) هدایت می‌شود. در این بازی هیچ داستان از پیش نوشته شده‌ای وجود ندارد. هر اقدام شما، هر انتخاب و هر کلمه‌ای که تایپ می‌کنید، داستان را به شکلی منحصر به فرد شکل می‌دهد. هوش مصنوعی در نقش «استاد بازی» یا (GM) دنیایی زنده را توصیف می‌کند، به اقدامات شما واکنش نشان می‌دهد و چالش‌های جدیدی را پیش روی شما قرار می‌دهد.',
                      isExpanded: true, // اولین مورد باز باشد
                    ),
                    _buildExpansionTile(
                      title: 'چگونه بازی کنم؟',
                      content:
                          'شما در نقش قهرمان داستان هستید. راوی (هوش مصنوعی) موقعیت را توصیف می‌کند و شما تصمیم می‌گیرید چه کاری انجام دهید. می‌توانید از گزینه‌های پیشنهادی استفاده کنید یا هر کاری که به ذهنتان می‌رسد را تایپ کنید (مثلاً "به سمت قلعه می‌روم" یا "با شمشیر حمله می‌کنم").',
                    ),
                    _buildExpansionTile(
                      title: 'آیا به کلید API نیاز دارم؟',
                      content:
                          'خیر، این نسخه از بازی به گونه‌ای تنظیم شده است که بدون نیاز به تنظیمات پیچیده توسط کاربر کار کند. اما اگر بخواهید از مدل‌های هوش مصنوعی شخصی خود استفاده کنید، می‌توانید در بخش تنظیمات کلید API خود را وارد کنید.',
                    ),
                    _buildExpansionTile(
                      title: 'تولید تصویر چیست؟',
                      content:
                          'بازی می‌تواند برای هر صحنه یا اتفاق مهم، یک تصویر منحصر به فرد با هوش مصنوعی تولید کند تا فضای داستان را بهتر حس کنید. این قابلیت ممکن است نیاز به اینترنت داشته باشد.',
                    ),
                    _buildExpansionTile(
                      title: 'بازی چگونه ذخیره می‌شود؟',
                      content:
                          'بازی به صورت خودکار بعد از هر نوبت (Turn) ذخیره می‌شود. شما می‌توانید در هر لحظه بازی را ببندید و بعداً از همان‌جا ادامه دهید. همچنین امکان ایجاد چندین فایل ذخیره (Save Slot) وجود دارد.',
                    ),
                    _buildExpansionTile(
                      title: 'وضعیت‌های حیاتی چیستند؟',
                      content: 'شخصیت شما دارای ۴ وضعیت اصلی است:\n'
                          '❤️ سلامتی: جان شما. اگر تمام شود، می‌میرید.\n'
                          '🧠 روان: سلامت ذهنی. کاهش آن باعث توهم یا تصمیمات اشتباه می‌شود.\n'
                          '🍗 گرسنگی: باید غذا بخورید تا انرژی داشته باشید.\n'
                          '⚡ انرژی: برای انجام کارهای فیزیکی سنگین مصرف می‌شود.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String content,
    bool isExpanded = false,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent, // حذف خط جداکننده پیش‌فرض
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white54,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        children: [
          Text(
            content,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              color: Colors.white70,
              height: 1.8, // فاصله خطوط بیشتر برای خوانایی
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
