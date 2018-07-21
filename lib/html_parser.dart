import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_video.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter_html_view/flutter_html_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class HtmlParser {
  HtmlParser();

  _parseChildren(dom.Element e, String p, widgetList) {
    print("new element in parent $p:\n$e");
    if (e.localName == "img" && e.attributes.containsKey('src')) {
      var src = e.attributes['src'];

      if (src.startsWith("http") || src.startsWith("https")) {
        widgetList.add(new CachedNetworkImage(
          placeholder: new Center(child: CircularProgressIndicator()),
          imageUrl: src,
          fit: BoxFit.cover,
        ));
      } else if (src.startsWith('data:image')) {
        var exp = new RegExp(r'data:.*;base64,');
        var base64Str = src.replaceAll(exp, '');
        var bytes = base64.decode(base64Str);

        widgetList.add(new Image.memory(bytes, fit: BoxFit.cover));
      }
    } else if (e.localName == "video" && e.attributes.containsKey('src')) {
      var src = e.attributes['src'];
      // var videoElements = e.getElementsByTagName("video");
      widgetList.add(
        new NetworkPlayerLifeCycle(
          src,
          (BuildContext context, VideoPlayerController controller) =>
              new AspectRatioVideo(controller),
        ),
      );
    } else if (!_isInsidePhrasingContent(e.localName, p)) {
      RegExp exp = new RegExp('(<img.*?>|<video.*></video>)');
      dom.Element n = parse(e.outerHtml.replaceAll(exp, '')).body.firstChild;
      if (n.hasContent()) {
        print('add element:\n ${n.outerHtml}');
        widgetList.add(new HtmlText(data: n.outerHtml));
      }
    }

    if (e.children.length > 0) {
      var p = e.localName;
      e.children.forEach((e) => _parseChildren(e, p, widgetList));
    }
  }

  List<Widget> HParse(String html) {
    List<Widget> widgetList = new List();

    dom.Document document = parse(html);

    dom.Element docBody = document.body;

    List<dom.Element> styleElements = docBody.getElementsByTagName("style");
    List<dom.Element> scriptElements = docBody.getElementsByTagName("script");
    if (styleElements.length > 0) {
      for (int i = 0; i < styleElements.length; i++) {
        docBody.getElementsByTagName("style").first.remove();
      }
    }
    if (scriptElements.length > 0) {
      for (int i = 0; i < scriptElements.length; i++) {
        docBody.getElementsByTagName("script").first.remove();
      }
    }

    List<dom.Element> docBodyChildren = docBody.children;
    if (docBodyChildren.length > 0)
      docBodyChildren.forEach((e) => _parseChildren(e, null, widgetList));

    return widgetList;
  }

  bool _isInsidePhrasingContent(element, parent) {
    // https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Content_categories#Phrasing_content
    // img and video excluded
    List<String> elements = <String>[
      'abbr',
      'audio',
      'b',
      'bdo',
      'br',
      'button',
      'canvas',
      'cite',
      'code',
      'data',
      'datalist',
      'dfn',
      'em',
      'embed',
      'i',
      'iframe',
      'input',
      'kbd',
      'label',
      'mark',
      'math',
      'meter',
      'noscript',
      'object',
      'output',
      'progress',
      'q',
      'ruby',
      'samp',
      'script',
      'select',
      'small',
      'span',
      'strong',
      'sub',
      'sup',
      'svg',
      'textarea',
      'time',
      'var',
      'wbr',
      'a',
      'area',
      'del',
      'ins',
      'link',
      'map',
      'meta',
    ];
    List<String> parents = new List.from(elements)..add('p');
    if (elements.contains(element) && parents.contains(parent)) {
      return true;
    }
    // TODO: A few other elements belong to this category, but only if a specific condition is fulfilled:
    // <a>, if it contains only phrasing content
    // <area>, if it is a descendant of a <map> element
    // <del>, if it contains only phrasing content
    // <ins>, if it contains only phrasing content
    // <link>, if the itemprop attribute is present
    // <map>, if it contains only phrasing content
    // <meta>, if the itemprop attribute is present
    return false;
  }
}
