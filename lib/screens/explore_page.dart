import 'dart:convert';
import 'package:ebook_app/models/book_manager.dart';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/screens/searchresult.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExplorePage extends StatefulWidget {
  final Map<String, List<Book>>? books;

  const ExplorePage({super.key, required this.books});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  BookManager bookMgr = BookManager.getInstance();
  List<Book> searchResultBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: bookMgr.categories.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              // 카테고리
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bookMgr.categories[index], style: const TextStyle(fontSize: 20)),
                    TextButton(
                      child: const Text('모두 보기', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        searchBookList(bookMgr.categories[index]);
                      },
                    )
                  ],
                )
              ),
              // 캐러세일 형태의 책 썸네일
              Container(
                height: 160,
                alignment: Alignment.center,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // padding: const EdgeInsets.all(12),
                  itemCount: widget.books![bookMgr.categories[index]]?.length,
                  itemBuilder: (context, index2) {
                    return bookMgr.buildBookCard(widget.books![bookMgr.categories[index]]![index2], context);
                  },
                ),
              ),
            ],
          );
        },
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