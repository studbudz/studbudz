import 'package:flutter/material.dart';
import 'package:studubdz/Engine/auth_manager.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/notifier.dart';
import 'http_request_handler.dart';

class Engine {
  AuthManager _authManager = AuthManager();
  late final Controller _controller;
  late final HttpRequestHandler _httpHandler;

  // Constructor ensures HttpRequestHandler is initialized upon Engine instantiation
  Engine() {
    _httpHandler = HttpRequestHandler(
        address: 'https://192.168.1.107:8080', authManager: _authManager);
    print('HttpHandler initialized: $_httpHandler');
  }

  void setController(Controller controller) {
    _controller = controller;
    print('Controller set: $_controller');
  }

  Future<bool> logIn(String username, String password) async {
    print("Logging in.");

    try {
      bool response = await _httpHandler.signInRequest(username, password);
      if (response) {
        print("Success!");
        return true;
      } else {
        print("Login failed.");
        return false;
      }
    } catch (e) {
      print("Login failed.");
      return false;
    }
  }
}
