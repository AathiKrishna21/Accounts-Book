import 'package:accounts_book/database.dart';
import 'package:accounts_book/models/acct_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Total extends StatefulWidget {
  final Acct acct;
  const Total({Key? key,required this.acct}) : super(key: key);

  @override
  _TotalState createState() => _TotalState();
}

class _TotalState extends State<Total> {
  double inflow=0.00,outflow=0.00;
  gettotal() async{
    var t=(await SQLiteDbProvider.db.gettotal(widget.acct.id, 1))[0]["total"];
    var s=(await SQLiteDbProvider.db.gettotal(widget.acct.id, 0))[0]["total"];
    setState(() {
      inflow= t ?? 0.00;
      outflow=s ?? 0.00;
    });
  }
  @override
  void initState() {
    super.initState();
    gettotal();
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text("Summary",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0),),
          SizedBox(height: 200.0,),
          Expanded(
            child: Column(
              children: [
                Text("Inflow : "+ inflow.toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0),),
                SizedBox(height: 30.0,),
                Text("Outflow : "+ outflow.toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0),),
              ],
            ),
          ),
          Container(
            width: double.maxFinite,
            color: Colors.grey,
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Text("Total : "+(inflow-outflow).toString(),style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600),),
            ),
          )
        ],
      ),
    );
  }
}
