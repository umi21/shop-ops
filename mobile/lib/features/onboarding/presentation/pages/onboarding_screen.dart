import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  static const _pages = [
    _OnboardingPageData(
      title: 'Track Sales &\nExpenses',
      subtitle:
          'Easily record every transaction and keep your business finances organized in one place.',
      imagePath: 'assets/onboarding_images/onboarding_1.png',
    ),
    _OnboardingPageData(
      title: 'Manage Inventory',
      subtitle:
          'Keep tabs on your stock levels and get alerts when it is time to restock.',
      imagePath: 'assets/onboarding_images/onboarding_2.png',
    ),
    _OnboardingPageData(
      title: 'Grow Your Profit',
      subtitle:
          'View simple charts and reports to understand your business health and trends over time.',
      imagePath: 'assets/onboarding_images/onboarding_3.png',
    ),
    _OnboardingPageData(
      title: 'Get Started Today',
      subtitle:
          'Join thousands of business owners making smart decisions with Shop\u2011Ops.',
      imagePath: 'assets/onboarding_images/onboarding_4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() async {
    if (_pageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
      Navigator.pushReplacementNamed(context, AppRoutes.signupRoute);
    }
  }

  void _goBack() {
    if (_pageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() async {
    await _completeOnboarding();
    Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
  }

  String get _buttonLabel {
    if (_pageIndex == _pages.length - 1) return 'Get Started';
    if (_pageIndex == 0) return 'Next';
    return 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = _pageIndex == 0;
    final isLast = _pageIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isFirst)
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF135BEC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.storefront,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Shop-Ops',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ],
                    )
                  else
                    TextButton.icon(
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Color(0xFF135BEC),
                      ),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF135BEC),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                  if (!isLast)
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 24),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64),
                ],
              ),
            ),

            // Paged hero image
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _pageIndex = index),
                  itemBuilder: (context, index) =>
                      _OnboardingImage(imagePath: _pages[index].imagePath),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _AnimatedPageText(
                key: ValueKey('title_$_pageIndex'),
                child: Text(
                  _pages[_pageIndex].title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    height: 1.1,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _AnimatedPageText(
                key: ValueKey('sub_$_pageIndex'),
                child:
                    _buildSubtitle(_pages[_pageIndex].subtitle, isLast),
              ),
            ),

            const SizedBox(height: 28),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child:
                      _OnboardingIndicator(isActive: index == _pageIndex),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF135BEC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _buttonLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Log in footer — last page only
            if (isLast) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await _completeOnboarding();
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.loginRoute);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Already have an account? Log In',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(String text, bool isLast) {
    const brand = 'Shop\u2011Ops';
    if (!isLast || !text.contains(brand)) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF475569),
        ),
      );
    }

    final parts = text.split(brand);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF475569),
        ),
        children: [
          TextSpan(text: parts.first),
          const TextSpan(
            text: brand,
            style: TextStyle(
              color: Color(0xFF135BEC),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.last),
        ],
      ),
    );
  }
}

// Hero image card

class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage({Key? key, required this.imagePath})
      : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: Icon(Icons.image_outlined,
                  size: 64, color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ),
    );
  }
}

// Animated dot indicator

class _OnboardingIndicator extends StatelessWidget {
  const _OnboardingIndicator({Key? key, required this.isActive})
      : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF135BEC)
            : const Color(0xFF135BEC).withOpacity(0.20),
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}

// Fade + slide animation wrapper for title/subtitle

class _AnimatedPageText extends StatefulWidget {
  const _AnimatedPageText({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<_AnimatedPageText> createState() => _AnimatedPageTextState();
}

class _AnimatedPageTextState extends State<_AnimatedPageText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// Data model

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;
}