import 'package:flutter/cupertino.dart';

abstract class Events {}

class LoginEvent extends Events {
  String password;
  String email;
  LoginEvent(this.email, this.password);
}

class RegisterEvent extends Events {
  String username;
  String email;
  String password;
  String referalCode;
  RegisterEvent(this.username, this.email, this.password, this.referalCode);
}
