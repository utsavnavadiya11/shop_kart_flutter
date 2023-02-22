import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token = '';
  DateTime? _expiryDate = DateTime.now();
  String? _userId = '';
  final Timer _authTimer = Timer(const Duration(seconds: 5), () {});

  bool get isAuth {
    return token.isNotEmpty;
  }

  String get token {
    if (_token!.isNotEmpty &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _expiryDate != null) {
      return _token!;
    }
    return '';
  }

  String get userId {
    return _userId!;
  }

  Future<void> _authenticate(BuildContext context, String email,
      String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=YourApiKey');
    try {
      final response = await http.post(url,
          body: json.encode(
            {
              'email': email,
              'password': password,
              'returnSecureToken': true,
            },
          ));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
      autoLogout(context);
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String()
      });
      prefs.setString('userData', userData);
    } on HttpException catch (_) {
      rethrow;
    } catch (error) {
      //
    }
  }

  Future<void> signUp(
      BuildContext context, String email, String password) async {
    return _authenticate(context, email, password, 'signUp');
  }

  Future<void> logIn(
      BuildContext context, String email, String password) async {
    return _authenticate(context, email, password, 'signInWithPassword');
  }

  void logout(BuildContext context) async {
    if (_authTimer.isActive) {
      _authTimer.cancel();
    }
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void autoLogout(BuildContext context) {
    if (_authTimer.isActive) {
      _authTimer.cancel();
    }
    final remainingTime = _expiryDate!.difference((DateTime.now())).inSeconds;
    Timer(Duration(seconds: remainingTime), () => logout(context));
  }

  Future<bool> autoLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout(context);
    return true;
  }
}
