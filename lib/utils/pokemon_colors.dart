import 'package:flutter/material.dart';

class PokemonColors {
  static Color getColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return Colors.green;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.amber;
      case 'poison':
        return Colors.purple;
      case 'bug':
        return Colors.lightGreen;
      case 'normal':
        return Colors.grey;
      case 'ground':
        return Colors.brown;
      case 'rock':
        return Colors.blueGrey;
      case 'psychic':
        return Colors.pink;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'fairy':
        return Colors.pinkAccent;
      case 'fighting':
        return Colors.deepOrange;
      case 'ghost':
        return Colors.deepPurple;
      case 'steel':
        return Colors.blueGrey;
      case 'dark':
        return Colors.black87;
      case 'flying':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}
