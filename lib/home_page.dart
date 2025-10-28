import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestoredeneme/lodges_page2.dart';
import 'package:firestoredeneme/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'admin_page.dart'; // AdminPage'e yönlendirme için
import 'text_styles.dart';
import 'users_page2.dart';
import 'change_password_page.dart';
import 'birthday_service.dart';
import 'settings_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> texts = [];
  int _tapCount = 0;
  bool _isPasswordDialogOpen = false;
  String _enteredPassword = '';
  String selectedDate = '';
  String firstText = '';
  String secondText = '';
  String thirdText = '';
  String fourthText = '';

  List<String> availableDates = [];
  int selectedDateIndex = 0; // Seçilen tarihin indeksini tutacağız
  // Settings butonuna tıklanıp tıklanmadığını kontrol etmek için değişken

  //final bool _isPasswordScreenVisible = true;  // Başlangıçta şifre ekranı görünsün

  // Veritabanından alınacak değer
  // late final bool _acilIsTercih = true;  // Varsayılan olarak true, Firestore'dan alınacak

  final BirthdayService _birthdayService = BirthdayService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    availableDates = getDatesForCurrentAndNextYear();
    if (availableDates.isNotEmpty) {
      selectedDate = getNextWednesday();
      selectedDateIndex = availableDates.indexOf(selectedDate);
      _loadTextsForSelectedDate(selectedDate);
    }
    _birthdayService.initialize(); // Bildirim servisini başlat
    _settingsService.initializeNotifications(); // Sistem mesajları için bildirimleri başlat
    // _checkUpcomingBirthdays(); // Bunu kaldırdık, sadece ikon tıklanınca çalışacak
    _sendSystemMessages();
  }

  void _sendSystemMessages() async {
    List<Map<String, dynamic>> birthdays = await _birthdayService.getUpcomingBirthdays();
    for (var birthday in birthdays) {
      _settingsService.showSystemMessage(
        'Yaklaşan Doğum Günü',
        '${birthday['name']} ${birthday['surname']} - ${DateFormat('dd.MM.yyyy').format(birthday['nextBirthday'])}',
      );
    }
  }

  void _checkUpcomingBirthdays() async {
    List<Map<String, dynamic>> birthdays = await _birthdayService.getUpcomingBirthdays();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        if (birthdays.isNotEmpty) {
          return AlertDialog(
            title: Text('Yaklaşan Doğum Günleri', style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: birthdays.map((birthday) {
                return Text('${birthday['name']} ${birthday['surname']} - ${DateFormat('dd.MM.yyyy').format(birthday['nextBirthday'])}');
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Kapat'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cake, color: Colors.red),
                SizedBox(width: 8),
                Text('Doğum Günü Bilgisi'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yaklaşan doğum günü bulunmamaktadır.'),
               // SizedBox(height: 12),
               // Text('Yine de kutlamak isterseniz, herkese mutlu günler! 🎉', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Tamam'),
              ),
            ],
          );
        }
      },
    );
  }

  // Bugünden sonraki ilk Çarşamba tarihini bulan fonksiyon
  String getNextWednesday() {
    DateTime today = DateTime.now();
    DateTime nextWednesday = today;

    // Eğer bugün Çarşamba değilse, bir sonraki Çarşambaya git
    while (nextWednesday.weekday != DateTime.wednesday || nextWednesday.isBefore(today)) {
      nextWednesday = nextWednesday.add(const Duration(days: 1));
    }

    return formatDate(nextWednesday); // Bulduğumuz tarihi formatlayıp döndürüyoruz
  }

  // Firebase'den metinleri yükleyen fonksiyon
  void _loadTextsForSelectedDate(String date) async {
    var collection = FirebaseFirestore.instance.collection('texts');
    var querySnapshot = await collection.where('date', isEqualTo: date).get();

    if (querySnapshot.docs.isNotEmpty) {
      var data = querySnapshot.docs.first.data();
      setState(() {
        firstText = data['first_text'] ?? '';
        secondText = data['second_text'] ?? '';
        thirdText = data['third_text'] ?? '';
        fourthText = data['fourth_text'] ?? '';
      });
    } else {
      setState(() {
        firstText = '';
        secondText = '';
        thirdText = '';
        fourthText = '';
      });
    }
  }

  // Mevcut yıl ve bir sonraki yıl tarihlerini hesaplayan fonksiyon
  List<String> getDatesForCurrentAndNextYear() {
    int currentYear = DateTime.now().year;  // Şu anki yılı alıyoruz
    List<String> dates = [];

    // Mevcut yıl ve bir sonraki yıl arasındaki çarşamba tarihlerini alıyoruz
    for (int year = currentYear; year <= currentYear + 1; year++) {
      List<String> yearDates = getDatesForYear(year);
      dates.addAll(yearDates);
    }

    return dates;
  }

  // Verilen bir yıl için 2., 4. ve 5. çarşambaları hesaplayan fonksiyon
  List<String> getDatesForYear(int year) {
    List<String> dates = [];
    for (int month = 1; month <= 12; month++) {
      int wednesdayCount = 0;
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      DateTime currentDay = firstDayOfMonth;

      while (currentDay.month == month) {
        if (currentDay.weekday == DateTime.wednesday) {
          wednesdayCount++;
          if (wednesdayCount == 2 || wednesdayCount == 4 || wednesdayCount == 5) {
            dates.add(formatDate(currentDay)); // İlgili çarşamba tarihini ekle
          }
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }
    }
    return dates;
  }

  // Tarihi "14 Ocak 2025" gibi formatlamak için yardımcı fonksiyon
  String formatDate(DateTime date) {
    List<String> months = [
      "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
      "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade600,
        title: GestureDetector(
          onTap: _onAppBarTapped, // AppBar tıklama işlemi
          child: Text(
            '${DateTime.now().year} - ${DateTime.now().year + 1} ',
            style: MainHeader2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.orangeAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersPage2()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_sharp, color: Colors.orangeAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LodgesPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.orangeAccent),
            onPressed: () {
              // Şifre değiştirme sayfasına yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
              );
            }, // Settings butonuna tıklanınca dialog açılacak
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.orangeAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.cake, color: Colors.red,),
            onPressed: _checkUpcomingBirthdays,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seçilen tarihe ait metinler
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 12),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 10),
                  Text(selectedDate, style: MainHeader3),
                  //  SizedBox(height: 10),
                  Text('I. D:. Çalışması:', style: MainHeader),
                  // Bu kısımdaki metni kaydırılabilir yapmak için SingleChildScrollView ekliyoruz
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        firstText,
                        style: MainBody,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  //  SizedBox(height: 8),
                  Text('II. D:. Çalışması:', style: MainHeader),
                  Flexible(
                    child: SizedBox(height: 50,
                      child: SingleChildScrollView(
                        child: Text(
                          secondText,
                          style: MainBody,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  //  SizedBox(height: 8),
                  Text('III. D:. Çalışması:', style: MainHeader),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        thirdText,
                        style: MainBody,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  //   SizedBox(height: 8),
                  Text('Kardeş Sofrası', style: MainHeader),
                  SizedBox(height: 50,
                    child: SingleChildScrollView(
                      child: Text(
                        fourthText,
                        style: MainBody,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cupertino Widget (Tarihler)
          SizedBox(
            height: 120,
            child: CupertinoPicker(
              diameterRatio: .8,
              useMagnifier: true,
              magnification: 1.12,
              itemExtent: 40, // Her öğe için yüksekliği belirliyoruz
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedDate = availableDates[index];
                  selectedDateIndex = index;
                });
                _loadTextsForSelectedDate(selectedDate);
              },
              scrollController:
              FixedExtentScrollController(initialItem: selectedDateIndex),
              children: availableDates.map((date) {
                return Text(date);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  // AppBar'a tıklama işlemi
  void _onAppBarTapped() {
    setState(() {
      _tapCount++;
    });
    if (_tapCount == 3 && !_isPasswordDialogOpen) {
      _showPasswordDialog();
    }
  }

  // Şifre penceresini göstermek için
  void _showPasswordDialog() {
    if (!_isPasswordDialogOpen) {
      setState(() {
        _isPasswordDialogOpen = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false, // Kullanıcı dışarıya tıklayarak dialog'ı kapatamasın
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Yönetici Girişi", style: MainBody,),
            content: SingleChildScrollView( // İçeriği kaydırılabilir yapmak için
              child: Column(
                mainAxisSize: MainAxisSize.min, // Column boyutunu minimumda tut
                children: [
                  TextField(
                    obscureText: true, // Şifreyi gizleyin
                    decoration: const InputDecoration(labelText: "Şifre"),
                    onChanged: (value) {
                      setState(() {
                        _enteredPassword = value; // Girilen şifreyi al
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("İptal"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog'ı kapat
                  setState(() {
                    _tapCount = 0;
                    _isPasswordDialogOpen = false;
                    // Dialog açılmadı olarak set et
                  });
                },
              ),
              TextButton(
                child: const Text("Giriş"),
                onPressed: () {
                  if (_enteredPassword == 'Ucgul1964') {
                    Navigator.of(context).pop(); // Şifre doğruysa dialog'ı kapat
                    setState(() {
                      _tapCount = 0; // Şifre doğruysa işlem tamamlandı
                      _isPasswordDialogOpen = false; // Dialog kapalı olarak işaretle
                    });

                    // Şifre doğruysa AdminPage'e yönlendir
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminPage()), // AdminPage'e yönlendirme
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Yanlış şifre"))
                    );
                  }
                },
              ),
            ],
          );
        },
      ).then((_) {
        setState(() {
          _isPasswordDialogOpen = false; // Dialog kapandıktan sonra state'i güncelle
        });
      });
    }
  }


}



