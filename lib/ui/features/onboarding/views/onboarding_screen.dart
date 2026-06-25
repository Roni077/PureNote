import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/core/config/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final settingsViewModel = context.read<SettingsViewModel>();
    await settingsViewModel.completeOnboarding();
    isFirstLaunch = false;
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _requestPermissions() async {
    // Request notifications permission
    final status = await Permission.notification.request();
    
    if (mounted) {
      if (status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications enabled!')),
        );
        _nextPage();
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission permanently denied. Please enable in settings.')),
        );
        openAppSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications not granted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    icon: Icons.edit_document,
                    title: 'Welcome to PureNote',
                    description: 'A minimalist markdown note-taking app designed for speed and clarity.',
                  ),
                  _buildSlide(
                    icon: Icons.folder_special,
                    title: 'Organize Your Thoughts',
                    description: 'Use folders and tags to keep everything structured. Lock sensitive notes with your fingerprint or PIN.',
                  ),
                  _buildSlide(
                    icon: Icons.notifications_active,
                    title: 'Stay on Track',
                    description: 'Set reminders for your important notes. We need your permission to send you notifications.',
                    actionWidget: ElevatedButton.icon(
                      onPressed: _requestPermissions,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Allow Notifications'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 12.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // Next / Finish Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String description,
    Widget? actionWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (actionWidget != null) ...[
            const SizedBox(height: 32),
            actionWidget,
          ],
        ],
      ),
    );
  }
}
