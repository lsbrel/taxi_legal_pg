import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';
import 'package:taxi_legal/controladores/indexController.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainDrawer extends StatefulWidget{
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState()=>_MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>{

  TextEditingController _cpf = TextEditingController(); 
  TextEditingController _placa = TextEditingController();
  final IndexController ctrl = Get.find(); 

  Future<void> _openExternalApp(url) async {
    launchUrl(Uri.parse(url));
  }


  void _validateLogin() async {
    final response = await http.post(Uri.parse('https://amttdetra.com/taxi/sistema_taxistas/android_login.php'),
      body: {
       'cpf': _cpf.text.toString(),
       'placa': _placa.text.toUpperCase().toString()
      }
    );
    final data = json.decode(response.body);
    // Caso de erro no login
    if( _placa.text.toUpperCase().toString().length < 1 || _cpf.text.toString().length < 1){
      Fluttertoast.showToast(
        msg: "Campos não podem estar vazios",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      return;
    }
    if(data == 'error'){
      Fluttertoast.showToast(
        msg: "Dados incorretos ou não regularizados",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      return;
    } 

    // Colocar dialog box
    Fluttertoast.showToast(
      msg: "Login realizado com sucesso",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
    );       
    setState(() {
      ctrl.changeIndexPage(2);
      ctrl.storeLogin(int.parse(data[0]['id_condutor']));
      Navigator.of(context).pop();
    });
  }

  void _realizarLogout(){
    Fluttertoast.showToast(
      msg: "Login realizado com sucesso",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
    );  
    setState(() {
      ctrl.changeIndexPage(0);
      ctrl.storeLogout();
    });
  }

  void _realizarLogin(){
    showDialog(context: context, builder: (context) => 
      AlertDialog(
        actions: [
          ListTile(
            iconColor: Colors.black,
            textColor: Colors.black,            
            leading: Icon(Icons.person),
            title: Text("CPF"),
          ),
          TextField(
            controller: _cpf,
            inputFormatters: [
              new MaskTextInputFormatter(
                mask: '000.000.000-00',
                filter: {
                  '0': RegExp(r'[0-9]'),
                },
                type: MaskAutoCompletionType.lazy
              )
            ],
          ),
          ListTile(
            iconColor: Colors.black,
            textColor: Colors.black,
            leading: Icon(Icons.local_taxi),
            title: Text("Placa"),
          ),
          TextField(
            controller: _placa,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              new MaskTextInputFormatter(
                mask: '###0!00',
                filter: {
                  '#': RegExp(r'[aA-zZ]'),
                  '!': RegExp(r'[aA0-zZ9]'),
                  '0': RegExp(r'[0-9]')
                },
                type: MaskAutoCompletionType.lazy
              )
            ],
          ),
          Divider(
            color: Color.fromRGBO(0, 0, 0, 0),
          ),
          Divider(
            color: Color.fromRGBO(0, 0, 0, 0),
          ),
          Center(
            child: MaterialButton(
              color: Color.fromRGBO(23, 23, 109, 1),
              textColor: Colors.white,
              onPressed: () => _validateLogin(),
              child: Text('Login'),
          ),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(23, 23, 109, 1)
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              ],
            )
          ),
          ListTile(
            leading: Icon(Icons.pageview_rounded),
            title: Text('Acesse o site '),
            onTap: () => _openExternalApp('https://transportes.pontagrossa.pr.gov.br/'),
          ),
          if(ctrl.isLogged() == true) ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: _realizarLogout
          )else ListTile(
            leading: Icon(Icons.login),
            title: Text('Entrar'),
            subtitle: Text('Acesso aos taxistas'),
            onTap: () => _realizarLogin(),
          ),
        ],
      ),
    );
  }
}