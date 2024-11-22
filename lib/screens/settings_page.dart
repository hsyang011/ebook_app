import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebook_app/main.dart';
import 'package:ebook_app/screens/favorites.dart';
import 'package:ebook_app/screens/histories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          ListTile(
            title: const Text('좋아요'),
            leading: const Icon(Icons.favorite_border_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('likes')
                      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SpinKitWave(
                        // 색상을 파란색으로 설정
                        color: Color(0xFF6A7BA2),
                        // 크기를 50.0으로 설정
                        size: 50.0,
                        // 애니메이션 수행 시간을 2초로 설정
                        duration: Duration(seconds: 2),
                      ); // 데이터를 불러올 동안 로딩 표시
                    }

                    final likedBooks = snapshot.data?.docs.map((doc) => doc).toList();

                    // likedBooks 목록을 사용하여 사용자가 좋아요 한 책을 표시
                    return FavoriteBooksList(likedBooks: likedBooks);
                  },
                )),
              );
            },
          ),
          const Divider(
            color: Colors.grey,
            height: 5,
          ),
          ListTile(
            title: const Text('방문 기록'),
            leading: const Icon(Icons.history_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('histories')
                      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SpinKitWave(
                        // 색상을 파란색으로 설정
                        color: Color(0xFF6A7BA2),
                        // 크기를 50.0으로 설정
                        size: 50.0,
                        // 애니메이션 수행 시간을 2초로 설정
                        duration: Duration(seconds: 2),
                      ); // 데이터를 불러올 동안 로딩 표시// 데이터를 불러올 동안 로딩 표시
                    }

                    final historyBooks = snapshot.data?.docs.map((doc) => doc).toList();

                    // likedBooks 목록을 사용하여 사용자가 좋아요 한 책을 표시
                    return HistoryBooksList(historyBooks: historyBooks);
                  },
                )),
              );
            },
          ),
          const Divider(
            color: Colors.grey,
            height: 5,
          ),
          ListTile(
            title: const Text('다크 모드'),
            leading: const Icon(Icons.dark_mode_outlined),
            trailing: Switch(
              value: switchValue,
              onChanged: (value) {
                setState(() {
                  if (switchValue) {
                    switchValue = false;
                    // 토스트 메시지 출력
                    Fluttertoast.showToast(
                      msg: '다크모드가 해제되었습니다.',
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.black,
                    );
                    // 내부저장소에 저장
                    prefs.setBool('isDarkMode', false);
                  } else {
                    switchValue = true;
                    // 토스트 메시지 출력
                    Fluttertoast.showToast(
                      msg: '다크모드가 실행되었습니다.',
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.black,
                    );
                    // 내부저장소에 저장
                    prefs.setBool('isDarkMode', true);
                  }
                  MyApp.themeNotifier.value = MyApp.themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
            onTap: () {
              setState(() {
                if (switchValue) {
                  switchValue = false;
                  // 토스트 메시지 출력
                  Fluttertoast.showToast(
                    msg: '다크모드가 해제되었습니다.',
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.black,
                  );
                  // 내부저장소에 저장
                  prefs.setBool('isDarkMode', false);
                } else {
                  switchValue = true;
                  // 토스트 메시지 출력
                  Fluttertoast.showToast(
                    msg: '다크모드가 실행되었습니다.',
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.black,
                  );
                  // 내부저장소에 저장
                  prefs.setBool('isDarkMode', true);
                }
                MyApp.themeNotifier.value = MyApp.themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              });
            },
          ),
          const Divider(
            color: Colors.grey,
            height: 5,
          ),
          ListTile(
            title: const Text('정보'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('정보'),
                    content: Text('플러터로 만든 ebook앱입니다.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Close'),
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(
            color: Colors.grey,
            height: 5,
          ),
          ListTile(
            title: const Text('라이선스'),
            leading: const Icon(Icons.description_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LicensePage())
              );
            },
          ),
          const Divider(
            color: Colors.grey,
            height: 5,
          ),
          ListTile(
            title: const Text('로그아웃'),
            leading: const Icon(Icons.logout_outlined),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}