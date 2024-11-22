import 'dart:convert';
import 'package:ebook_app/models/book_manager.dart';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/screens/explore_page.dart';
import 'package:ebook_app/screens/home_page.dart';
import 'package:ebook_app/screens/search.dart';
import 'package:ebook_app/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GlobalPage extends StatefulWidget {
  const GlobalPage({super.key});

  @override
  State<GlobalPage> createState() => _GlobalPageState();
}

class _GlobalPageState extends State<GlobalPage> {
  BookManager bookMgr = BookManager.getInstance();
  int currentIndex = 0;
  String title = '홈';

  @override
  void initState() {
    super.initState();
    for (int i=0; i<bookMgr.categories.length; i++) {
      preparedBookList(bookMgr.categories[i], i);
    }
    recentlyBookList('가');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 루트에서 뒤로가기 누를 때 앱 종료 다이얼로그 출력
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          // 삼항연산자를 사용하여 현재 페이지가 2번인덱스이면 검색 아이콘 안보이게 처리
          actions: currentIndex == 2 ? [] : [
            IconButton(
              icon: Icon(Icons.search_outlined, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onPressed: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage())
                  );
                });
              },
            ),
          ],
        ),
        body: Center(
          child: getPage(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 30,
          selectedItemColor: Colors.blue,
          selectedLabelStyle: const TextStyle(fontSize: 14),
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          currentIndex: currentIndex,
          onTap: (idx) {
            switch (idx) {
              case 0: title = '홈'; break;
              case 1: title = '탐색'; break;
              case 2: title = '설정'; break;
            }
            setState(() {
              currentIndex = idx;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: '탐색'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: '설정'),
          ],
        ),
      ),
    );
  }

  Widget getPage() {
    Widget? page;
    switch (currentIndex) {
      case 0:
        page = HomePage(preparedBooks: bookMgr.allBooks['소설'], recentlyBooks: bookMgr.recentlyBooks);
        break;
      case 1:
        page = ExplorePage(books: bookMgr.allBooks);
        break;
      case 2:
        page = const SettingsPage();
        break;
    }
    return page!;
  }
  
  // 캐러세일에서 준비할 책 리스트
  void preparedBookList([String keyword = 'a', int idx = 0]) async {
    List<Book> preparedBooks = [];
    var url = Uri.parse('https://dapi.kakao.com/v3/search/book?target=title&query=$keyword');
    var response = await http.get(url, headers: {"Authorization": "KakaoAK b270028a0ad57404c64a581cb79f48c7"});
    // print(response.body);
    // var statusCode = response.statusCode;
    var responseBody = utf8.decode(response.bodyBytes);
    var jsonData = jsonDecode(responseBody);
    // print(jsonData);
    setState(() {});
    for (int i=0; i<jsonData['documents'].length; i++) {
      var authors = jsonData['documents'][i]['authors'];
      var contents = jsonData['documents'][i]['contents'];
      var datetime =  jsonData['documents'][i]['datetime'];
      var isbn = jsonData['documents'][i]['isbn'];
      var price = jsonData['documents'][i]['price'];
      var publisher = jsonData['documents'][i]['publisher'];
      var salePrice = jsonData['documents'][i]['salePrice'];
      var status = jsonData['documents'][i]['status'];
      var thumbnail = jsonData['documents'][i]['thumbnail'];
      var title = jsonData['documents'][i]['title'];
      var url = jsonData['documents'][i]['url'];
      var book = Book(authors: authors, contents: contents, datetime: datetime,
        isbn: isbn, price: price, publisher: publisher, salePrice: salePrice,
        status: status, thumbnail: thumbnail, title: title, url: url);
      preparedBooks.add(book);
    }
    bookMgr.allBooks[bookMgr.categories[idx]] = preparedBooks;
  }

  // 최근 책 리스트
  void recentlyBookList([String keyword = 'a']) async {
    var url = Uri.parse('https://dapi.kakao.com/v3/search/book?target=title&query=$keyword&sort=latest');
    var response = await http.get(url, headers: {"Authorization": "KakaoAK b270028a0ad57404c64a581cb79f48c7"});
    // print(response.body);
    // var statusCode = response.statusCode;
    var responseBody = utf8.decode(response.bodyBytes);
    var jsonData = jsonDecode(responseBody);
    // print(jsonData);
    setState(() {});
    for (int i=0; i<jsonData['documents'].length; i++) {
      var authors = jsonData['documents'][i]['authors'];
      var contents = jsonData['documents'][i]['contents'];
      var datetime =  jsonData['documents'][i]['datetime'];
      var isbn = jsonData['documents'][i]['isbn'];
      var price = jsonData['documents'][i]['price'];
      var publisher = jsonData['documents'][i]['publisher'];
      var salePrice = jsonData['documents'][i]['salePrice'];
      var status = jsonData['documents'][i]['status'];
      var thumbnail = jsonData['documents'][i]['thumbnail'];
      var title = jsonData['documents'][i]['title'];
      var url = jsonData['documents'][i]['url'];
      var book = Book(authors: authors, contents: contents, datetime: datetime,
        isbn: isbn, price: price, publisher: publisher, salePrice: salePrice,
        status: status, thumbnail: thumbnail, title: title, url: url);
      bookMgr.recentlyBooks.add(book);
    }
  }
  
  // 앱 종료 다이얼로그
  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('정말로 앱을 종료하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('아니요'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('예'),
          ),
        ],
      ),
    ) ?? false;
  }
}