import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home()
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Album> _futureAlbum;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: FutureBuilder<Album>(
          future: _futureAlbum,
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              if(snapshot.hasData){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.data!.title ?? 'deleted'),
                    ElevatedButton(onPressed: (){
                      setState(() {
                        _futureAlbum = deleteAlbum(snapshot.data!.id.toString());
                      });
                    }, child: Text("Delete Data")
                    )
                  ],
                );
              }
              else if(snapshot.hasError){
                return Text("${snapshot.error}");
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
Future<Album> deleteAlbum(String id)async{
  final response = await http.delete(
    Uri.parse("https://jsonplaceholder.typicode.com/albums/1"),
    headers: <String,String>{
      'Content-Type': 'application/json; charset=UTF-8'
    }
  ); 
  if(response.statusCode == 200){
    return Album.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to delete');
  }
}
Future<Album> fetchAlbum()async{
  final response = await http.get(
    Uri.parse("https://jsonplaceholder.typicode.com/albums/1")
  );
  if(response.statusCode == 200 ){
    return Album.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to load album');
  }
}

class Album {
  final int? id;
  final String? title;

  Album({this.id, this.title});

  factory Album.fromJson(Map<String,dynamic> json){
    return Album(
    id: json['id'],
    title: json['title']
    );
  }
}

