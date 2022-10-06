import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class Referralpage extends StatefulWidget {
  const Referralpage({Key? key}) : super(key: key);

  @override
  State<Referralpage> createState() => _ReferralpageState();
}

class _ReferralpageState extends State<Referralpage> {
  String invitationUrl = '';
  void generateLink() async {
    final user = FirebaseAuth.instance.currentUser!;
    var uid = user.uid;
    var invitationLink = "https://rayydeeplink.page.link/refer?invitedby=$uid";

    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse(invitationLink),
        uriPrefix: "https://rayydeeplink.page.link",
        androidParameters: const AndroidParameters(
            packageName: "com.example.webview", minimumVersion: 20),
        iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: "REFER A FRIEND AND EARN",
            description: "EARN RS 1000",
            imageUrl: Uri.parse(
                "https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")));
    var dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    setState(() {
      invitationUrl = dynamicLink.shortUrl.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      generateLink();
    });
  }

  Future<void> _share(invitationLink, titleText, desc) async {
    try {
      FlutterShare.share(
        text: desc,
        title: titleText,
        linkUrl: invitationLink,
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
              _share(invitationUrl, "test",
                  "lets play use my rederrer link :$invitationUrl");
            },
          ),
        ],
      )),
    );
  }
}
