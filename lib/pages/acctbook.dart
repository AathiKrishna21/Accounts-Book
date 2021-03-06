import 'package:accounts_book/models/acct_class.dart';
import 'package:accounts_book/pages/addTrxn.dart';
import 'package:accounts_book/pages/cashInflow.dart';
import 'package:accounts_book/pages/cashoutflow.dart';
import 'package:accounts_book/pages/total.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AccountBook extends StatefulWidget {
  final Acct acct;
  const AccountBook({Key? key,required this.acct}) : super(key: key);

  @override
  _AccountBookState createState() => _AccountBookState(acct);
}

class _AccountBookState extends State<AccountBook> {
  int _selectedIndex = 0;
  final Acct acct;
  _AccountBookState(this.acct);
  void showToast(String toastmsg) {
    Fluttertoast.showToast(
        msg: toastmsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white
    );
  }
  // static List<Widget> _widgetOptions = <Widget>[
  //   Text('Profile Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  // ];
  getwidget(int t){
    if(t==0){
      return  AddTrxn(acct: acct,showToast: showToast,);
    }
    if(t==1){
      return  CashInflow(acct: acct,showToast: showToast,);
    }
    if(t==2){
      return CashOutflow(acct: acct,showToast: showToast,);
    }
    return Total(acct: acct);
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_outlined),
              SizedBox(width: 10.0,),
              Text(widget.acct.acct+" - Account"),
            ],
          ),
          backgroundColor: Colors.blueAccent
      ),
      body: Center(
        child: getwidget(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_to_photos_outlined),
              label: 'Add Transaction',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on_outlined),
                label: 'Income',
                backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.attach_money_outlined),
                label: 'Expenditure',
                backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_membership_outlined),
              label: 'Total',
              backgroundColor: Colors.white,
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.grey[300],
          selectedItemColor: Colors.blueAccent,
          iconSize: 30,
          onTap: _onItemTapped,
          elevation: 5
      ),
    );
  }
}
