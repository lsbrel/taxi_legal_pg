import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MainTaxiMap extends StatefulWidget{
  const MainTaxiMap({super.key});

  @override
  State<MainTaxiMap> createState() => _MainTaxiMapState();
}

class _MainTaxiMapState extends State<MainTaxiMap>{

  // Variaveis de controle
  double _userLat = 0;
  double _userLng = 0;
  List _pontosLivres = [];
  final List<Marker> _markers = <Marker>[];
  MapsRoutes route = new MapsRoutes();
  DistanceCalculator distanceCalculator = new DistanceCalculator();
  List<LatLng> totalDistance = [];


  @override
  void initState(){
    // Pegando pontos de taxi e associando eles com os pontos livres
    pegarPontosLivres().then((value) => criarMarkers());
    // Pegando a localizacao do usuario e assiciando as variaveis de controle de latidue e longitude
    _getUserLocation().then((value){
      _userLat = value.latitude.toDouble();
      _userLng = value.longitude.toDouble();
    });
    super.initState();
  } 


  // Pegando posicao do usuario
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

  // Pegando dados da api
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


  // Criando marcadores
  criarMarkers() async{
    for(int i=0 ;i<_pontosLivres.length; i++){
      _markers.add(
        Marker(
          markerId: MarkerId(_pontosLivres[i]['id_pontos'].toString()),
          position: LatLng(double.parse(_pontosLivres[i]['lat']),double.parse( _pontosLivres[i]['lng'])),
          icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () => newTraceRoute(double.parse(_pontosLivres[i]['lat']),double.parse( _pontosLivres[i]['lng'])),
          infoWindow: InfoWindow(
            title: 'Ver Mais',
            onTap: () => showDialog(context: context, builder: (context){
              return AlertDialog(
                actions: [
                  Center(
                    child: MaterialButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: ()=>_openExternalApp('whatsapp://send?phone=+55${_pontosLivres[i]['telefone1_c']}'),
                      child: ListTile(
                        leading: Icon(Icons.phone),
                        title: Text("Entrar em contato"),
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      )
                    ),
                  )
                ],
                title: Text('${_pontosLivres[i]['nome']}'),
                content: Text('Condutor: ${_pontosLivres[i]['nm_condutor']}\nVeículo: ${_pontosLivres[i]['marca_veiculo']}'+
                ' ${_pontosLivres[i]['modelo_veiculo']} ${_pontosLivres[i]['cor_veiculo']}\nPlaca: ${_pontosLivres[i]['placa_veiculo']}\nDistância: ${distanceCalculator.calculateRouteDistance(totalDistance, decimals: 1)}'),
              );
            }),
            )
        )
        );
        }
    }
    newTraceRoute(lat, lng) async {
      try{
        route.routes.clear();
      }catch(e){
        print('erro ao limpar rotas');
      }
      List<LatLng> _points = [
        LatLng(_userLat, _userLng),
        LatLng(lat, lng),
      ];
      await route.drawRoute(_points,'Rota', Colors.blueAccent, 'AIzaSyBILLmaUJWRv6-TrXZCiXR9GwLmOSxc0kw', travelMode: TravelModes.walking);
      // Atualiza a rota na tela
      setState(() {
        totalDistance = _points;
      });
    }

  @override
  Widget build(BuildContext){
    return GoogleMap(
        polylines: route.routes,
        markers: Set<Marker>.of(_markers),       
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onTap: (args)=>distanceCalculator.calculateRouteDistance(totalDistance),
        initialCameraPosition: CameraPosition(
          target: const LatLng(-25.098062, -50.154762),
          zoom: 13
        ),
    );
  }
}