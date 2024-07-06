import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String Name;
  final String Email;
  final String Password;

  const UserModel({
    required this.id,
    required this.Email,
    required this.Name,
    required this.Password
  });

  toJson(){
    return {
      "Name": Name,
      "Email": Email,
      "Password": Password,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data()!;
    return UserModel(
        id: document.id,
        Email: data["Email"],
        Name: data["Name"],
        Password: data["Password"]);
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is UserModel &&
    runtimeType == other.runtimeType &&
    Name == other.Name &&
    Email == other.Email &&
    Password == other.Password &&
    id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode ^ Name.hashCode ^ Email.hashCode ^ Password.hashCode;
}