import 'package:accounts_book/helper/decimal_input.dart';
import 'package:accounts_book/models/acct_class.dart';
import 'package:accounts_book/models/trxn_class.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../database.dart';

class CashOutflow extends StatefulWidget {
  final Acct acct;
  final Function(String toastmsg) showToast;
  const CashOutflow({Key? key,required this.acct,required this.showToast}) : super(key: key);

  @override
  _CashOutflowState createState() => _CashOutflowState(acct);
}

class _CashOutflowState extends State<CashOutflow> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Trxn>> trxns;
  final Acct acct;
  _CashOutflowState(this.acct);
  double total=0.00;
  final TextEditingController _sourcecontroller = TextEditingController();
  final TextEditingController _amountcontroller = TextEditingController();
  final TextEditingController _sourceupdatecontroller = TextEditingController();
  final TextEditingController _amountupdatecontroller = TextEditingController();
  final _amountValidator = RegExInputFormatter.withRegex('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');
  final f = DateFormat('dd-MM-yy');
  gettrxn() {
    var t=SQLiteDbProvider.db.getgainAcctsByTopic(acct.id, 0);
    setState(() {
      trxns=t;
    });
  }
  gettotal() async{
    var t=(await SQLiteDbProvider.db.gettotal(acct.id, 0))[0]["total"];
    setState(() {
      total=t !=null ? double.parse(t.toStringAsFixed(2)) : 0;
    });
  }
  @override
  void initState() {
    super.initState();
    gettrxn();
    gettotal();
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
              const Text("Cash Outflow",
                style: TextStyle(fontWeight: FontWeight.w600,fontSize: 22.0,),
              ),
              ElevatedButton(
                onPressed: () {
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
                                        return value!.isNotEmpty ? null : "Enter Recipient";
                                      },
                                      decoration:
                                      InputDecoration(hintText: "Recipient"),
                                    ),
                                    TextFormField(
                                      controller: _amountcontroller,
                                      inputFormatters: [_amountValidator],
                                      keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: false,
                                      ),
                                      validator: (value) {
                                        return value!.isNotEmpty ? null : "Enter amount";
                                      },
                                      decoration:
                                      InputDecoration(hintText: "Amount"),
                                    ),

                                  ],
                                )),
                            title: Text('Add Cash Outflow'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text('Add'),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    double temp=double.parse(_amountcontroller.text);
                                    SQLiteDbProvider.db.insert(Trxn(0,f.format(DateTime.now()).split(" ")[0],_sourcecontroller.text,0,temp,acct.id)).then((value) {
                                      gettrxn();
                                      gettotal();
                                      _sourcecontroller.clear();
                                      _amountcontroller.clear();
                                      setState(() {});
                                    }
                                    );
                                    widget.showToast("Transaction Added");
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
                  if(snapshot.hasData && snapshot.data.length>0){
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text(
                              'Date',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          )),
                          DataColumn(label: Text(
                              'Recipient',
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
                                      return Colors.white.withOpacity(0.3);; // Use default value for other states and odd rows.
                                    }),
                                cells: [
                                  DataCell(Center(
                                      child: Text(snapshot.data[index].date,style: const TextStyle(fontSize: 16.0),))),
                                  DataCell(Center(
                                      child: Text(snapshot.data[index].reason,style: const TextStyle(fontSize: 16.0),))),
                                  DataCell(Center(
                                      child: Text(snapshot.data[index].total.toString(),style: const TextStyle(fontSize: 16.0),))),
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
                                                  _amountupdatecontroller.text=snapshot.data[index].total.toString();
                                                  _sourceupdatecontroller.text=snapshot.data[index].reason;
                                                  return AlertDialog(
                                                    content: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              controller: _sourceupdatecontroller,
                                                              validator: (value) {
                                                                return value!.isNotEmpty ? null : "Enter Recipient";
                                                              },
                                                              decoration: InputDecoration(hintText: "Recipient"),
                                                            ),
                                                            TextFormField(
                                                              controller: _amountupdatecontroller,
                                                              inputFormatters: [_amountValidator],
                                                              keyboardType: const TextInputType.numberWithOptions(
                                                                decimal: true,
                                                                signed: false,
                                                              ),
                                                              validator: (value) {
                                                                return value!.isNotEmpty ? null : "Enter amount";
                                                              },
                                                              decoration: InputDecoration(hintText: "Amount"),
                                                            ),

                                                          ],
                                                        )
                                                    ),
                                                    title: Text('Update Cash Outflow'),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        child: Text('Done'),
                                                        onPressed: () {
                                                          if (_formKey.currentState!.validate()) {
                                                            double temp=double.parse(_amountupdatecontroller.text);
                                                            SQLiteDbProvider.db.update(Trxn(snapshot.data[index].id,snapshot.data[index].date,_sourceupdatecontroller.text,0,temp,snapshot.data[index].title)).then((value) {
                                                              _sourceupdatecontroller.clear();
                                                              _amountupdatecontroller.clear();
                                                              gettrxn();
                                                              gettotal();
                                                              setState(() {});
                                                            }
                                                            );
                                                            widget.showToast("Transaction Updated");
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
                                          showDialog(context: context, builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Confirm Delete"),
                                              content: const Text("Do you want to delete this Account"),
                                              actions: [
                                                ElevatedButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () {
                                                    SQLiteDbProvider.db.delete(snapshot.data[index].id).then((value) {
                                                      gettotal();
                                                      gettrxn();
                                                      setState(() {});
                                                    });
                                                    widget.showToast("Transaction Deleted");
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
                    return Stack(
                        alignment: Alignment.center,
                        children: const [
                          SizedBox(height: 350.0),
                          Text("Add a new transaction",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500)),]
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            width: double.maxFinite,
            color: Colors.blueAccent,
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Total : ",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600,color: Colors.white),),
                Text(double.parse(total.toStringAsFixed(2)).toString(),style: const TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600,color: Colors.white),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
