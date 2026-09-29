/// Comprehensive translation dictionary supporting English and Sinhala (සිංහල).
class AppTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Actions
      'app_name': 'Trace Expense Tracker',
      'settings': 'Settings',
      'language': 'Language',
      'language_subtitle': 'Choose your preferred language',
      'select_language': 'Select Language',
      'english': 'English',
      'sinhala': 'සිංහල (Sinhala)',
      'save': 'Save',
      'cancel': 'Cancel',
      'add_expense': 'Add Expense',
      'delete': 'Delete',
      'edit': 'Edit',
      'undo': 'Undo',
      'reset': 'Reset',
      'clear': 'Clear',
      'skip': 'Skip',
      'all': 'All',
      'search_hint': 'Search expenses, categories, notes...',
      
      // Dashboard Header & Cards
      'hello': 'Hello',
      'smart_saver': 'Smart Saver',
      'this_month_spending': "THIS MONTH'S SPENDING",
      'daily_spending': 'DAILY SPENDING',
      'selected_month': 'SELECTED MONTH',
      'set_target': 'Set Target',
      'on_track': 'On Track',
      'limit_warning': '80%+ Limit',
      'exceeded': 'Exceeded',
      'budget_exceeded_by': 'Budget exceeded by',
      'of_limit': 'of limit',
      'left': 'left',
      'transactions': 'Transactions',
      'daily_avg': 'Daily Avg',
      'budget_left': 'Budget Left',
      'top_spending': 'Top Spending',
      'no_limit': 'No Limit',
      'none': 'None',
      
      // Sections
      'categories': 'Categories',
      'recent_transactions': 'Recent Transactions',
      'all_month': 'All Month',
      'monthly_target': 'Monthly Target',
      'set_spending_limit': 'Set a spending limit for',
      'remove_limit': 'Remove Limit',
      'overall_budget': 'Overall Budget',
      'category_budgets': 'Category Budgets',
      'set_category_limit': 'Set Category Limit',
      'all_categories': 'All Categories',
      'no_limit_set': 'No limit set',
      'total_category_budget': 'Allocated to Categories',
      'category_budget_saved': 'Category budget saved!',
      'category_budget_removed': 'Category budget removed',
      'category_limit': 'Category Limit',
      
      // Options Menu
      'select_month_day': 'Select Month / Day',
      'export_report': 'Export Report (PDF/CSV)',
      'recycle_bin': 'Recycle Bin',
      'theme_colors': 'Theme & Colors',
      'onboarding_story': 'Onboarding Story',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      
      // Settings Page
      'general_settings': 'General',
      'appearance': 'Appearance',
      'theme_mode': 'Theme Mode',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'system_theme': 'System',
      'accent_color': 'Accent Color',
      'preferences': 'Preferences',
      'currency': 'Currency',
      'currency_subtitle': 'Choose currency symbol for all expense tracking',
      'select_currency': 'Select Currency',
      'search_currency_hint': 'Search currency by name, code, or symbol...',
      'popular_currencies': 'Popular Currencies',
      'currency_changed': 'Currency changed to',
      'no_currencies_found': 'No matching currencies found',
      'data_management': 'Data & Management',
      'manage_deleted_items': 'Manage deleted items (kept for 5 days)',
      'download_expense_records': 'Download PDF or CSV reports',
      'account': 'Account',
      'logged_in_as': 'Logged in as',
      'about': 'About',
      'app_version': 'Version 1.0.0',
      'developed_with_love': 'Crafted with Flutter & Firebase',
      'language_applied_notice': 'Language changed to English successfully',

      // Security & Biometric Lock
      'security': 'Security',
      'biometric_lock': 'Biometric App Lock',
      'biometric_lock_subtitle': 'Protect your finances with fingerprint, Face ID, or PIN',
      'biometric_not_supported': 'Biometric authentication is not supported or set up on this device.',
      'biometric_auth_reason': 'Authenticate to unlock Expense Tracker',
      'biometric_enable_reason': 'Confirm your identity to enable Biometric Lock',
      'biometric_disable_reason': 'Confirm your identity to disable Biometric Lock',
      'biometric_auth_failed': 'Authentication failed. Please try again.',
      'biometric_lock_enabled_msg': 'Biometric lock enabled successfully',
      'biometric_lock_disabled_msg': 'Biometric lock disabled',
      'unlock_app': 'Unlock App',
      'app_locked': 'App Locked',
      'touch_sensor_to_unlock': 'Use fingerprint, Face ID, or device passcode to unlock.',
      'unlock_now': 'Unlock Now',
      'switch_account': 'Switch Account / Log Out',

      // Notifications & Reminders
      'notifications': 'Notifications & Alerts',
      'notifications_subtitle': 'Daily reminders, budget alerts & cleanup notices',
      'enable_notifications': 'Enable Notifications',
      'enable_notifications_desc': 'Receive reminders and real-time financial alerts',
      'daily_reminder': 'Daily Expense Reminder',
      'daily_reminder_desc': 'Remind me to record today\'s expenses every day',
      'reminder_time': 'Reminder Time',
      'set_reminder_time': 'Set Daily Reminder Time',
      'change_time': 'Change Time',
      'budget_alerts': 'Budget Warning Alerts',
      'budget_alerts_desc': 'Notify when spending reaches 80% or 100% of limits',
      'test_notification': 'Send Test Notification',
      'test_notification_sent': 'Test notification sent!',
      'test_notification_title': 'Expense Tracker Test Alert 🔔',
      'test_notification_body': 'Notifications are configured and working properly!',
      'daily_reminder_title': 'Expense Reminder 📝',
      'daily_reminder_body': 'Don\'t forget to record today\'s expenses!',
      'budget_warning_80_title': 'Budget Warning (80% Reached) ⚠️',
      'budget_exceeded_title': 'Budget Limit Exceeded! 🚨',
      'budget_warning_overall_body': 'You have spent 80% or more of your overall monthly budget limit.',
      'budget_exceeded_overall_body': 'You have exceeded your overall monthly budget limit!',
      'budget_warning_category_body': 'category has reached 80% or more of its allocated budget limit.',
      'budget_exceeded_category_body': 'category has exceeded its allocated budget limit!',
      'recycle_bin_warning_title': 'Recycle Bin Notice 🗑️',
      'recycle_bin_warning_body': 'item(s) in recycle bin will be permanently deleted after 5 days.',
      'notification_permission_denied': 'Notification permission was denied. Please allow notifications in device settings.',
      'test_timer_10s': 'Test Scheduled Reminder (10 seconds)',
      'test_timer_started': 'Test reminder scheduled for 10 seconds from now! Minimize or lock phone to test.',
      
      // Categories
      'cat_food': 'Food & Dining',
      'cat_transport': 'Transport',
      'cat_shopping': 'Shopping',
      'cat_entertainment': 'Entertainment',
      'cat_bills': 'Bills & Utilities',
      'cat_health': 'Health & Medical',
      'cat_education': 'Education',
      'cat_other': 'Other',

      // Navigation
      'home': 'Home',
      'analytics': 'Analytics',
    },
    'si': {
      // General & Actions
      'app_name': 'ට්‍රේස් වියදම් කළමනාකරු',
      'settings': 'සැකසීම්',
      'language': 'භාෂාව',
      'language_subtitle': 'ඔබ කැමති භාෂාව තෝරාගන්න',
      'select_language': 'භාෂාව තෝරන්න',
      'english': 'English',
      'sinhala': 'සිංහල (Sinhala)',
      'save': 'සුරකින්න',
      'cancel': 'අවලංගු කරන්න',
      'add_expense': 'වියදමක් එක් කරන්න',
      'delete': 'මකන්න',
      'edit': 'සංස්කරණය',
      'undo': 'පෙර තත්වයට',
      'reset': 'යළි පිහිටුවන්න',
      'clear': 'ඉවත් කරන්න',
      'skip': 'මඟහරින්න',
      'all': 'සියල්ල',
      'search_hint': 'වියදම්, කාණ්ඩ, සටහන් සොයන්න...',
      
      // Dashboard Header & Cards
      'hello': 'ආයුබෝවන්',
      'smart_saver': 'බුද්ධිමත් ඉතුරුම්කරු',
      'this_month_spending': 'මෙම මස වියදම',
      'daily_spending': 'දෛනික වියදම',
      'selected_month': 'තෝරාගත් මාසය',
      'set_target': 'ඉලක්කයක් යොදන්න',
      'on_track': 'නියමිත පරිදි',
      'limit_warning': '80%+ සීමාව',
      'exceeded': 'ඉක්මවා ඇත',
      'budget_exceeded_by': 'අයවැය ඉක්මවා ඇත්තේ',
      'of_limit': 'සීමාවෙන්',
      'left': 'ඉතිරි',
      'transactions': 'ගනුදෙනු',
      'daily_avg': 'දෛනික සාමාන්‍යය',
      'budget_left': 'ඉතිරි අයවැය',
      'top_spending': 'වැඩිම වියදම',
      'no_limit': 'සීමාවක් නැත',
      'none': 'නැත',
      
      // Sections
      'categories': 'කාණ්ඩ',
      'recent_transactions': 'මෑත ගනුදෙනු',
      'all_month': 'මුළු මාසය',
      'monthly_target': 'මාසික ඉලක්කය',
      'set_spending_limit': 'සඳහා වියදම් සීමාවක් සකසන්න',
      'remove_limit': 'සීමාව ඉවත් කරන්න',
      'overall_budget': 'සමස්ත අයවැය',
      'category_budgets': 'කාණ්ඩ අයවැය සීමා',
      'set_category_limit': 'කාණ්ඩ සීමාව සකසන්න',
      'all_categories': 'සියලුම කාණ්ඩ',
      'no_limit_set': 'සීමාවක් සකසා නැත',
      'total_category_budget': 'කාණ්ඩ සඳහා වෙන් කළ මුදල',
      'category_budget_saved': 'කාණ්ඩ අයවැය සුරැකිණි!',
      'category_budget_removed': 'කාණ්ඩ අයවැය ඉවත් කරන ලදී',
      'category_limit': 'කාණ්ඩ සීමාව',
      
      // Options Menu
      'select_month_day': 'මාසය / දිනය තෝරන්න',
      'export_report': 'වාර්තාව බාගන්න (PDF/CSV)',
      'recycle_bin': 'කසළ බඳුන',
      'theme_colors': 'තේමාව සහ වර්ණ',
      'onboarding_story': 'මඟපෙන්වීම (Onboarding)',
      'sign_out': 'ඉවත් වන්න',
      'sign_out_confirm': 'ඔබට ගිණුමෙන් ඉවත් වීමට අවශ්‍යද?',
      
      // Settings Page
      'general_settings': 'පොදු සැකසීම්',
      'appearance': 'පෙනුම',
      'theme_mode': 'තේමා ප්‍රකාරය',
      'light_theme': 'දීප්තිමත්',
      'dark_theme': 'අඳුරු',
      'system_theme': 'පද්ධති',
      'accent_color': 'ප්‍රධාන වර්ණය',
      'preferences': 'මනාපයන්',
      'currency': 'මුදල් ඒකකය',
      'currency_subtitle': 'සියලු වියදම් සඳහා මුදල් ඒකකය තෝරන්න',
      'select_currency': 'මුදල් ඒකකය තෝරන්න',
      'search_currency_hint': 'නම හෝ කේතය මඟින් සොයන්න (උදා: LKR, USD)...',
      'popular_currencies': 'ජනප්‍රිය මුදල් ඒකක',
      'currency_changed': 'මුදල් ඒකකය වෙනස් කරන ලදී',
      'no_currencies_found': 'ගැලපෙන මුදල් ඒකක හමු නොවීය',
      'data_management': 'දත්ත සහ කළමනාකරණය',
      'manage_deleted_items': 'මැකූ දත්ත කළමනාකරණය (දින 5ක් තබාගනී)',
      'download_expense_records': 'PDF හෝ CSV වාර්තා බාගත කරන්න',
      'account': 'ගිණුම',
      'logged_in_as': 'පිවිස ඇති ගිණුම',
      'about': 'විස්තර',
      'app_version': 'අනුවාදය 1.0.0',
      'developed_with_love': 'Flutter සහ Firebase මඟින් නිර්මාණය කර ඇත',
      'language_applied_notice': 'භාෂාව සිංහලට සාර්ථකව මාරු කරන ලදී',

      // Security & Biometric Lock
      'security': 'ආරක්ෂාව',
      'biometric_lock': 'ඇඟිලි සලකුණු / මුහුණු අගුල',
      'biometric_lock_subtitle': 'ඇඟිලි සලකුණ, Face ID හෝ PIN මඟින් යෙදුම ආරක්ෂා කරන්න',
      'biometric_not_supported': 'මෙම දුරකථනයේ ජෛවමිතික ආරක්ෂාව සහාය නොදක්වයි හෝ සකසා නැත.',
      'biometric_auth_reason': 'Expense Tracker වෙත පිවිසීමට තහවුරු කරන්න',
      'biometric_enable_reason': 'ජෛවමිතික අගුල සක්‍රිය කිරීමට ඔබගේ අනන්‍යතාවය තහවුරු කරන්න',
      'biometric_disable_reason': 'ජෛවමිතික අගුල අක්‍රිය කිරීමට ඔබගේ අනන්‍යතාවය තහවුරු කරන්න',
      'biometric_auth_failed': 'තහවුරු කිරීම අසාර්ථක විය. නැවත උත්සාහ කරන්න.',
      'biometric_lock_enabled_msg': 'ජෛවමිතික අගුල සාර්ථකව සක්‍රිය කරන ලදී',
      'biometric_lock_disabled_msg': 'ජෛවමිතික අගුල අක්‍රිය කරන ලදී',
      'unlock_app': 'යෙදුම අගුළු හරින්න',
      'app_locked': 'යෙදුම අගුළු දමා ඇත',
      'touch_sensor_to_unlock': 'අගුළු හැරීමට ඇඟිලි සලකුණ, Face ID හෝ PIN භාවිතා කරන්න.',
      'unlock_now': 'දැන් අගුළු හරින්න',
      'switch_account': 'වෙනත් ගිණුමකට මාරු වන්න / ඉවත් වන්න',

      // Notifications & Reminders
      'notifications': 'දැනුම්දීම් සහ අනතුරු ඇඟවීම්',
      'notifications_subtitle': 'දෛනික මතක් කිරීම් සහ අයවැය අනතුරු ඇඟවීම්',
      'enable_notifications': 'දැනුම්දීම් සක්‍රිය කරන්න',
      'enable_notifications_desc': 'වියදම් මතක් කිරීම් සහ සජීවී අනතුරු ඇඟවීම් ලබා ගන්න',
      'daily_reminder': 'දෛනික වියදම් මතක් කිරීම',
      'daily_reminder_desc': 'අද දවසේ වියදම් සටහන් කිරීමට දිනපතා මතක් කරන්න',
      'reminder_time': 'මතක් කිරීමේ වේලාව',
      'set_reminder_time': 'දෛනික මතක් කිරීමේ වේලාව සකසන්න',
      'change_time': 'වේලාව වෙනස් කරන්න',
      'budget_alerts': 'අයවැය සීමා අනතුරු ඇඟවීම්',
      'budget_alerts_desc': 'වියදම් 80% හෝ 100% සීමාව ඉක්මවූ විට දැනුම් දෙන්න',
      'test_notification': 'පරීක්ෂණ දැනුම්දීමක් එවන්න',
      'test_notification_sent': 'පරීක්ෂණ දැනුම්දීම සාර්ථකව එවන ලදී!',
      'test_notification_title': 'වියදම් සටහන් කිරීමේ පරීක්ෂණ දැනුම්දීම 🔔',
      'test_notification_body': 'දැනුම්දීම් සාර්ථකව ක්‍රියාත්මක වේ!',
      'daily_reminder_title': 'වියදම් මතක් කිරීම 📝',
      'daily_reminder_body': 'අද දවසේ වියදම් සටහන් කිරීමට අමතක නොකරන්න!',
      'budget_warning_80_title': 'අයවැය අනතුරු ඇඟවීම (80% ළඟා විය) ⚠️',
      'budget_exceeded_title': 'අයවැය සීමාව ඉක්මවා ඇත! 🚨',
      'budget_warning_overall_body': 'ඔබ මාසික සමස්ත අයවැය සීමාවෙන් 80% ක් හෝ ඊට වැඩි ප්‍රමාණයක් වියදම් කර ඇත.',
      'budget_exceeded_overall_body': 'ඔබ මාසික සමස්ත අයවැය සීමාව ඉක්මවා ඇත!',
      'budget_warning_category_body': 'කාණ්ඩයේ වෙන් කළ සීමාවෙන් 80% ක් හෝ ඊට වැඩි ප්‍රමාණයක් වියදම් කර ඇත.',
      'budget_exceeded_category_body': 'කාණ්ඩයේ වෙන් කළ සීමාව ඉක්මවා ඇත!',
      'recycle_bin_warning_title': 'කසළ බඳුන පිරිසිදු කිරීමේ දැනුම්දීම 🗑️',
      'recycle_bin_warning_body': 'කසළ බඳුනේ ඇති අයිතම දින 5කට පසු ස්ථිරවම මැකී යනු ඇත.',
      'notification_permission_denied': 'දැනුම්දීම් අවසරය ප්‍රතික්ෂේප විය. දුරකථන සැකසීම් වලින් අවසර ලබා දෙන්න.',
      'test_timer_10s': 'මතක් කිරීම පරීක්ෂා කරන්න (තත්පර 10කින්)',
      'test_timer_started': 'තත්පර 10කින් මතක් කිරීමක් සැලසුම් කර ඇත! පරීක්ෂා කිරීමට යෙදුම අවම කරන්න හෝ තිරය අගුළු දමන්න.',
      
      // Categories
      'cat_food': 'ආහාර සහ පාන',
      'cat_transport': 'ප්‍රවාහනය',
      'cat_shopping': 'සාප්පු සවාරි',
      'cat_entertainment': 'විනෝදාස්වාදය',
      'cat_bills': 'බිල්පත් සහ උපයෝගිතා',
      'cat_health': 'සෞඛ්‍ය සහ වෛද්‍ය',
      'cat_education': 'අධ්‍යාපනය',
      'cat_other': 'වෙනත්',

      // Navigation
      'home': 'මුල් පිටුව',
      'analytics': 'විශ්ලේෂණ',
    },
  };

  /// Returns translated string by key and language code ('en' or 'si')
  static String getText(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  /// Translates standard categories to Sinhala if active
  static String getCategoryName(String category, String languageCode) {
    if (languageCode != 'si') return category;
    switch (category) {
      case 'Food & Dining':
        return 'ආහාර සහ පාන';
      case 'Transport':
        return 'ප්‍රවාහනය';
      case 'Shopping':
        return 'සාප්පු සවාරි';
      case 'Entertainment':
        return 'විනෝදාස්වාදය';
      case 'Bills & Utilities':
        return 'බිල්පත් සහ උපයෝගිතා';
      case 'Health & Medical':
        return 'සෞඛ්‍ය සහ වෛද්‍ය';
      case 'Education':
        return 'අධ්‍යාපනය';
      case 'Other':
        return 'වෙනත්';
      default:
        return category;
    }
  }
}
