import 'package:accounts_book/models/acct_class.dart';
import 'package:accounts_book/models/trxn_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database.dart';

class CashInflow extends StatefulWidget {
  final Acct acct;
  const CashInflow({Key? key,required this.acct}) : super(key: key);

  @override
  _CashInflowState createState() => _CashInflowState();
}

class _CashInflowState extends State<CashInflow> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Trxn>> trxns;
  final TextEditingController _sourcecontroller = TextEditingController();
  final TextEditingController _amountcontroller = TextEditingController();
  final f = DateFormat('dd-MM-yy');
  gettrxn() {
    var t=SQLiteDbProvider.db.getgainAcctsByTopic(widget.acct.id, 1);
    trxns=t;
  }
  updatetotal(double t,Acct a){
    SQLiteDbProvider.db.updateAcct(Acct(a.id,a.acct,t,a.tspend));
  }
  @override
  void initState() {
    super.initState();
    gettrxn();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                const Text("Cash Inflow",
                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25.0,),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    showDialog(
                        context: context,
                        builder: (context) {
                          bool isChecked = false;
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              content: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: _sourcecontroller,
                                        validator: (value) {
                                          return value!.isNotEmpty ? null : "Enter Source";
                                        },
                                        decoration:
                                        InputDecoration(hintText: "Source"),
                                      ),
                                      TextFormField(
                                        controller: _amountcontroller,
                                        validator: (value) {
                                          return value!.isNotEmpty ? null : "Enter amount";
                                        },
                                        decoration:
                                        InputDecoration(hintText: "Amount"),
                                      ),

                                    ],
                                  )),
                              title: Text('Add Cash Inflow'),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text('Add'),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      double temp=double.parse(_amountcontroller.text);
                                      SQLiteDbProvider.db.insert(Trxn(0,f.format(DateTime.now()).split(" ")[0],_sourcecontroller.text,1,temp,widget.acct.id)).then((value) {
                                        gettrxn();
                                        double t=widget.acct.tgain+temp;
                                        updatetotal(t, widget.acct);
                                        _sourcecontroller.clear();
                                        _amountcontroller.clear();
                                        setState(() {});
                                      }
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ],
                            );
                          });
                        });
                  },
                  child: Text("ADD"),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder(
                  future: trxns,
                  builder: (context, AsyncSnapshot snapshot){
                    if(snapshot.hasError) print(snapshot.error);
                    if(snapshot.hasData){
                      return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text(
                                  'Date',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                              )),
                              DataColumn(label: Text(
                                  'Source',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                              )),
                              DataColumn(label: Text(
                                  'Amount',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                              )),
                              DataColumn(label: Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                              )),
                            ],
                            rows: List<DataRow>.generate(
                                snapshot.data.length,
                                    (index) => DataRow(
                                    color: MaterialStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          if (index % 2 == 0)
                                            return Colors.grey.withOpacity(0.3);
                                          return Colors.white.withOpacity(0.3); // Use default value for other states and odd rows.
                                        }),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(snapshot.data[index].date))),
                                      DataCell(Center(
                                          child: Text(snapshot.data[index].reason))),
                                      DataCell(Center(
                                          child: Text(snapshot.data[index].total.toString()))),
                                      DataCell(Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                                showDialog(
                                                context: context,
                                                builder: (context) {
                                                bool isChecked = false;
                                                return StatefulBuilder(builder: (context, setState) {
                                                  _amountcontroller.text=snapshot.data[index].total.toString();
                                                  _sourcecontroller.text=snapshot.data[index].reason;
                                                  return AlertDialog(
                                                    content: Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          TextFormField(
                                                            controller: _sourcecontroller,
                                                            validator: (value) {
                                                              return value!.isNotEmpty ? null : "Enter Source";
                                                              },
                                                            decoration: InputDecoration(hintText: "Source"),
                                                          ),
                                                          TextFormField(
                                                            controller: _amountcontroller,
                                                            validator: (value) {
                                                              return value!.isNotEmpty ? null : "Enter amount";
                                                              },
                                                            decoration: InputDecoration(hintText: "Amount"),
                                                            ),

                                                        ],
                                                      )
                                                    ),
                                                    title: Text('Update Cash Inflow'),
                                                    actions: <Widget>[
                                                    ElevatedButton(
                                                        child: Text('Done'),
                                                        onPressed: () {
                                                          if (_formKey.currentState!.validate()) {
                                                            double temp=double.parse(_amountcontroller.text);
                                                            double t=widget.acct.tgain+temp-snapshot.data[index].total;
                                                            SQLiteDbProvider.db.update(Trxn(snapshot.data[index].id,snapshot.data[index].date,_sourcecontroller.text,1,temp,snapshot.data[index].title)).then((value) {
                                                              gettrxn();
                                                              updatetotal(t, widget.acct);
                                                              _sourcecontroller.clear();
                                                              _amountcontroller.clear();
                                                              setState(() {});
                                                            }
                                                            );
                                                            Navigator.of(context).pop();
                                                          }
                                                        },
                                                    ),
                                                    ],
                                                    );
                                                  }
                                                  );
                                                }
                                                );
                                            },
                                            child: Icon(Icons.edit, color: Colors.blueAccent),
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(5),
                                              primary: Colors.white, // <-- Splash color
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              SQLiteDbProvider.db.delete(snapshot.data[index].id).then((value) {
                                                gettrxn();
                                                double t=widget.acct.tgain-snapshot.data[index].total;
                                                updatetotal(t, widget.acct);
                                                setState(() {});
                                              });
                                            },
                                            child: Icon(Icons.delete_outline, color: Colors.red),
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(5),
                                              primary: Colors.white,// <-- Splash color
                                            ),
                                          )
                                        ],
                                      )),
                                    ])),
                          ),
                        );
                    }
                    else{
                      return const Text("Create a new Account");
                    }
                  },
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              color: Colors.grey,
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: Text("Total : "+widget.acct.tgain.toString(),style: const TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600),),
              ),
            )
          ],
        ),
      );
  }
}
