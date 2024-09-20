import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NgoModel {
  final String name;
  final String address;
  final String phone;

  NgoModel({required this.name, required this.address, required this.phone});

  // From Firestore Document Snapshot
  factory NgoModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NgoModel(
      name: data['Name'] ?? 'No Name',
      address: data['Address'] ?? 'No Address',
      phone: data['Phone number'] ?? 'No Phone',
    );
  }

  // To Firestore Map (Optional: for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
    };
  }
}
