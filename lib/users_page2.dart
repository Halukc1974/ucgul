import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'birthday_service.dart';

class UsersPage2 extends StatefulWidget {
  const UsersPage2({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage2> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  String searchQuery = '';
  String selectedUserId = ''; // Seçilen kullanıcının ID'si (güncelleme için)
  final TextEditingController _searchController = TextEditingController();
  final BirthdayService _birthdayService = BirthdayService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
        _filterUsers();
      });
    });
    _birthdayService.initialize(); // Bildirim servisini başlat
  }

  void _loadUsers() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').get();
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
        };
      }).toList();

      // Matrükül No'ya göre sıralama
      users.sort((a, b) {
        int matriculNoA = int.tryParse(a['matriculNo'] ?? '0') ?? 0;
        int matriculNoB = int.tryParse(b['matriculNo'] ?? '0') ?? 0;
        return matriculNoA.compareTo(matriculNoB); // Küçükten büyüğe sıralama
      });

      filteredUsers = List.from(users);
      _filterUsers();
    });
  }

  void _filterUsers() {
    if (searchQuery.isEmpty) {
      filteredUsers = List.from(users);
    } else {
      filteredUsers = users.where((user) {
        final query = searchQuery.toLowerCase();
        final fullName =
        '${user['name']} ${user['surname']}'.toLowerCase();
        final matriculNo = user['matriculNo']?.toString().toLowerCase() ?? '';
        return fullName.contains(query) || matriculNo.contains(query);
      }).toList();
    }
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Üye Bilgileri'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'İsim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['name']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Soyisim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['surname']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Telefon: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['phone']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'E-posta: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['email']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Matrikül No: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['matriculNo']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Tekris: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['tekris']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Geçiş: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['gecis']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Yükseliş: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['yukselis']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Doğum Tarihi: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['dogum']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Meslek: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['meslek']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Kan Grubu: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['kangrubu']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Rehber Üs:.: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['rehber']}'),
                ])),
                const Divider(color: Colors.black, thickness: 3, height: 20),
                const SizedBox(height: 30),
                const Text('Eşinin Bilgileri', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 15),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'İsim: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esisim']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Telefon: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['estel']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'E-posta: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esmail']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Meslek: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esmeslek']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Doğum Tarihi: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['esdogum']}'),
                ])),
                const Divider(color: Colors.black26, thickness: 1, height: 20),
                Text.rich(TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Kan Grubu: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${user['eskangrubu']}'),
                ])),
              ],
            ),
          ),
          actions: [
            SizedBox(
              height: 30,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Kapat'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpcomingBirthdays() async {
    List<Map<String, dynamic>> birthdays = await _birthdayService.getUpcomingBirthdays();
    if (birthdays.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Yaklaşan Doğum Günleri', style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: birthdays.map((birthday) {
                String dateStr = '';
                if (birthday['nextBirthday'] != null && birthday['nextBirthday'] is DateTime) {
                  try {
                    dateStr = DateFormat('dd.MM.yyyy').format(birthday['nextBirthday']);
                  } catch (e) {
                    dateStr = '';
                  }
                }
                return Text('${birthday['name']} ${birthday['surname']} - $dateStr');
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Kapat'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bilgi'),
            content: Text('Yaklaşan doğum günü bulunmamaktadır.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        toolbarHeight: 80,
        title: Row(
          children: [
            Expanded(child: Image.asset('assets/images/ucgul.png')),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.cake, color: Colors.red,),
              onPressed: _showUpcomingBirthdays,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Arama kutusu eklendi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İsim veya Matrikül No ile ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var user = filteredUsers[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                          '${user['matriculNo']} - ${user['name']} ${user['surname']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _viewUserDetails(user),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black26, thickness: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
