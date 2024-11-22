import 'dart:convert';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/screens/searchresult.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final keyword = TextEditingController();
  List<Book> searchResultBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: TextField(
          autofocus: true,
          style: const TextStyle(fontSize: 16),
          controller: keyword,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 1.0)
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 1.0)
            ),
            hintText: '검색어를 입력하세요',
            filled: true,
            fillColor: Colors.transparent,
          ),
          onSubmitted: (value) => searchBookList(value),
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
    for (int i=0; i<searchResultBooks.length; i++) {
      print('$i번째 책의 이름 : ${searchResultBooks[i].title}');
    }
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SearchResultPage(searchResultBooks, keyword))
      );
    });
    // allBooks[categories[idx]] = preparedBooks;
  }
}