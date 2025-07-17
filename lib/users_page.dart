
//mport 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'birthday_service.dart';
import 'package:intl/intl.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [];

  // Yeni kullanıcı formu için TextEditingController'lar
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculNoController = TextEditingController();
  final TextEditingController _sicilNoController = TextEditingController();
  final TextEditingController _tekrisController = TextEditingController();
  final TextEditingController _gecisController = TextEditingController();
  final TextEditingController _yukselisController = TextEditingController();
  final TextEditingController _dogumController = TextEditingController();
  final TextEditingController _meslekController = TextEditingController();
  final TextEditingController _kangrubuController = TextEditingController();
  final TextEditingController _rehberController = TextEditingController();
  final TextEditingController _esisimController = TextEditingController();
  final TextEditingController _estelController = TextEditingController();
  final TextEditingController _esmailController = TextEditingController();
  final TextEditingController _esmeslekController = TextEditingController();
  final TextEditingController _esdogumController = TextEditingController();
  final TextEditingController _eskangrubuController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  String selectedUserId = '';  // Seçilen kullanıcının ID'si (güncelleme için)

  final BirthdayService _birthdayService = BirthdayService();
  List<Map<String, dynamic>> upcomingBirthdays = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();  // Firebase'den kullanıcı verilerini alıyoruz
    _initializeBirthdayService();
  }

  void _initializeBirthdayService() async {
    await _birthdayService.initialize();
    // Her gün kontrol et
    Future.delayed(Duration(seconds: 1), () {
      _birthdayService.checkAndSendBirthdayNotifications();
    });
  }

  void _showBirthdayCard(BuildContext context) async {
    upcomingBirthdays = await _birthdayService.getUpcomingBirthdays();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yaklaşan Doğum Günleri 🎂'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: upcomingBirthdays.length,
              itemBuilder: (context, index) {
                final user = upcomingBirthdays[index];
                final nextBirthday = user['nextBirthday'] as DateTime;
                final today = DateTime.now();
                final difference = nextBirthday.difference(today).inDays;
                
                String timeText = '';
                if (difference == 0) {
                  timeText = 'Bugün';
                } else if (difference == 1) {
                  timeText = 'Yarın';
                } else {
                  timeText = '$difference gün sonra';
                }

                return ListTile(
                  leading: Icon(Icons.cake, color: Colors.pink),
                  title: Text('${user['name']} ${user['surname']}'),
                  subtitle: Text('$timeText (${DateFormat('dd.MM').format(nextBirthday)})'),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Kullanıcıları Firebase'den alıyoruz
  void _loadUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'surname': doc['surname'],
          'phone': doc['phone'],
          'email': doc['email'],
          'matriculNo': doc['matriculNo'],
          'sicilNo': doc['sicilNo'],
          'tekris': doc['tekris'],
          'gecis': doc['gecis'],
          'yukselis': doc['yukselis'],
          'dogum': doc['dogum'],
          'meslek': doc['meslek'],
          'kangrubu': doc['kangrubu'],
          'rehber': doc['rehber'],
          'esisim': doc['esisim'],
          'estel': doc['estel'],
          'esmail': doc['esmail'],
          'esmeslek': doc['esmeslek'],
          'esdogum': doc['esdogum'],
          'eskangrubu': doc['eskangrubu'],
          'password': doc['password'],
          'acilistercih': doc['acilistercih'],

        };
      }).toList();

      // Matrükül No'ya göre sıralama
      users.sort((a, b) {
        int matriculNoA = int.tryParse(a['matriculNo'] ?? '0') ?? 0;
        int matriculNoB = int.tryParse(b['matriculNo'] ?? '0') ?? 0;
        return matriculNoA.compareTo(matriculNoB); // Küçükten büyüğe sıralama
      });
    });
  }


  // Yeni kullanıcıyı Firebase'e kaydetme fonksiyonu
  void _addUser() async {
    bool acilistercih = false;
    String name = _nameController.text.trim();
    String surname = _surnameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String matriculNo = _matriculNoController.text.trim();
    String sicilNo = _sicilNoController.text.trim();
    String tekris = _tekrisController.text.trim();
    String gecis = _gecisController.text.trim();
    String yukselis = _yukselisController.text.trim();
    String dogum = _dogumController.text.trim();
    String meslek = _meslekController.text.trim();
    String kangrubu = _kangrubuController.text.trim();
    String rehber = _rehberController.text.trim();
    String esisim = _esisimController.text.trim();
    String estel = _estelController.text.trim();
    String esmail = _esmailController.text.trim();
    String esmeslek = _esmeslekController.text.trim();
    String esdogum = _esdogumController.text.trim();
    String eskangrubu = _eskangrubuController.text.trim();
    String password = _passwordController.text.trim();


    // Eğer tüm bilgiler girildiyse, Firebase'e ekleyelim
    if (name.isNotEmpty && surname.isNotEmpty ) {
      await FirebaseFirestore.instance.collection('users').add({
        'acilistercih': acilistercih,
        'name': name,
        'surname': surname,
        'phone': phone,
        'email': email,
        'matriculNo': matriculNo,
        'sicilNo': sicilNo,
        'tekris': tekris,
        'gecis': gecis,
        'yukselis': yukselis,
        'dogum': dogum,
        'meslek': meslek,
        'kangrubu': kangrubu,
        'rehber': rehber,
        'esisim': esisim,
        'estel': estel,
        'esmail': esmail,
        'esmeslek': esmeslek,
        'esdogum': esdogum,
        'eskangrubu': eskangrubu,
        'password': password,

      });

      // Veriler başarılı şekilde kaydedildiğinde mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı başarıyla eklendi')));

      // Formu temizle
      _clearForm();

      // Listeyi yeniden yükle
      _loadUsers();
    }
  }

  // Kullanıcıyı görüntüleme fonksiyonu (Detaylar için)
  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Üye Bilgileri'),
          content: SingleChildScrollView(  // Wrap the content in a scrollable view
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'İsim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['name']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Soyisim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['surname']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Telefon: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['phone']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'E-posta: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['email']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Matrikül No: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['matriculNo']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Sicil No: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['sicilNo']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Tekris: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['tekris']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Geçiş: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['gecis']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Yükseliş: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['yukselis']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Doğum Tarihi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['dogum']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Meslek: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['meslek']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Kan Grubu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['kangrubu']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Rehber Üs:.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['rehber']}'),
                ])),
                const SizedBox(height: 30),
                const Text('Eşinin Bilgileri', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 15),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'İsim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esisim']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Telefon: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['estel']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'E-posta: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esmail']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Meslek: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esmeslek']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Doğum Tarihi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esdogum']}'),
                ])),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(text: 'Kan Grubu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['eskangrubu']}'),
                ])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Kapat'),
            ),
          ],
        );

      },
    );
  }

  // Kullanıcıyı silme fonksiyonu
  void _deleteUser(String userId) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Silme Onayı'),
          content: const Text('Bu kullanıcıyı silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // İptal
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Onayla
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı başarıyla silindi')));
      _loadUsers(); // Kullanıcı listesini yeniden yükle
    }
  }

  // Kullanıcıyı güncelleme fonksiyonu
  void _updateUser() async {
    String name = _nameController.text.trim();
    String surname = _surnameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String matriculNo = _matriculNoController.text.trim();
    String sicilNo = _sicilNoController.text.trim();
    String tekris = _tekrisController.text.trim();
    String gecis = _gecisController.text.trim();
    String yukselis = _yukselisController.text.trim();
    String dogum = _dogumController.text.trim();
    String meslek = _meslekController.text.trim();
    String kangrubu = _kangrubuController.text.trim();
    String rehber = _rehberController.text.trim();
    String esisim = _esisimController.text.trim();
    String estel = _estelController.text.trim();
    String esmail = _esmailController.text.trim();
    String esmeslek = _esmeslekController.text.trim();
    String esdogum = _esdogumController.text.trim();
    String eskangrubu = _eskangrubuController.text.trim();
    String password = _passwordController.text.trim();



    if (name.isNotEmpty && surname.isNotEmpty && phone.isNotEmpty && email.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(selectedUserId).update({
        'name': name,
        'surname': surname,
        'phone': phone,
        'email': email,
        'matriculNo': matriculNo,
        'sicilNo': sicilNo,
        'tekris': tekris,
        'gecis': gecis,
        'yukselis': yukselis,
        'dogum': dogum,
        'meslek': meslek,
        'kangrubu': kangrubu,
        'rehber': rehber,
        'esisim': esisim,
        'estel': estel,
        'esmail': esmail,
        'esmeslek': esmeslek,
        'esdogum': esdogum,
        'eskangrubu': eskangrubu,
        'password': password,


      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı başarıyla güncellendi')));

      // Formu temizle
      _clearForm();

      // Listeyi yeniden yükle
      _loadUsers();
    }
  }

  // Formu temizleme fonksiyonu
  void _clearForm() {
    _nameController.clear();
    _surnameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _matriculNoController.clear();
    _sicilNoController.clear();
    _tekrisController.clear();
    _gecisController.clear();
    _yukselisController.clear();
    _dogumController.clear();
    _meslekController.clear();
    _kangrubuController.clear();
    _rehberController.clear();
    _esisimController.clear();
    _estelController.clear();
    _esmailController.clear();
    _esmeslekController.clear();
    _esdogumController.clear();
    _eskangrubuController.clear();
    _passwordController.clear();

  }

  // Ayarlar ikonu ile güncelleme popup'ı
  void _showUpdateUserDialog(String userId) async {
    // Seçilen kullanıcının ID'sini kaydet
    selectedUserId = userId;

    // Firebase'den kullanıcının verilerini alalım
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Verileri controller'lara yükleyelim
    _nameController.text = doc['name'];
    _surnameController.text = doc['surname'];
    _phoneController.text = doc['phone'];
    _emailController.text = doc['email'];
    _matriculNoController.text = doc['matriculNo'] ?? '';
    _sicilNoController.text = doc['sicilNo'] ?? '';
    _tekrisController.text = doc['tekris'] ?? '';
    _gecisController.text = doc['gecis'] ?? '';
    _yukselisController.text = doc['yukselis'] ?? '';
    _dogumController.text = doc['dogum'] ?? '';
    _meslekController.text = doc['meslek'] ?? '';
    _kangrubuController.text = doc['kangrubu'] ?? '';
    _rehberController.text = doc['rehber'] ?? '';
    _esisimController.text = doc['esisim'] ?? '';
    _estelController.text = doc['estel'] ?? '';
    _esmailController.text = doc['esmail'] ?? '';
    _esmeslekController.text = doc['esmeslek'] ?? '';
    _esdogumController.text = doc['esdogum'] ?? '';
    _eskangrubuController.text = doc['eskangrubu'] ?? '';


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kullanıcıyı Güncelle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'İsim'),
                ),
                TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Soyisim'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon No'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Mail Adresi'),
                ),
                TextField(
                  controller: _matriculNoController,
                  decoration: const InputDecoration(labelText: 'Matrikül No'),
                ),
                TextField(
                  controller: _sicilNoController,
                  decoration: const InputDecoration(labelText: 'Sicil No'),
                ),
                TextField(
                  controller: _tekrisController,
                  decoration: const InputDecoration(labelText: 'Tekris'),
                ),
                TextField(
                  controller: _gecisController,
                  decoration: const InputDecoration(labelText: 'Geçiş'),
                ),
                TextField(
                  controller: _yukselisController,
                  decoration: const InputDecoration(labelText: 'Yükseliş'),
                ),
                TextField(
                  controller: _dogumController,
                  decoration: const InputDecoration(labelText: 'Doğum Tarihi'),
                ),
                TextField(
                  controller: _meslekController,
                  decoration: const InputDecoration(labelText: 'Mesleği'),

                ),
                TextField(
                  controller: _kangrubuController,
                  decoration: const InputDecoration(labelText: 'Kan Grubu'),
                ),
                TextField(
                  controller: _rehberController,
                  decoration: const InputDecoration(labelText: 'Rehber Üstadı'),
                ),
                TextField(
                  controller: _esisimController,
                  decoration: const InputDecoration(labelText: 'Eş İsim'),
                ),
                TextField(
                  controller: _estelController,
                  decoration: const InputDecoration(labelText: 'Eş Telefon'),
                ),
                TextField(
                  controller: _esmailController,
                  decoration: const InputDecoration(labelText: 'Eş E-posta'),
                ),
                TextField(
                  controller: _esmeslekController,
                  decoration: const InputDecoration(labelText: 'Eş Meslek'),
                ),
                TextField(
                  controller: _esdogumController,
                  decoration: const InputDecoration(labelText: 'Eş Doğum Tarihi'),
                ),
                TextField(
                  controller: _eskangrubuController,
                  decoration: const InputDecoration(labelText: 'Eş Kan Grubu'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // İptal et
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUser(); // Güncelleme işlemini yap
                Navigator.of(context).pop(); // Kapat
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: const Text('Üye Listesi'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.cake, color: Colors.pink),
                if (upcomingBirthdays.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${upcomingBirthdays.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showBirthdayCard(context),
            tooltip: 'Yaklaşan Doğum Günleri',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          var user = users[index];
          return ListTile(
            title: Text('${user['name']} ${user['surname']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red,),
                  onPressed: () => _deleteUser(user['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _viewUserDetails(user),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.green,),
                  onPressed: () => _showUpdateUserDialog(user['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          backgroundColor: Colors.grey.shade300,
          onPressed: _showAddUserDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Yeni kullanıcı ekleme popup'ı
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Kullanıcı Ekle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'İsim'),
                ),
                TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Soyisim'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon No'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Mail Adresi'),
                ),
                TextField(
                  controller: _matriculNoController,
                  decoration: const InputDecoration(labelText: 'Matrikül No'),
                ),
                TextField(
                  controller: _sicilNoController,
                  decoration: const InputDecoration(labelText: 'Sicil No'),
                ),
                TextField(
                  controller: _tekrisController,
                  decoration: const InputDecoration(labelText: 'Tekris'),
                ),
                TextField(
                  controller: _gecisController,
                  decoration: const InputDecoration(labelText: 'Geçiş'),
                ),
                TextField(
                  controller: _yukselisController,
                  decoration: const InputDecoration(labelText: 'Yükseliş'),
                ),
                TextField(
                  controller: _dogumController,
                  decoration: const InputDecoration(labelText: 'Doğum Tarihi'),
                ),
                TextField(
                  controller: _meslekController,
                  decoration: const InputDecoration(labelText: 'Mesleği'),
                ),
                TextField(
                  controller: _kangrubuController,
                  decoration: const InputDecoration(labelText: 'Kan Grubu'),
                ),
                TextField(
                  controller: _rehberController,
                  decoration: const InputDecoration(labelText: 'Rehber Üstadı'),
                ),
                TextField(
                  controller: _esisimController,
                  decoration: const InputDecoration(labelText: 'Eş İsim'),
                ),
                TextField(
                  controller: _estelController,
                  decoration: const InputDecoration(labelText: 'Eş Telefon'),
                ),
                TextField(
                  controller: _esmailController,
                  decoration: const InputDecoration(labelText: 'Eş E-posta'),
                ),
                TextField(
                  controller: _esmeslekController,
                  decoration: const InputDecoration(labelText: 'Eş Meslek'),
                ),
                TextField(
                  controller: _esdogumController,
                  decoration: const InputDecoration(labelText: 'Eş Doğum Tarihi'),
                ),
                TextField(
                  controller: _eskangrubuController,
                  decoration: const InputDecoration(labelText: 'Eş Kan Grubu'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // İptal et
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                _addUser(); // Kullanıcıyı ekle
                Navigator.of(context).pop(); // Kapat
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
