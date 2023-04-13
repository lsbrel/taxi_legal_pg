import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_routes/google_maps_routes.dart';

class MainCardList extends StatefulWidget{

  @override
  State<MainCardList> createState() => _MainCardListState();
}

class _MainCardListState extends State<MainCardList>{

  double _userLat = 0;
  double _userLng = 0;
  List _pontosLivres = [];
  MapsRoutes route = new MapsRoutes();
  DistanceCalculator distanceCalculator = new DistanceCalculator();
  List<LatLng> totalDistance = [];
  
  @override
  void initState(){
    pegarPontosLivres();
    _getUserLocation().then((value){
      _userLat = value.latitude.toDouble();
      _userLng = value.longitude.toDouble();
    });
    super.initState();
  }

  Future<Position> _getUserLocation() async{
    // Se as poermissoes ja estiverem gatantidas
    if(await Geolocator.checkPermission() != LocationPermission.denied) return await Geolocator.getCurrentPosition();

    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async{
      await Geolocator.requestPermission();
      print('Errro');
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> pegarPontosLivres() async {
      final response = await http.get(Uri.parse('https://amttdetra.com/taxi/sistema_usuario/controller_pontos.php?case=todos'));
      final data = json.decode(response.body);
      setState(() {
        _pontosLivres = data;
      });
  }
  Future<void> _openExternalApp(url)async{
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: _pontosLivres.length,
      itemBuilder: (context, index){
        return Card(
          child: ListTile(
            leading: Icon(Icons.local_taxi, color: Color.fromRGBO(23, 23, 109, 1)),
            title: Text('${_pontosLivres[index]['nm_condutor']}'),
            subtitle: Text('Horario de saída: ${_pontosLivres[index]['horario_saida']}'),
            onTap: () => showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text('${_pontosLivres[index]['nm_condutor']}'),
                  content: Text('Local: ${_pontosLivres[index]['nome']}\nVeículo: ${_pontosLivres[index]['marca_veiculo']}'+
                ' ${_pontosLivres[index]['modelo_veiculo']} ${_pontosLivres[index]['cor_veiculo']}\nPlaca: ${_pontosLivres[index]['placa_veiculo']}'+'\nDistância: ${distanceCalculator.calculateRouteDistance(<LatLng>[
                  LatLng(_userLat, _userLng),
                  LatLng(double.parse(_pontosLivres[index]['lat']), double.parse(_pontosLivres[index]['lng']))
                ], decimals: 1)}'),
                  actions: [
                    MaterialButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: ()=>_openExternalApp('whatsapp://send?phone=+55${_pontosLivres[index]['telefone1_c']}'),
                      child: ListTile(
                        leading: Icon(Icons.phone),
                        title: Text("Entrar em contato"),
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      )
                    ),
                  ],
                );
              }
            ),
          )
        );
      }
    );
  }
}