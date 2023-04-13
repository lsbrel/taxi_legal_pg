import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> pegarPontosLivres() async {
  final response = await http.get(Uri.parse('https://amttdetra.com/taxi/sistema_usuario/controller_pontos.php?case=todos'));
  final data = json.decode(response.body);
  return data;
}