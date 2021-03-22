import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownPage extends StatelessWidget {
  final String title;
  final String file;

  const MarkdownPage({
    Key? key,
    required this.title,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder(
          future: rootBundle.loadString(file),
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                selectable: true,
                data: snapshot.data!,
                onTapLink: (text, href, title) async {
                  if (href == null) return;
                  if (await canLaunch(href)) {
                    await launch(href);
                  }
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
