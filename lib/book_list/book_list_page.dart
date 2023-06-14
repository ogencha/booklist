import 'package:book_list_sample/add_book/add_book_page.dart';
import 'package:book_list_sample/book_list/book_list_model.dart';
import 'package:book_list_sample/domain/book.dart';
import 'package:book_list_sample/edit_book/edit_book_page.dart';
import 'package:book_list_sample/login/login_page.dart';
import 'package:book_list_sample/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BookListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookListModel>(
      create: (_) => BookListModel()..fetchBookList(),
      child: ScaffoldMessenger(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('本一覧'),
            actions: [
              IconButton(
                  onPressed: () async {
                    //画面遷移
                    if (FirebaseAuth.instance.currentUser != null) {
                      print('ログインしている');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                          fullscreenDialog: true,
                        ),
                      );
                    } else {
                      print('ログインいてない');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                          fullscreenDialog: true,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.person)),
            ],
          ),
          body: Center(
            child: Consumer<BookListModel>(
              builder: (context, model, child) {
                final List<Book>? books = model.books;

                if (books == null) {
                  return const CircularProgressIndicator();
                }

                final List<Widget> widget = books
                    .map(
                      (book) => Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          dismissible: DismissiblePane(onDismissed: () {}),
                          children: [
                            SlidableAction(
                              backgroundColor: Color(0xFF21B7CA),
                              foregroundColor: Colors.white,
                              icon: Icons.share,
                              label: '編集',
                              onPressed: (context) async {
                                final String? title = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditBookPage(book)),
                                );

                                if (title != null) {
                                  final snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('$titleを編集しました'),
                                  );
                                  scaffoldMessengerKey.currentState
                                      ?.showSnackBar(snackBar);
                                }
                                model.fetchBookList();
                              },
                            ),
                            SlidableAction(
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '削除',
                                onPressed: (context) async {
                                  //削除しますか？はいなら削除
                                  await showConfirmDialog(context, book, model);
                                }),
                          ],
                        ),
                        child: ListTile(
                          leading: book.imgURL != null
                              ? Image.network(book.imgURL!)
                              : null,
                          title: Text(book.title),
                          subtitle: Text(book.author),
                        ),
                      ),
                    )
                    .toList();
                return Builder(builder: (context) {
                  return ListView(
                    children: widget,
                  );
                });
              },
            ),
          ),
          floatingActionButton:
              Consumer<BookListModel>(builder: (context, model, child) {
            return FloatingActionButton(
              onPressed: () async {
                //画面遷移
                final bool? added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookPage(),
                    fullscreenDialog: true,
                  ),
                );

                if (added != null && added) {
                  const snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('本を追加しました'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }

                model.fetchBookList();
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            );
          }),
        ),
      ),
    );
  }
}

Future showConfirmDialog(
  BuildContext context,
  Book book,
  BookListModel model,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        title: Text("削除の確認"),
        content: Text("${book.title}を削除しますか？"),
        actions: [
          Builder(builder: (context) {
            return TextButton(
              child: Text("いいえ"),
              onPressed: () => Navigator.pop(context),
            );
          }),
          Builder(builder: (context) {
            return TextButton(
              child: Text("はい"),
              onPressed: () async {
                //modelで削除
                await model.delete(book);
                Navigator.pop(context);
                final snackBar = SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('${book.title}を削除しました'),
                );
                scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
                model.fetchBookList();
              },
            );
          }),
        ],
      );
    },
  );
}
