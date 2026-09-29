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
