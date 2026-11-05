import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:readpack/data/raw_data/raw_books_data_1.dart';
import 'package:readpack/data/raw_data/raw_books_data_2.dart';
import 'package:readpack/data/raw_data/raw_books_data_3.dart';
import 'package:readpack/data/raw_data/raw_books_data_4.dart';
import 'package:readpack/models/book.dart';

class BookRepository {
  static List<Book> getInitialBooks() {
    return fromJsonString(_rawBooksJson);
  }

  static List<Book> fromJsonString(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Book>> loadFromAssets() async {
    final str = await rootBundle.loadString('assets/data/real_data.json');
    return fromJsonString(str);
  }

  static const String _rawBooksJson =
      '[$rawBooksPart1,\n$rawBooksPart2,\n$rawBooksPart3,\n$rawBooksPart4]';
}
