import 'package:example/collection/schema/album/album.schema.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarConfig {
  //crud operation of database is handled here

  Future<Isar?> create() async {
    Isar? isar = Isar.getInstance();
    if (isar != null) {
      return isar;
    } else {
      final dir = await getApplicationDocumentsDirectory();

      final isar = await Isar.open(
        [AlbumDBSchema],
        directory: dir.path,
      );
      return isar;
    }
  }

  Future<List<AlbumDB>?>? read() async {
    Isar? isar = await create();
    if (isar?.isOpen == true) {
      List<AlbumDB>? albumList = await isar?.albumDBs.where().findAll();
      return albumList;
    }
  }

  update() {}
  delete() {}
}
