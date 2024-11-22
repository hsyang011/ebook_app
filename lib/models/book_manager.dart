import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/screens/details.dart';
import 'package:flutter/material.dart';

class BookManager {
  // 싱글톤 구현
  static final BookManager bookManager = BookManager.getInstance();
  // private 생성자
  BookManager.getInstance();
  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 팩토리 메소드
  factory BookManager() {
    return bookManager;
  }

  List<Book> recentlyBooks = [];
  Map<String, List<Book>> allBooks = {};
  List<String> categories = ['소설', '잡지', '여행', '요리', 'IT모바일'];
  List<String> likedBooks = [];

  buildBookCard(Book book, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      height: 160,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
          MaterialPageRoute(builder: (context) => BookDetail(book: book)));
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(1.0)),
          child: Stack(
            children: [
              Image.network(
                book.thumbnail,
                loadingBuilder: (context, child, loadingProgress) {
                  // 이미지 로딩이 완료되면 원래 이미지를 반환
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    // 이미지 로딩 중 또는 실패 시 대체 이미지를 반환
                    return const CircularProgressIndicator();
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  // 이미지 로딩 중 오류 발생 시 대체 이미지를 반환
                  return Image.asset('assets/images/noImage.jpg', fit: BoxFit.contain, width: 140.0);
                },
                fit: BoxFit.contain, width: 140.0
              ),
            ],
          ),
        ),
      )
    );
  }

  buildBookList(Book book, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      height: 160,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
          MaterialPageRoute(builder: (context) => BookDetail(book: book)));
        },
        child: ClipRRect(
          child: Row(
            children: [
              SizedBox(
                child: Image.network(
                  book.thumbnail,
                  loadingBuilder: (context, child, loadingProgress) {
                    // 이미지 로딩이 완료되면 원래 이미지를 반환
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      // 이미지 로딩 중 또는 실패 시 대체 이미지를 반환
                      return const CircularProgressIndicator();
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로딩 중 오류 발생 시 대체 이미지를 반환
                    return Image.asset('assets/images/noImage.jpg', fit: BoxFit.contain, width: 140.0);
                  },
                  fit: BoxFit.contain, width: 140.0
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${book.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text('${book.authors}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                    const SizedBox(height: 3),
                    Text('${book.contents}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}