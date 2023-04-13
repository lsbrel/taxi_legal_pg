import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Controlador
import 'package:taxi_legal/controladores/indexController.dart';

class MainNavigationBar extends StatefulWidget{
  const MainNavigationBar({super.key});

  @override
  State<MainNavigationBar> createState()=> _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar>{

  final IndexController ctrl = Get.find();
  // final controller = Get.put(IndexController());


  int _navigationIndex = 0;

  @override
  Widget build(BuildContext context){
    return BottomNavigationBar(
      currentIndex: ctrl.indexPage,
      onTap: (value) => setState(() {
        ctrl.changeIndexPage(value);
      }),
      selectedItemColor: Color.fromRGBO(23, 23, 109, 1),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Lista de Taxistas'
        ),
        if(ctrl.isLogged() == true) BottomNavigationBarItem(
          icon: Icon(Icons.local_taxi),
          label: 'Área de Taxistas'
        )
      ],
    );
  }
}