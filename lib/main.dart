import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:example/collection/isar_config.dart';
import 'package:example/collection/schema/album/album.schema.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Album>? albums;
  Future<List<Album>?> _makeApiCall() async {
    try {
      if (IsarConfig().read() != null) {
        var isar = await IsarConfig().create();

        var albumForDB = await isar?.albumDBs.where().findAll();

        return albumForDB
            ?.map((e) => Album.fromJson({
                  'id': e.id,
                  'title': e.title,
                  'userId': e.userId,
                }))
            .toList();
      }
      var res = await Dio()
          .get<List<dynamic>>('https://jsonplaceholder.typicode.com/albums');

      if (res.statusCode == 200) {
        albums = res.data?.map((e) => Album.fromJson(e)).toList();
        writeToDB(albums);
        return albums;
      }
    } catch (e) {
      print(e);
    }
  }

  createAndRunIsolate() {
    try {
      Isolate.spawn((message) {}, []);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: _makeApiCall(),
          initialData: albums,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: ((context, index) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.8),
                        child: Text(snapshot.data![index].id.toString()),
                      ),
                      subtitle: Text(snapshot.data![index].title),
                      title: Text(
                        'User ${snapshot.data![index].userId}',
                      ),
                    )),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _makeApiCall,
      //   tooltip: 'Api call',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  void writeToDB(List<Album>? albums) async {
    Isar? isar = await IsarConfig().create();
    albums?.forEach(
      (e) {
        isar?.writeTxn(
          () {
            AlbumDB albumDB = AlbumDB();
            albumDB.id = e.id;
            albumDB.userId = e.userId;
            albumDB.title = e.title;

            isar.albumDBs.put(albumDB);

            return Future.value();
          },
        );
      },
    );
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
