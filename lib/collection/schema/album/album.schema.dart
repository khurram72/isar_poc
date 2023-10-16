import 'package:isar/isar.dart';
part 'album.schema.g.dart';

@collection
class AlbumDB {
  Id isarId = Isar.autoIncrement;

  @Index(type: IndexType.value)
  int? id;
  int? userId;
  String? title;
}
