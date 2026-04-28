// lib/core/constants/app_strings.dart
class AppStrings {
  AppStrings._();

  static const String appName        = 'Daily Programming';
  static const String appTagline     = 'Alışkanlıklarını takip et';

  // Auth
  static const String login          = 'Giriş Yap';
  static const String register       = 'Kayıt Ol';
  static const String logout         = 'Çıkış Yap';
  static const String email          = 'Email';
  static const String username       = 'Kullanıcı Adı';
  static const String password       = 'Şifre';
  static const String confirmPw      = 'Şifre Tekrar';
  static const String createAccount  = 'Hesap Oluştur';

  // Validasyon
  static const String emailEmpty     = 'Email boş olamaz';
  static const String emailInvalid   = 'Geçerli bir email girin';
  static const String usernameEmpty  = 'Kullanıcı adı boş olamaz';
  static const String usernameShort  = 'En az 3 karakter olmalı';
  static const String passwordShort  = 'En az 6 karakter olmalı';
  static const String passwordMismatch = 'Şifreler eşleşmiyor';

  // Home
  static const String todayHabits   = 'Bugünün Alışkanlıkları';
  static const String addHabit      = 'Alışkanlık Ekle';
  static const String noHabits      = 'Henüz alışkanlık yok';
  static const String noHabitsSub   = 'İlk alışkanlığını eklemek için + butonuna bas';

  // Stats
  static const String statistics    = 'İstatistikler';
  static const String weeklyProgress = 'Haftalık İlerleme';
  static const String longestStreak  = 'En Uzun Seri';

  // Drawer / Menü
  static const String myHabits      = 'Alışkanlıklarım';
  static const String profile       = 'Profilim';
  static const String notifications = 'Bildirimler';
  static const String about         = 'Hakkımda';
  static const String settings      = 'Ayarlar';

  // Profile
  static const String deleteAccount = 'Hesabı Sil';
  static const String memberSince   = 'Üyelik Tarihi';
  static const String kvkkTitle     = 'KVKK Aydınlatma Metni';
  static const String kvkkText      = '''
Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında, uygulamayı kullanırken toplanan kişisel verileriniz (e-posta adresi, kullanıcı adı, alışkanlık verileri) yalnızca uygulama hizmetlerinin sunulması amacıyla işlenmektedir.

Verileriniz üçüncü taraflarla paylaşılmamaktadır. Bildirim göndermek amacıyla Firebase Cloud Messaging hizmeti kullanılmaktadır.

Hesabınızı istediğiniz zaman silebilir ve tüm verilerinizin kalıcı olarak silinmesini talep edebilirsiniz.

Veri sorumlusu: Daily Programming Uygulama Geliştirici Ekibi
İletişim: destek@dailyprogramming.app
''';

  // SSS (FAQ)
  static const String faqTitle      = 'Sıkça Sorulan Sorular';
  static const String helpTitle     = 'Yardım & Destek';
  static const String helpText      = 'Herhangi bir sorunuz veya geri bildiriminiz için destek@dailyprogramming.app adresine mail atabilirsiniz.';

  // About
  static const String aboutTitle    = 'Hakkında';
  static const String appVersion    = 'Versiyon 1.0.0';
  static const String developer     = 'Geliştirici: Emirhan';
  static const String aboutDesc     = 'Daily Programming, günlük alışkanlıklarınızı takip etmenize ve kişisel gelişiminizi desteklemenize yardımcı olan modern bir uygulama.';

  // Notifications
  static const String notifTitle    = 'Bildirim Ayarları';
  static const String setReminder   = 'Hatırlatıcı Kur';
  static const String reminderSet   = 'Hatırlatıcı ayarlandı';
  static const String noReminder    = 'Hatırlatıcı yok';

  // Genel
  static const String save          = 'Kaydet';
  static const String cancel        = 'İptal';
  static const String errorOccurred = 'Bir hata oluştu';
  static const String confirm       = 'Onayla';
  static const String areYouSure    = 'Emin misin?';
}
