import 'package:flutter/material.dart';
import 'package:taxi_legal/controladores/indexController.dart';
import 'package:get/get.dart';

class MainAppBar extends AppBar{
  MainAppBar({super.key});

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar>{

  final IndexController ctrl = Get.find(); 

  @override
  Widget build(BuildContext context){
    return AppBar(
      title: Text("Táxi Legal - PG"),
      backgroundColor: Color.fromRGBO(23, 23, 109, 1),
      centerTitle: true,
    );
  }
}