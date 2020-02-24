import 'package:buscador_gifs/ul/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _busca;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_busca == null || _busca.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=MkK43E6EuU75bDUBmTzLp4zog6cOWBGg&limit=20&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=MkK43E6EuU75bDUBmTzLp4zog6cOWBGg&q=$_busca&limit=19&offset=$_offset&rating=G&lang=pt");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
                labelText: "Pesquisar",
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            onSubmitted: (text){
              setState(() {
                _busca = text;
                _offset = 0;
              });
            },
          ),
        ),
        Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if(snapshot.hasError) return Container();
                      else return _tabelasDeGifs(context, snapshot);
                  }
                }))
      ]),
    );
  }

  int _itemCount(List data){
    if(_busca == null)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _tabelasDeGifs(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
        ), 
      itemCount: _itemCount(snapshot.data["data"]),
      itemBuilder: (context, index){
        if(_busca == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])) 
              );
            },
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
            else
              return Container(
                child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.white, size: 70.0,)
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      _offset += 19;
                    });
                  },
                ),
              );

      }
      
      );
  }

}