import 'package:accounts_book/helper/decimal_input.dart';
import 'package:accounts_book/models/acct_class.dart';
import 'package:accounts_book/models/trxn_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database.dart';

class AddTrxn extends StatefulWidget {
  final Acct acct;
  final Function(String toastmsg) showToast;
  const AddTrxn({Key? key,required this.acct,required this.showToast}) : super(key: key);

  @override
  _AddTrxnState createState() => _AddTrxnState();
}

class _AddTrxnState extends State<AddTrxn> {
  int? selectedValue = null;
  final _dropdownFormKey = GlobalKey<FormState>();
  final TextEditingController _amountcontroller = TextEditingController();
  final TextEditingController _sourcecontroller = TextEditingController();
  final _amountValidator = RegExInputFormatter.withRegex('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');
  final f = DateFormat('dd-MM-yy');
  List<DropdownMenuItem<int>> get dropdownItems{
    List<DropdownMenuItem<int>> menuItems = [
      const DropdownMenuItem(child: Text("Income"),value: 1),
      DropdownMenuItem(child: Container(child: Text("Expenditure")),value: 0),
    ];
    return menuItems;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Column(
        children: [
          const Center(child: Padding(
            padding: EdgeInsets.fromLTRB(0.0,30.0,0,0),
            child: Text("Add Transaction",style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.w600),),
          )),
          Expanded(
            child: Center(
              child: Form(
                  key: _dropdownFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250.0,
                        child: TextFormField(
                          controller: _sourcecontroller,
                          validator: (value) {
                            return value!.isNotEmpty ? null : "Enter Source / Recipient";
                          },
                          decoration: InputDecoration(
                            label: const Text("Source / Recipient"),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0,),
                      Container(
                        width: 250.0,
                        child: TextFormField(
                          controller: _amountcontroller,
                          inputFormatters: [_amountValidator],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          validator: (value) {
                            return value!.isNotEmpty ? null : "Enter amount";
                          },
                          decoration: InputDecoration(
                            label: const Text("Amount"),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0,),
                      Container(
                        width: 250.0,
                        child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            validator: (value) => value==null ? "Select Debit or Credit" : null,
                            dropdownColor: Colors.grey[400],
                            hint: const Text("Select"),
                            value: selectedValue,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                            items: dropdownItems),
                      ),
                      SizedBox(height: 15.0,),
                      ElevatedButton(
                          onPressed: () {
                            if (_dropdownFormKey.currentState!.validate()) {
                              double temp=double.parse(_amountcontroller.text);
                              SQLiteDbProvider.db.insert(Trxn(0,f.format(DateTime.now()).split(" ")[0],_sourcecontroller.text,selectedValue!,temp,widget.acct.id)).then((value) {
                                _sourcecontroller.clear();
                                _amountcontroller.clear();
                                setState(() {selectedValue=null;});
                                widget.showToast("Transaction Added");
                              }
                              );
                            }
                          },
                          child: Text("Add"))
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
