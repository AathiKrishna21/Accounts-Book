import 'package:accounts_book/database.dart';
import 'package:accounts_book/models/acct_class.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Acct>> accts;
  final TextEditingController _acctcontroller = TextEditingController();
  getaccts() async{
    var t=SQLiteDbProvider.db.getAllAccts();
    accts= t;
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
        title: Text("My Accounts Book"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: accts,
                builder: (context, AsyncSnapshot snapshot){
                  if(snapshot.hasError) print(snapshot.error);
                  if(snapshot.hasData){
                    return ListView.builder(
                          itemCount: snapshot.data.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ListTile(
                                  title: Text(snapshot.data[index].acct),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      if (_formKey.currentState!.validate()) {
                                        SQLiteDbProvider.db.deleteAcct(snapshot.data[index].id).then((value) {
                                          getaccts();
                                          setState(() {
                                            _acctcontroller.clear();
                                          });
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Account Deleted')),
                                        );
                                      }
                                    },
                                    child: Icon(Icons.delete_outline),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(CircleBorder()),
                                      padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                                      backgroundColor: MaterialStateProperty.all(Colors.white), // <-- Button color
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                    );
                  }
                  else{
                    return const Text("Create a new Account");
                  }
                },
              ),
            ),
          ),
          Divider(thickness: 3.0,height: 5.0,color: Colors.blueAccent,),
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
                        SQLiteDbProvider.db.insertAcct(Acct(0,_acctcontroller.text,0,0)).then((value) {
                          getaccts();
                          setState(() {
                            _acctcontroller.clear();
                          });
                        }
                      );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account Created')),
                        );
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
