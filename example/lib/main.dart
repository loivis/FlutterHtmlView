import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String html = '''
<h1>This is &nbsp;heading 1</h1>
<h2>This is heading 2</h2>
<h3>This is heading 3</h3>
<h4>This is heading 4</h4>
<h5>This is heading 5</h5>
<h6>This is heading 6</h6>
<a data-link="1" href="https://flutter.io">flutter.io</a>
<p>
    leading plain text
    <strong>leading strong</strong>
    <img alt="Flutter Logo" src="https://flutter.io/images/flutter-mark-square-100.png"><span class="span">span text</span>
    <video src="https://flutter.github.io/assets-for-api-docs/videos/bee.mp4"></video>
    <i>trailing italic</i>
    tailing plain text
</p>
<p>
    <a href="https://google.com">Go Google</a>
    <a href="mailto:address@email.domain">Mail to me</a>
</p>
''';

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter Html View Example'),
        ),
        body: new SingleChildScrollView(
          child: new Center(
            child: new HtmlView(
              data: html,
            ),
          ),
        ),
      ),
    );
  }
}
