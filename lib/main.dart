import 'package:accounts_book/pages/acctbook.dart';
import 'package:accounts_book/pages/home.dart';
import 'package:flutter/material.dart';

import 'models/acct_class.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: const Home(),
      routes: {
        "/" : (context) => const Home(),
        "/acct" : (context) => AccountBook(acct: Acct(0,"")),
      },
    );
  }
}
