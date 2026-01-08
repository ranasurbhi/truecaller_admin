import "package:flutter/material.dart";

class Butn extends StatelessWidget {
  final String textVal;
  final Function fun;
  const Butn({super.key,required this.textVal,required this.fun});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
    onPressed: ()=>fun,
    label: Text(textVal,style: TextStyle(color: Colors.white),),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ));
  }
}