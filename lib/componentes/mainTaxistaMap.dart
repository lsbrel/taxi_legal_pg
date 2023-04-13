import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:get/get.dart';
// Controladores
import 'package:taxi_legal/controladores/fetchDataController.dart';
import 'package:taxi_legal/controladores/indexController.dart';

class MainTaxistaMap extends StatefulWidget{
  const MainTaxistaMap({super.key});

  @override
  State<MainTaxistaMap> createState() => _MainTaxistaMapState();
}

class _MainTaxistaMapState extends State<MainTaxistaMap>{

  // Variaveis de controle
  List _pontosTaxis = [];
  final List<Marker> _markers = <Marker>[];
  List<LatLng> totalDistance = [];
  List _loggedData = [];
  bool _controllerFromTime = false;
  final IndexController ctrl = Get.find();
  final controller = Get.put(IndexController());


  @override
  void initState(){
    // Pegando pontos de taxi e associando eles com os pontos livres
    // print(ctrl.retId());
    if(_isValid(ctrl.retId()) == false){
      print('userr Logged');
    }else{
      pegarPontosTaxi().then((value) => criarMarkerTaxi());
    }
    // Pegando a localizacao do usuario e assiciando as variaveis de controle de latidue e longitude
    super.initState();
  }


  Future<bool> _isValid(int id_condutor) async{

    final response = await http.get(Uri.parse('http://amttdetra.com/taxi/sistema_taxistas/painel_ajax_controller.php?case=painel&id=${id_condutor}'));
    final data = json.decode(response.body);
    
    if(DateTime.parse(data[0]['horario_saida']).isAfter(DateTime.now())) {
      print("data");
      setState(() {
        _controllerFromTime = true;
      });
    };

  // print(ctrl.retId());

    setState(() {
      _loggedData = data;
    });
    if(data != []) return false;
    else return true;

  }

  // Pegando dados da api
  Future<void> pegarPontosTaxi() async {
      final response = await http.get(Uri.parse('https://amttdetra.com/taxi/sistema_taxistas/sistema_get_pontos.php?case=todos'));
      final data = json.decode(response.body);
      setState(() {
        _pontosTaxis = data;
      });
  }
  // Criando marcadores
  criarMarkerTaxi() async{
    for(int i=0 ;i<_pontosTaxis.length; i++){
      _markers.add(
        Marker(
          markerId: MarkerId(_pontosTaxis[i]['id_pontos'].toString()),
          position: LatLng(double.parse(_pontosTaxis[i]['lat']),double.parse( _pontosTaxis[i]['lng'])),
          icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Ver Mais',
            onTap: () => showDialog(context: context, builder: (context){
              return AlertDialog(
                actions: [
                Center(
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: ()=>_checkVaga(ctrl.retId(), _pontosTaxis[i]['id_pontos']),
                      child: ListTile(
                        leading: Icon(Icons.check),
                        title: Text('Check-In'),
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      )
                    ),
                  )
                ],
                title: Text('${_pontosTaxis[i]['nome']}'),
                content: Text('Endereço: ${_pontosTaxis[i]['endereco_pontos']}\n\nLargura: ${_pontosTaxis[i]['largura']}\n'+
                'Comprimento: ${_pontosTaxis[i]['comprimento']}'),
              );
            }),
            )
        )
        );
        }
    }

    void _checkVaga(id_condutor, id_ponto)async{
        final res = await http.get(Uri.parse('https://amttdetra.com/taxi/sistema_taxistas/sistema_get_pontos.php?case=check&id=${id_condutor}&ponto=${id_ponto}'));

        // Fazer Teste de if e else mas primeiro mudar o retrono da rota
        Fluttertoast.showToast(
          msg: "Check-In realizado",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
        );  
      
        setState(() {
          ctrl.changeIndexPage(0);
          Navigator.of(context).pop();
        });
    }

    void _sairVaga(String id) async {
      final res = await http.post(Uri.parse('https://amttdetra.com//taxi/sistema_taxistas/sistema_get_pontos.php?case=adm-out'),
        body: {
          'id': id
        }
      );
      Fluttertoast.showToast(
        msg: "Check-out Realizado",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      ); 
      setState(() {
        ctrl.changeIndexPage(0);
        Navigator.of(context).pop();
      });
    }


    void _renovarVaga(String id)async{
      final res = await http.post(Uri.parse('https://amttdetra.com/taxi/sistema_taxistas/sistema_get_pontos.php?case=rapp'),
        body: {
          'id' : id
        }
      );
      Fluttertoast.showToast(
        msg: "Ponto Renovado",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
      ); 
      setState(() {
        ctrl.changeIndexPage(0);
      });
    }



  @override
  Widget build(BuildContext){
    return _controllerFromTime == true ?
      Card(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromRGBO(23, 23, 109, 1),
              ),
              child: Text('${_loggedData[0]['nm_condutor']}',style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('${_loggedData[0]['nome']}'),
              subtitle: Text('Endereço'),
            ),
            ListTile(
              leading: Icon(Icons.lock_clock),
              title: Text('${_loggedData[0]['horario_entrada']}'),
              subtitle: Text('Entrada'),
            ),
            ListTile(
              leading: Icon(Icons.lock_clock),
              title: Text('${_loggedData[0]['horario_saida']}'),
              subtitle: Text('Saída'),
            ),
            ListTile(
              leading: Icon(Icons.local_taxi),
              title: Text('${_loggedData[0]['marca_veiculo']}'+
                ' ${_loggedData[0]['modelo_veiculo']} ${_loggedData[0]['cor_veiculo']}'),
              subtitle: Text('Carro'),
            ),
            ListTile(
              leading: Icon(Icons.car_crash_rounded),
              title: Text('${_loggedData[0]['placa_veiculo']}'),
              subtitle: Text('Placa'),
            ),
            Spacer(),
            MaterialButton(
                color: Colors.blue,
                minWidth: MediaQuery.of(context).size.width / 2,
                onPressed: ()=>_renovarVaga(_loggedData[0]['id_condutor']),
                child: Text("Renovar Ponto", style: TextStyle(color: Colors.white)),
            ),
            MaterialButton(
                color: Colors.red[600],
                minWidth: MediaQuery.of(context).size.width / 2,
                onPressed: ()=>_sairVaga(_loggedData[0]['id_pontos']),
                child: Text("Sair do Ponto", style: TextStyle(color: Colors.white)),
            )                                   
          ],
        ),
      )
      : GoogleMap(
        // polylines: route.routes,
        markers: Set<Marker>.of(_markers),       
        // myLocationButtonEnabled: true,
        // myLocationEnabled: true,
        // onTap: (args)=>distanceCalculator.calculateRouteDistance(totalDistance),
        initialCameraPosition: CameraPosition(
          target: const LatLng(-25.098062, -50.154762),
          zoom: 11
        ),
    );
  }
}