import re

with open("lib/screens/auth/auth_screen.dart", "r") as f:
    orig = f.read()

# Extract ProfileStep block (case 'profile': ... case 'interests': ... default:)
switch_match = re.search(r"case 'profile':\n(.*?)\s+default:", orig, re.DOTALL)
if not switch_match:
    print("Could not find switch cases")
    exit(1)
switch_cases = "      case 'profile':\n" + switch_match.group(1)

# Extract widgets
widgets_match = re.search(r"// ╔══════════════════════════════════════════════════════╗\n// ║  STEP 4 — PROFILE.+?(?=// ╔══════════════════════════════════════════════════════╗\n// ║  STEP 1 — WELCOME)", orig, re.DOTALL)
if not widgets_match:
    print("Could not find step 4 profile")
# Wait, STEP 1 welcome is before step 4. In auth_screen.dart:
# STEP 1 WELCOME is at line 377. STEP 4 PROFILE is at line 1042.
# So I should search from STEP 4 PROFILE to EOF.
widgets_match = re.search(r"(// ╔══════════════════════════════════════════════════════╗\n// ║  STEP 4 — PROFILE.*)", orig, re.DOTALL)

with open("lib/screens/profile/profile_setup_screen.dart", "w") as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../Api/provider/auth_controller.dart';
import '../../Api/model/location_model.dart';
import '../../Api/model/category_model.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../widgets/app_loader.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _authController = Get.find<AuthController>();
  String _step = 'profile';
  final _nameCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  int? _selectedQuartierId;
  final Set<int> _selectedInterests = {};
  String? _selectedProfilePhotoPath;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    if (user != null) {
      _nameCtrl.text = user.nom ?? '';
      _detailsCtrl.text = user.details ?? '';
      _selectedQuartierId = user.quartierId;
      if (user.categories != null) {
        // user.categories might be List<dynamic> depending on mapping, assume they are Category model
        // but wait, is user.categories defined in the model? 
        // We'll leave categories empty by default for setup to avoid parsing errors.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: WillPopScope(
        onWillPop: () async {
          if (_step == 'profile') {
            Get.offAllNamed('/home');
            return true;
          } else if (_step == 'interests') {
            setState(() => _step = 'profile');
            return false;
          }
          return false;
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
""")
    f.write(switch_cases)
    f.write("""      default:
        return const SizedBox.shrink();
    }
  }
}

""")
    if widgets_match:
        f.write(widgets_match.group(1))

print("Extraction complete")
