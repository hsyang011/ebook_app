import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/models/book_manager.dart';
import 'package:flutter/material.dart';

class HistoryBooksList extends StatefulWidget {
  final historyBooks;

  const HistoryBooksList({super.key, required this.historyBooks});

  @override
  State<HistoryBooksList> createState() => _HistoryBooksListState();
}

class _HistoryBooksListState extends State<HistoryBooksList> {
  BookManager bookMgr = BookManager.getInstance();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('방문 기록 리스트', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined, color: Colors.blue),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView.builder(
          // padding: const EdgeInsets.all(12),
          itemCount: widget.historyBooks.length,
          itemBuilder: (context, index) {
            var data = widget.historyBooks[index];
            var book = Book(authors: data['authors'], contents: data['contents'], datetime: data['datetime'], isbn: data['isbn'],
              price: data['price'], publisher: data['publisher'], salePrice: data['salePrice'], status: data['status'],
              thumbnail: data['thumbnail'], title: data['title'], url: data['url']);
            return bookMgr.buildBookList(book, context);
          },
        ),
      ),
    );
    // return Scaffold(
    //   body: Container(
    //     alignment: Alignment.center,
    //     child: Text('${widget.likedBooks[0]["title"]}'),
    //   ),
    // );
  }
}