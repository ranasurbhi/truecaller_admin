import "package:flutter/material.dart";

class ButtonWIcon extends StatelessWidget {
  final String textVal;
  final IconData iconVal;

  const ButtonWIcon({super.key,required this.textVal, required this.iconVal});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
    onPressed: () {},
    icon:  Icon(iconVal, size: 18,color: Colors.white,),
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