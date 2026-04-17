import re

with open("lib/screens/auth/auth_screen.dart", "r") as f:
    orig = f.read()

# 1. Strip the switch cases for 'profile' and 'interests' (lines 284 to 369)
# wait, my regex can do this simply
orig = re.sub(r"      case 'profile':.*?      default:", "      default:", orig, flags=re.DOTALL)

# 2. Re-wire Get.offAllNamed('/home') to Get.offAllNamed('/profile-setup') in step='welcome' Google sign-in (wait, google sign in currently delegates to _step='phone' or '/home' directly since it's already registered). Actually, in `auth_screen.dart` if Google sign in skips phone, it means they are fully logged in. Let's send them to "/home" and the home banner will flag them. This is correct.
# Wait, for normal login / register:
orig = orig.replace("setState(() => _step = 'profile');", "Get.offAllNamed('/profile-setup');")
orig = orig.replace("Get.offAllNamed('/home');", "Get.offAllNamed('/home');") # fine

# 3. Strip the _ProfileStep and _InterestsStep widgets
# from `class _ProfileStep` up to the end of `_showZonePicker`
match = re.search(r"// ╔══════════════════════════════════════════════════════╗\n// ║  STEP 4 — PROFILE.*", orig, re.DOTALL)
if match:
    orig = orig.replace(match.group(0), "")

with open("lib/screens/auth/auth_screen.dart", "w") as f:
    f.write(orig)

print("Stripped auth screen")
