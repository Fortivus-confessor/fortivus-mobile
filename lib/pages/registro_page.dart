import '../model/registro.dart';

class RegistroPage {
  final List<Registro> content;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  RegistroPage({
    required this.content,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory RegistroPage.fromJson(Map<String, dynamic> json) {
    return RegistroPage(
      content: (json['content'] as List)
          .map((item) => Registro.fromJson(item))
          .toList(),
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
    );
  }
}
