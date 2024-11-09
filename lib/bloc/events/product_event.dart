// lib/bloc/events/product_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateProductEvent extends ProductEvent {
  final String name;
  final String? description;
  final String? country;
  final String? type;
  final double brutto;
  final double netto;
  final File? photo;

  CreateProductEvent({
    required this.name,
    this.description,
    this.country,
    this.type,
    required this.brutto,
    required this.netto,
    this.photo,
  });

  @override
  List<Object?> get props => [name, description, country, type, brutto, netto, photo];
}
