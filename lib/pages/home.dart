import 'package:accounts_book/database.dart';
import 'package:accounts_book/models/acct_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'acctbook.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Acct>> accts;
  final TextEditingController _acctcontroller = TextEditingController();
  getaccts() {
    var t=SQLiteDbProvider.db.getAllAccts();
    accts= t;
  }
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
  @override
  void initState() {
    super.initState();
    getaccts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined),
            SizedBox(width: 10.0,),
            Text("My Accounts Book"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: accts,
                builder: (context, AsyncSnapshot snapshot){
                  if(snapshot.hasError) print(snapshot.error);
                  if(snapshot.hasData && snapshot.data.length>0){
                    return ListView.builder(
                          itemCount: snapshot.data.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AccountBook(acct: snapshot.data[index])));
                                  },
                                  title: Text(snapshot.data[index].acct,style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      showDialog(context: context, builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: const Text("Do you want to delete this Account"),
                                          actions: [
                                            ElevatedButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                SQLiteDbProvider.db.deleteAcct(snapshot.data[index].id).then((value) {
                                                  getaccts();
                                                  setState(() {});
                                                });
                                                showToast('Account Deleted');
                                                Navigator.of(context).pop();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:  MaterialStateProperty.all(Colors.red[300]),
                                                overlayColor:  MaterialStateProperty.all(Colors.red[500]),

                                              ),
                                            ),
                                            ElevatedButton(
                                              child: const Text('NO'),
                                              onPressed: () {
                                                  Navigator.of(context).pop();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:  MaterialStateProperty.all(Colors.lightGreen[300]),
                                                overlayColor:  MaterialStateProperty.all(Colors.lightGreen[500]),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                    },
                                    child: Icon(Icons.delete_outline,color: Colors.red,),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(CircleBorder()),
                                      padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                                      backgroundColor: MaterialStateProperty.all(Colors.white), // <-- Button color
                                      ),
                                    ),
                                  ),
                                ),
                              );
                          }

                    );
                  }
                  else{
                    return Stack(
                        alignment: Alignment.center,
                        children: const [
                          SizedBox(height: 350.0),
                          Text("Create a new Account",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500)),]
                    );
                  }
                },
              ),
            ),
          ),
          const Divider(thickness: 3.0,height: 5.0,color: Colors.blueAccent,),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Form(
                      key: _formKey,
                      child: Container(
                        width: 290.0,
                        child: TextFormField(
                          controller: _acctcontroller,
                          decoration: InputDecoration(
                            label: const Text("Account Name"),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Account name';
                            }
                            return null;
                          },
                        ),
                      )
                  ),
                  GestureDetector(
                    onTap: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        SQLiteDbProvider.db.insertAcct(Acct(0,_acctcontroller.text)).then((value) {
                          getaccts();
                          setState(() {
                            _acctcontroller.clear();
                          });
                        }
                      );
                        showToast('Account Created');

                      }
                    },
                    child: Icon(Icons.add,color: Colors.grey[600],size: 35.0,),

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
