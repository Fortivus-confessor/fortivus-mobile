import 'package:fortivus_app/model/despacho.dart' as model;

class RegistroPage {
  final List<model.Despacho> content;
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
          .map((item) => model.Despacho.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['number'] as int? ?? json['currentPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems:
          json['totalElements'] as int? ?? json['totalItems'] as int? ?? 0,
    );
  }
}
