import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String backendUrl = 'http://localhost:3050'; // Remplacez par l'URL de votre serveur

  // Fonction pour envoyer une requête de connexion au backend
  Future<String?> login(String email, String password) async {
    final url = '$backendUrl/login'; // Endpoint de connexion

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Retourne le token JWT
    } else if (response.statusCode == 401) {
      throw Exception('Email ou mot de passe invalide');
    } else {
      throw Exception('Erreur serveur');
    }
  }

  // Fonction pour envoyer une requête d'enregistrement au backend
  Future<bool> register(String email, String password) async {
    final url = '$backendUrl/register'; // Endpoint d'enregistrement

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      // Inscription réussie
      return true;
    } else if (response.statusCode == 400) {
      // Erreur (par exemple : email déjà existant)
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Échec de l\'inscription');
    } else {
      // Autre erreur serveur
      throw Exception('Erreur serveur');
    }
  }
}

