import 'package:ebook_app/models/book_manager.dart';
import 'package:ebook_app/models/book.dart';
import 'package:flutter/material.dart';

class SearchResultPage extends StatefulWidget {
  final List<Book> searchResultBooks;
  final String keyword;

  const SearchResultPage(this.searchResultBooks, this.keyword, {Key? key}) : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  BookManager bookMgr = BookManager.getInstance();

  @override
  Widget build(BuildContext context) {
    // widget.searchResultBooks를 사용하여 데이터에 접근할 수 있습니다.
    List<Book> books = widget.searchResultBooks;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.keyword} 검색 결과 총 ${books.length}건', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView.builder(
          // padding: const EdgeInsets.all(12),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return bookMgr.buildBookList(books[index], context);
          },
        ),
      ),
    );
  }
}