import json

def main():
    with open('assets/data/real_data.json', 'r', encoding='utf-8') as f:
        raw_json_str = f.read()

    dart_code = f"""import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:readpack/models/book.dart';

class BookRepository {{
  static List<Book> getInitialBooks() {{
    return fromJsonString(_rawBooksJson);
  }}

  static List<Book> fromJsonString(String jsonStr) {{
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) => Book.fromJson(item as Map<String, dynamic>)).toList();
  }}

  static Future<List<Book>> loadFromAssets() async {{
    final str = await rootBundle.loadString('assets/data/real_data.json');
    return fromJsonString(str);
  }}

  static const String _rawBooksJson = r'''{raw_json_str}''';
}}
"""
    with open('lib/data/book_repository.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)

    print("Successfully generated lib/data/book_repository.dart from assets/data/real_data.json")

if __name__ == '__main__':
    main()
