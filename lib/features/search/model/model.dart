import 'package:flutter/material.dart';

class Book {
  final String title;
  final String author;
  final double rating;
  final String? image;

  const Book({
    required this.title,
    required this.author,
    required this.rating,
    this.image,
  });
}