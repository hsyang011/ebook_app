import 'package:ebook_app/models/book.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookDetail extends StatefulWidget {
  final Book book;

  const BookDetail({super.key, required this.book});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  final FlutterTts tts = FlutterTts();
  bool isFavorite = false;
  final reviewText = TextEditingController();
  int reviewCnt = 0;

  @override
  void initState() {
    super.initState();
    // 언어 설정
    tts.setLanguage('ko-KR');
    // 속도 지정 (0.0이 제일 느리고 1.0이 제일 빠름)
    tts.setSpeechRate(0.5);
    // 방문 기록 핸들러
    _handleHistory();
    // 좋아요 기록 핸들러
    initFavorite();
  }

  @override
  Widget build(BuildContext context) {
    Book book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text('상세 보기', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            // icon: const Icon(Icons.favorite_border_outlined),
            icon: isFavorite ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_border_outlined),
            onPressed: _handleLikeButton,
          ),
          IconButton(
            icon: const Icon(Icons.travel_explore_outlined),
            onPressed: () {
              _launchURL('${book.url}');
            }),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 카드
            Container(
              margin: const EdgeInsets.all(1.0),
              height: 200,
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
                          return Image.asset('assets/images/noImage.jpg', width: 140.0);
                        },
                        fit: BoxFit.contain, width: 160.0
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${book.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text('${book.authors}', style: const TextStyle(fontSize: 17)),
                          const SizedBox(height: 5),
                          Text('${book.publisher}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 5),
                          Text('${book.datetime.split("T")[0]}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 20, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('책 설명', style: TextStyle(fontSize: 20, color: Colors.blue)),
                      TextButton(
                        child: const Icon(Icons.campaign_outlined),
                        // tts 기능
                        onPressed: () => tts.speak(book.contents)
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black, height: 5),
                  Text('${book.contents}...', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Text('리뷰 $reviewCnt건', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                  const SizedBox(height: 8),
                  // 리뷰 등록
                  TextField(
                    style: const TextStyle(fontSize: 16),
                    controller: reviewText,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0)
                      ),
                      hintText: '리뷰를 등록하세요',
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    onSubmitted: (value) => postReview(value),
                  ),
                  const SizedBox(height: 8),
                  // 리뷰 목록
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reviews').where('isbn', isEqualTo: widget.book.isbn).snapshots(),
                    builder: (context, snapshot) => reviewList(context, snapshot), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 인터넷으로 이동
  void _launchURL(url) async {
    Uri _url = Uri.parse(url);
    await canLaunchUrl(_url) ? await launchUrl(_url) : throw 'Could not launch $url'; 
  }

  // 좋아요 버튼 클릭 핸들러
  void _handleLikeButton() async {
    final user = FirebaseAuth.instance.currentUser;
    final book = widget.book; // 책

    if (user != null) {
      final likesRef = FirebaseFirestore.instance.collection('likes');
      final likeDoc = likesRef.doc('${user.email}_${book.isbn}');

      if ((await likeDoc.get()).exists) {
        // 이미 좋아요한 경우, 좋아요 취소
        likeDoc.delete();
        // 검정 하트로 변경
        setState(() {
          isFavorite = false;
        });
        // 토스트 메시지 출력
        Fluttertoast.showToast(
          msg: '좋아요가 취소되었습니다.',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.black,
        );
      } else {
        // 좋아요 추가
        likeDoc.set({'userId': user.email, 'authors': book.authors, 'contents': book.contents, 'datetime': book.datetime,
          'isbn': book.isbn, 'price': book.price, 'publisher': book.publisher, 'salePrice': book.salePrice, 'status': book.status,
          'thumbnail': book.thumbnail, 'title': book.title, 'url': book.url});
        // 빨간색 하트로 변경
        setState(() {
          isFavorite = true;
        });
        // 토스트 메시지 출력
        Fluttertoast.showToast(
          msg: '좋아요가 반영되었습니다.',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.black,
        );
      }
    }
  }

  // 좋아요 여부
  void initFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    final book = widget.book; // 책

    if (user != null) {
      final likesRef = FirebaseFirestore.instance.collection('likes');
      final likeDoc = likesRef.doc('${user.email}_${book.isbn}');

      if ((await likeDoc.get()).exists) {
        // 이미 좋아요한 경우 빨간색으로 반영
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  // 방문 기록 핸들러
  void _handleHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final book = widget.book; // 책

    if (user != null) {
      final historiesRef = FirebaseFirestore.instance.collection('histories');
      final historyDoc = historiesRef.doc('${user.email}_${book.isbn}');

      if ((await historyDoc.get()).exists) {
        // 이미 저장되었을 경우 함수 종료
        return;
      } else {
        // 방문 기록 추가
        historyDoc.set({'userId': user.email, 'authors': book.authors, 'contents': book.contents, 'datetime': book.datetime,
          'isbn': book.isbn, 'price': book.price, 'publisher': book.publisher, 'salePrice': book.salePrice, 'status': book.status,
          'thumbnail': book.thumbnail, 'title': book.title, 'url': book.url});
      }
    }
  }

  // 리뷰 등록
  void postReview(value) async {
    final user = FirebaseAuth.instance.currentUser;
    final book = widget.book; // 책

    if (user != null) {
      final reviewsRef = FirebaseFirestore.instance.collection('reviews');
      final reviewDoc = reviewsRef.doc('${user.email}_${book.isbn}');

      // 리뷰 등록
      reviewDoc.set({'userId': user.email, 'isbn': book.isbn, 'reviewText': value});
      // 실시간 반영
      setState(() {
        reviewText.clear();
      });
      // 토스트 메시지 출력
      Fluttertoast.showToast(
        msg: '리뷰가 등록되었습니다.',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.black,
      );
    }
  }

  // 리뷰 리스트 출력
  reviewList(context, snapshot) {
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
    reviewCnt = snapshot.data!.docs.length;

    List<Widget> reviewWidgets = [];
    // 데이터를 가져와서 리뷰 목록을 생성
    for (var review in snapshot.data!.docs) {
      reviewWidgets.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // 배경색 설정
            borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
          ),
          child: ListTile(
            leading: const Icon(Icons.account_box, size: 50.0),
            title: Text(review['userId'].split('@')[0]),
            subtitle: Text(review['reviewText']),
          ),
        )
      );
      reviewWidgets.add(const SizedBox(height: 8));
    }

    return ListView(
      shrinkWrap: true,
      children: reviewWidgets,
    );
  }
}