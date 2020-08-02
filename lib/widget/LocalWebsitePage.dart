import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class LocalWebsitePage extends StatelessWidget {
  
  final String title;
  final String htmlFile;

  const LocalWebsitePage({Key key, this.title, this.htmlFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: rootBundle.loadString(htmlFile),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Html(
                  data: snapshot.data,
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
