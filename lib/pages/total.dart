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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Summary",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0),),
        Column(
          children: [
            Text("Inflow : "+ widget.acct.tgain.toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0),),
            SizedBox(height: 15.0,),
            Text("Outflow : "+ widget.acct.tspend.toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0),),
          ],
        ),
        Container(
          width: double.maxFinite,
          color: Colors.grey,
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: Text("Total : "+(widget.acct.tgain-widget.acct.tspend).toString(),style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600),),
          ),
        )
      ],
    );
  }
}
