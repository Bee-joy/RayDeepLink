import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class Referralpage extends StatefulWidget {
  String dynamicLink;
  Referralpage(this.dynamicLink, {Key? key}) : super(key: key);

  @override
  State<Referralpage> createState() => _ReferralpageState();
}

class _ReferralpageState extends State<Referralpage> {
  String dyanmicLink = '';
  void generateLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://rayydeeplink.page.link/test"),
      uriPrefix: "https://rayydeeplink.page.link",
      androidParameters:
          const AndroidParameters(packageName: "com.example.webview"),
      iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
    );
    var dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    setState(() {
      dyanmicLink = dynamicLink.shortUrl.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      generateLink();
    });
  }

  Future<void> _share(image, text) async {
    try {
      FlutterShare.share(
        text: text,
        title: text,
        linkUrl: image,
      );
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          FlatButton(
            child: Row(
              children: const [
                Icon(
                  Icons.share,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                )
              ],
            ),
            onPressed: () {
              _share(widget.dynamicLink, "test");
            },
          ),
        ],
      )),
    );
  }
}
