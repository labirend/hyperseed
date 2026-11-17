import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('tr'), Locale('en')];

  late final Map<String, String> _strings = _loadStrings();

  Map<String, String> _loadStrings() {
    switch (locale.languageCode) {
      case 'en':
        return _en;
      case 'tr':
      default:
        return _tr;
    }
  }

  String translate(String key) => _strings[key] ?? key;

  String get appTitle => translate('appTitle');
  String get welcomeTitle => translate('welcomeTitle');
  String get welcomeSubtitle => translate('welcomeSubtitle');
  String get getStarted => translate('getStarted');
  String get energyTitle => translate('energyTitle');
  String get energyLow => translate('energyLow');
  String get energyLowDesc => translate('energyLowDesc');
  String get energyHyper => translate('energyHyper');
  String get energyHyperDesc => translate('energyHyperDesc');
  String get energyChaos => translate('energyChaos');
  String get energyChaosDesc => translate('energyChaosDesc');
  String get tasks => translate('tasks');
  String get addTask => translate('addTask');
  String get editTask => translate('editTask');
  String get taskTitle => translate('taskTitle');
  String get taskDuration => translate('taskDuration');
  String get taskEnergy => translate('taskEnergy');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get complete => translate('complete');
  String get thankYou => translate('thankYou');
  String get thankYouMessage => translate('thankYouMessage');
  String get dailyLimit => translate('dailyLimit');
  String get dailyLimitDesc => translate('dailyLimitDesc');
  String get settings => translate('settings');
  String get language => translate('language');
  String get turkish => translate('turkish');
  String get english => translate('english');
  String get noTasks => translate('noTasks');
  String get noCompletedTasks => translate('noCompletedTasks');
  String get randomTask => translate('randomTask');
  String get minutes => translate('minutes');
  String get lowEnergy => translate('lowEnergy');
  String get mediumEnergy => translate('mediumEnergy');
  String get highEnergy => translate('highEnergy');
  String get deleteConfirmation => translate('deleteConfirmation');
  String get yes => translate('yes');
  String get no => translate('no');
  String get tasksCompleted => translate('tasksCompleted');
  String get backToTasks => translate('backToTasks');
  String get changeEnergy => translate('changeEnergy');
  String get dailyLimitReached => translate('dailyLimitReached');
  String get taskAdded => translate('taskAdded');
  String get taskDeleted => translate('taskDeleted');
  String get undo => translate('undo');
  String get decisionWheel => translate('decisionWheel');
  String get cantDecide => translate('cantDecide');
  String get spinWheel => translate('spinWheel');
  String get selectedTask => translate('selectedTask');
  String get tasksOf => translate('tasksOf');
  String get todayTasks => translate('todayTasks');
  String get noCompletedToday => translate('noCompletedToday');
  String get dailyTasks => translate('dailyTasks');

  String get focusTimer => translate('focusTimer');
  String get auraTimer => translate('auraTimer');
  String get startFocus => translate('startFocus');
  String get pauseFocus => translate('pauseFocus');
  String get resumeFocus => translate('resumeFocus');
  String get focusComplete => translate('focusComplete');
  String get setDuration => translate('setDuration');
  String get minutesRemaining => translate('minutesRemaining');
  String get hoursMinutes => translate('hoursMinutes');
  String get auraDescription => translate('auraDescription');

  String get focusBuddy => translate('focusBuddy');
  String get buddyWorking => translate('buddyWorking');
  String get buddySleeping => translate('buddySleeping');
  String get buddyCheering => translate('buddyCheering');
  String get buddyIdle => translate('buddyIdle');
  String get wakeBuddy => translate('wakeBuddy');

  String get waitMode => translate('waitMode');
  String get waitModeTitle => translate('waitModeTitle');
  String get setAppointmentTime => translate('setAppointmentTime');
  String get appointmentTime => translate('appointmentTime');
  String get timeUntilAppointment => translate('timeUntilAppointment');
  String get fillingTasks => translate('fillingTasks');
  String get noFillingTasks => translate('noFillingTasks');
  String get startWaitMode => translate('startWaitMode');
  String get stopWaitMode => translate('stopWaitMode');
  String get waitModeDescription => translate('waitModeDescription');

  String get focus => translate('focus');
  String get optionLabel => translate('optionLabel');
  String get addOption => translate('addOption');
  String get optionPlaceholder => translate('optionPlaceholder');
  String get minOptions => translate('minOptions');
  String get maxOptions => translate('maxOptions');
  String get resultLabel => translate('resultLabel');
  String get deleteAllData => translate('deleteAllData');
  String get deleteAllDataConfirm => translate('deleteAllDataConfirm');
  String get deleteAllDataWarning => translate('deleteAllDataWarning');
  String get dangerZone => translate('dangerZone');
  String get interests => translate('interests');
  String get interestsDesc => translate('interestsDesc');
  String get selectInterests => translate('selectInterests');
  String get interestsHint => translate('interestsHint');
  String get thankYouButtonMain => translate('thankYouButtonMain');
  String get thankYouMessageNew => translate('thankYouMessageNew');
  String get tasksCount => translate('tasksCount');
  String get interestsSubDesc => translate('interestsSubDesc');
  String get interestsFinal => translate('interestsFinal');
  String get selectAll => translate('selectAll');
  String get deselectAll => translate('deselectAll');
  String get stepMainCategories => translate('stepMainCategories');
  String get stepSubCategories => translate('stepSubCategories');
  String get stepInterests => translate('stepInterests');

  static const Map<String, String> _tr = {
    'appTitle': 'HyperSeed',
    'welcomeTitle': "HyperSeed'e Ho\u011feldin",
    'welcomeSubtitle': 'Bug\u00fcn kendin i\u00e7in ne yapabilirsin?',
    'getStarted': 'Ba\u015fla',
    'energyTitle': 'Bug\u00fcn Enerjin Nas\u0131l?',
    'energyLow': 'D\u00fc\u015f\u00fck',
    'energyLowDesc': 'Mikro g\u00f6revler, dinlenme',
    'energyHyper': 'Hiperfocus',
    'energyHyperDesc': 'Derin \u00e7al\u0131\u015fma, odaklanma',
    'energyChaos': 'Kaos',
    'energyChaosDesc': 'Rastgele, h\u0131zl\u0131 kazan\u0131mlar',
    'tasks': 'G\u00f6revlerim',
    'addTask': 'Yeni G\u00f6rev',
    'editTask': 'G\u00f6revi D\u00fczenle',
    'taskTitle': 'G\u00f6rev Ba\u015fl\u0131\u011f\u0131',
    'taskDuration': 'Tahmini S\u00fcre (dk)',
    'taskEnergy': 'Enerji Seviyesi',
    'save': 'Kaydet',
    'cancel': '\u0130ptal',
    'delete': 'Sil',
    'complete': 'Tamamland\u0131',
    'thankYou': 'TE\u015eEKK\u00dcR ET',
    'thankYouMessage':
        'Bug\u00fcn kendin i\u00e7in yeterliydin.\nHayat sana te\u015fekk\u00fcr eder.',
    'dailyLimit': 'G\u00fcnl\u00fck G\u00f6rev Limiti',
    'dailyLimitDesc': '5 g\u00f6rev ile s\u0131n\u0131rla',
    'settings': 'Ayarlar',
    'language': 'Dil',
    'turkish': 'T\u00fcrk\u00e7e',
    'english': 'English',
    'noTasks': 'Hen\u00fcz g\u00f6rev eklenmemi\u015f',
    'noCompletedTasks': 'Bug\u00fcn hen\u00fcz g\u00f6rev tamamlamad\u0131n',
    'randomTask': 'Rastgele G\u00f6rev Ekle',
    'minutes': 'dk',
    'lowEnergy': 'D\u00fc\u015f\u00fck',
    'mediumEnergy': 'Orta',
    'highEnergy': 'Y\u00fcksek',
    'deleteConfirmation': 'Bu g\u00f6revi silmek istedi\u011fine emin misin?',
    'yes': 'Evet',
    'no': 'Hay\u0131r',
    'tasksCompleted': 'g\u00f6rev tamamland\u0131',
    'backToTasks': 'G\u00f6revlere D\u00f6n',
    'changeEnergy': 'Enerji seviyen de\u011fi\u015ftir',
    'dailyLimitReached': 'G\u00fcnl\u00fck limite ula\u015f\u0131ld\u0131',
    'taskAdded': 'G\u00f6rev eklendi',
    'taskDeleted': 'G\u00f6rev silindi',
    'undo': 'Geri Al',
    'decisionWheel': 'Karar \u00c7ark\u0131',
    'cantDecide': 'Karar Veremedin mi?',
    'spinWheel': '\u00c7ark\u0131 \u00c7evir',
    'selectedTask': 'Se\u00e7ilen G\u00f6rev',
    'tasksOf': 'g\u00f6rev',
    'todayTasks': 'Bug\u00fcnl\u00fck G\u00f6revler',
    'noCompletedToday': 'Bug\u00fcn hi\u00e7 g\u00f6rev tamamlamad\u0131n',
    'dailyTasks': 'G\u00fcnl\u00fck G\u00f6revler',
    'focusTimer': 'Odaklanma Zamanlay\u0131c\u0131s\u0131',
    'auraTimer': 'Aura Zamanlay\u0131c\u0131',
    'startFocus': 'Ba\u015fla',
    'pauseFocus': 'Duraklat',
    'resumeFocus': 'Devam Et',
    'focusComplete': 'Odaklanma Tamamland\u0131!',
    'setDuration': 'S\u00fcre Se\u00e7',
    'minutesRemaining': 'dakika kald\u0131',
    'hoursMinutes': 'saat dakika',
    'auraDescription':
        'Zaman ge\u00e7tik\u00e7e renkten renge ge\u00e7en tam ekran gradyan. Anksiyeteyi azalt\u0131r.',
    'focusBuddy': 'Odak Asistanı',
    'buddyWorking': 'Çalışıyor...',
    'buddySleeping': 'Uyuyor...',
    'buddyCheering': 'Senin için çalışıyor!',
    'buddyIdle': 'Hazır',
    'wakeBuddy': 'Asistanı Uyandır',
    'waitMode': 'Bekleme Modu',
    'waitModeTitle': 'Bekleme Modu Kurtar\u0131c\u0131s\u0131',
    'setAppointmentTime': 'Randevu Saatini Gir',
    'appointmentTime': 'Randevu Saati',
    'timeUntilAppointment': 'Randevuya kalan s\u00fcre',
    'fillingTasks': 'Bo\u015f Zaman G\u00f6revleri',
    'noFillingTasks': '\u015eu an i\u00e7in bo\u015f zaman g\u00f6revi yok',
    'startWaitMode': 'Bekleme Modunu Ba\u015flat',
    'stopWaitMode': 'Bekleme Modunu Durdur',
    'waitModeDescription':
        'Randevu saatinde kadar boş zamanını dolduran hızlı görevler.',
    'focus': 'Odak',
    'optionLabel': 'Seçenek',
    'addOption': 'Yeni Seçenek',
    'optionPlaceholder': 'Bir seçenek yazınız',
    'minOptions': 'En az 2 seçenek gerekli',
    'maxOptions': 'En fazla 5 seçenek',
    'resultLabel': 'Sonuç',
    'deleteAllData': 'Tüm Verileri Sil',
    'deleteAllDataConfirm':
        'Bu işlem geri alınamaz. Tüm görevleriniz ve ayarlarınız silinecek.',
    'deleteAllDataWarning': 'Emin misiniz?',
    'dangerZone': 'Tehlikeli Bölge',
    'interests': 'İlgi Alanları',
    'interestsDesc':
        'Rastgele görev önerileri bu alanlara göre kişiselleştirilir',
    'selectInterests': 'İlgi Alanlarını Seç',
    'interestsHint': 'En az bir kategori seçin',
    'interestsSubDesc': 'Her kategoride ilgilendiğiniz alanları seçin',
    'interestsFinal': 'Sevdiğiniz seçenekleri işaretleyin',
    'selectAll': 'Tümünü Seç',
    'deselectAll': 'Tümünü Kaldır',
    'stepMainCategories': 'Ana Kategoriler',
    'stepSubCategories': 'Alt Kategoriler',
    'stepInterests': 'İlgi Alanları',
    'thankYouButtonMain': 'KENDİNE TEŞEKKÜR ET',
    'thankYouMessageNew':
        'Bugün kendine zaman ayırdın.\nBu bile başlı başına bir zafer.',
    'tasksCount': 'görev tamamlandı',
  };

  static const Map<String, String> _en = {
    'appTitle': 'HyperSeed',
    'welcomeTitle': 'Welcome to HyperSeed',
    'welcomeSubtitle': 'What can you do for yourself today?',
    'getStarted': 'Get Started',
    'energyTitle': "How's Your Energy Today?",
    'energyLow': 'Low',
    'energyLowDesc': 'Micro tasks, rest',
    'energyHyper': 'Hyperfocus',
    'energyHyperDesc': 'Deep work, focus',
    'energyChaos': 'Chaos',
    'energyChaosDesc': 'Random, quick wins',
    'tasks': 'My Tasks',
    'addTask': 'New Task',
    'editTask': 'Edit Task',
    'taskTitle': 'Task Title',
    'taskDuration': 'Estimated Duration (min)',
    'taskEnergy': 'Energy Level',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'complete': 'Completed',
    'thankYou': 'THANK YOU',
    'thankYouMessage': 'You were enough for yourself today.\nLife thanks you.',
    'dailyLimit': 'Daily Task Limit',
    'dailyLimitDesc': 'Limit to 5 tasks',
    'settings': 'Settings',
    'language': 'Language',
    'turkish': 'T\u00fcrk\u00e7e',
    'english': 'English',
    'noTasks': 'No tasks added yet',
    'noCompletedTasks': 'No tasks completed today',
    'randomTask': 'Add Random Task',
    'minutes': 'min',
    'lowEnergy': 'Low',
    'mediumEnergy': 'Medium',
    'highEnergy': 'High',
    'deleteConfirmation': 'Are you sure you want to delete this task?',
    'yes': 'Yes',
    'no': 'No',
    'tasksCompleted': 'tasks completed',
    'backToTasks': 'Back to Tasks',
    'changeEnergy': 'Change energy level',
    'dailyLimitReached': 'Daily limit reached',
    'taskAdded': 'Task added',
    'taskDeleted': 'Task deleted',
    'undo': 'Undo',
    'decisionWheel': 'Decision Wheel',
    'cantDecide': "Can't Decide?",
    'spinWheel': 'Spin the Wheel',
    'selectedTask': 'Selected Task',
    'tasksOf': 'tasks',
    'todayTasks': "Today's Tasks",
    'noCompletedToday': "You haven't completed any tasks today",
    'dailyTasks': 'Daily Tasks',
    'focusTimer': 'Focus Timer',
    'auraTimer': 'Aura Timer',
    'startFocus': 'Start Focus',
    'pauseFocus': 'Pause',
    'resumeFocus': 'Resume',
    'focusComplete': 'Focus Session Complete!',
    'setDuration': 'Set Duration',
    'minutesRemaining': 'minutes remaining',
    'hoursMinutes': 'hours minutes',
    'auraDescription':
        'A full-screen gradient that shifts colors over time. Reduces anxiety.',
    'focusBuddy': 'Focus Buddy',
    'buddyWorking': 'Working...',
    'buddySleeping': 'Sleeping...',
    'buddyCheering': 'Working for you!',
    'buddyIdle': 'Ready',
    'wakeBuddy': 'Wake Buddy',
    'waitMode': 'Wait Mode',
    'waitModeTitle': 'Wait Mode Saver',
    'setAppointmentTime': 'Set Appointment Time',
    'appointmentTime': 'Appointment Time',
    'timeUntilAppointment': 'Time until appointment',
    'fillingTasks': 'Fill Time Tasks',
    'noFillingTasks': 'No fill-time tasks right now',
    'startWaitMode': 'Start Wait Mode',
    'stopWaitMode': 'Stop Wait Mode',
    'waitModeDescription':
        'Quick tasks to fill the gap until your appointment.',
    'focus': 'Focus',
    'optionLabel': 'Option',
    'addOption': 'Add Option',
    'optionPlaceholder': 'Enter an option',
    'minOptions': 'Minimum 2 options required',
    'maxOptions': 'Maximum 5 options',
    'resultLabel': 'Result',
    'deleteAllData': 'Delete All Data',
    'deleteAllDataConfirm':
        'This action cannot be undone. All your tasks and settings will be deleted.',
    'deleteAllDataWarning': 'Are you sure?',
    'dangerZone': 'Danger Zone',
    'interests': 'Interests',
    'interestsDesc': 'Random task suggestions are personalized based on these',
    'selectInterests': 'Select Your Interests',
    'interestsHint': 'Select at least one category',
    'interestsSubDesc': 'Select areas of interest in each category',
    'interestsFinal': 'Mark the options you like',
    'selectAll': 'Select All',
    'deselectAll': 'Deselect All',
    'stepMainCategories': 'Main Categories',
    'stepSubCategories': 'Subcategories',
    'stepInterests': 'Interests',
    'thankYouButtonMain': 'THANK YOURSELF',
    'thankYouMessageNew':
        'You made time for yourself today.\nThat alone is a victory.',
    'tasksCount': 'tasks completed',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
