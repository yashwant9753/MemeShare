import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Country {
  final bool capital;
  final String country;
  final String name;
  final int population;
  List regions;
  var state;

  Country({
    this.capital,
    this.country,
    this.name,
    this.population,
    this.regions,
    this.state,
  });

  factory Country.fromDocument(DocumentSnapshot doc) {
    return Country(
      capital: doc['capital'],
      country: doc['country'],
      name: doc['name'],
      population: doc['population'],
      regions: doc['regions'],
      state: doc['state'],
    );
  }
}
