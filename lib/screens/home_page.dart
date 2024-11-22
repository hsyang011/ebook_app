import 'dart:convert';
import 'package:ebook_app/models/book_manager.dart';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/screens/searchresult.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final List<Book>? preparedBooks;
  final List<Book>? recentlyBooks;

  const HomePage({super.key, required this.preparedBooks, required this.recentlyBooks});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 싱글톤 인스턴스 객체 획득
  BookManager bookMgr = BookManager.getInstance();
  List<Book> searchResultBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 캐러세일 형태의 책 썸네일
            Container(
              height: 160,
              alignment: Alignment.center,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // padding: const EdgeInsets.all(8),
                itemCount: widget.preparedBooks?.length,
                itemBuilder: (context, index) {
                  // null값을 체크해야 앱 로딩시 오류가 안나므로 체크한다.
                  if (widget.preparedBooks != null) {
                    return bookMgr.buildBookCard(widget.preparedBooks![index], context);
                  }
                  return null;
                },
              ),
            ),
            // 텍스트
            Container(
              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              padding: const EdgeInsets.all(12),
              child: const Text('카테고리', style: TextStyle(fontSize: 20)),
            ),
            // 카테고리
            Container(
              height: 60,
              alignment: Alignment.center,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: bookMgr.categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    child: ElevatedButton(
                      child: Text('${bookMgr.categories[index]}'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                      ),
                      onPressed: () {
                        searchBookList(bookMgr.categories[index]);
                      }
                    ),
                  );
                },
              ),
            ),
            // 텍스트
            Container(
              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              padding: const EdgeInsets.all(12),
              child: const Text('최근 등록됨', style: TextStyle(fontSize: 20)),
            ),
            // 최근 책 리스트
            Container(
              height: 1625,
              alignment: Alignment.center,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                // padding: const EdgeInsets.all(12),
                itemCount: widget.recentlyBooks?.length,
                itemBuilder: (context, index) {
                  // null값을 체크해야 앱 로딩시 오류가 안나므로 체크한다.
                  if (widget.recentlyBooks != null) {
                    return bookMgr.buildBookList(widget.recentlyBooks![index], context);
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 결과 리스트
  void searchBookList([String keyword = 'a']) async {
    if (searchResultBooks.isNotEmpty) searchResultBooks.clear(); // 리스트 초기화
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
      searchResultBooks.add(book);
    }
    // searchPage(searchResultBooks);
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchResultPage(searchResultBooks, keyword))
      );
    });
    // allBooks[categories[idx]] = preparedBooks;
  }
}