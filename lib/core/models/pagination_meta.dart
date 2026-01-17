import 'package:json_annotation/json_annotation.dart';

part 'pagination_meta.g.dart';

@JsonSerializable()
class PaginationMeta {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
