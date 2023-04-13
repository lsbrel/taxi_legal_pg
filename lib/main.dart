import 'package:flutter/material.dart';
import 'package:get/get.dart';
// COMPONENTES
import 'package:taxi_legal/componentes/mainAppBar.dart';
import 'package:taxi_legal/componentes/mainDrawer.dart';
import 'package:taxi_legal/componentes/mainNavigationBar.dart';
import 'package:taxi_legal/componentes/mainTaxiMap.dart';
import 'package:taxi_legal/componentes/mainTaxistaMap.dart';
import 'package:taxi_legal/componentes/mainCardList.dart';
// CONTROLADORES
import 'package:taxi_legal/controladores/indexController.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Táxi Legal - PG',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  final controller = Get.put(IndexController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IndexController>(
      builder: (_){
        return Scaffold(
          appBar: MainAppBar(),
          drawer: MainDrawer(),
          body: Column(
              children: [
                if(_.indexPage == 0) Expanded(child: MainTaxiMap())
                else if(_.indexPage == 1) Expanded(child: MainCardList())
                else if(_.indexPage == 2) Expanded(child: MainTaxistaMap())
                else Text("ERROR")
              ]
          ),
          bottomNavigationBar: MainNavigationBar(),
        );
      }
    );
  }
}
