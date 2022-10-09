import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:webview/WebView/Login/Event.dart';

class LoginBloc {
  //To control all the events
  final _eventController = StreamController<Events>();
  Sink<Events> get eventSink => _eventController.sink;

  final loginController = StreamController<Map>.broadcast();
  Sink<Map> get loginSink => loginController.sink;
  Stream<Map> get loginStream => loginController.stream;

  final registerController = StreamController<Map>.broadcast();
  Sink<Map> get registerSink => registerController.sink;
  Stream<Map> get regsiterStream => registerController.stream;

  LoginBloc() {
    _eventController.stream.listen(_actions);
  }
  final _auth = FirebaseAuth.instance;
  String uid = '';
  Future _actions(Events event) async {
    if (event is RegisterEvent) {
      registerSink.add({
        'status': 'processing',
      });
      await registerUser(
          event.username, event.email, event.password, event.referalCode);
    }

    if (event is LoginEvent) {
      loginSink.add({
        'status': 'processing',
      });
      await login(event.email, event.password);
    }
  }

  Future registerUser(
      String name, String email, String password, String referralCode) async {
    try {
      final uid = await signup(email, password);
      final referCode = generateCode("refer");
      final referLink = await generateLink(referCode);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'uid': uid,
        'refer_link': referLink,
        'refer_code': referCode,
        'reward': 0
      });
      if (referralCode.isNotEmpty) {
        await rewardUser(uid, referralCode);
      }
      if (uid != null) {
        registerSink.add({
          'status': 'success',
        });
      }
    } catch (e) {
      registerSink.add({
        'status': 'failed',
      });
    }
  }

  Future<void> rewardUser(String? currentUserId, String referrerCode) async {
    try {
      final referer = await getreferrerUser(referrerCode);
      final checkUserAlreadyExist = await FirebaseFirestore.instance
          .collection("users")
          .doc(referer['uid'])
          .collection('referrers')
          .doc(currentUserId)
          .get();
      if (!checkUserAlreadyExist.exists) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(referer['uid'])
            .collection("referrers")
            .doc(currentUserId)
            .set({
          "uid": currentUserId,
          "createdAt": DateTime.now().toUtc().microsecondsSinceEpoch,
        });
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(referer['uid'])
          .update({"reward": FieldValue.increment(100)});
    } catch (e) {
      print(e);
    }
  }

  Future getreferrerUser(String referCode) async {
    final docSnapshots = await FirebaseFirestore.instance
        .collection("users")
        .where("refer_code", isEqualTo: referCode)
        .get();
    final user = docSnapshots.docs.first;
    if (user.exists) {
      return user.data();
    } else {
      return null;
    }
  }

  Future<String> generateLink(String referCode) async {
    var invitationLink = 'https://rayydeeplink.page.link/refer?code=$referCode';
    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse(invitationLink),
        uriPrefix: 'https://rayydeeplink.page.link',
        androidParameters: const AndroidParameters(
            packageName: "com.example.webview", minimumVersion: 20),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: "REFER A FRIEND AND EARN",
            description: "EARN RS 1000",
            imageUrl: Uri.parse(
                "https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")));
    var dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
  }

  Future<String?> signup(String email, String password) async {
    final currentUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = currentUser.user?.uid;
    return uid;
  }

  String generateCode(String prefix) {
    Random random = Random();
    var id = random.nextInt(92143543) + 0945123456;
    return '$prefix-${(id.toString().substring(0, 8))}';
  }

  Future login(String email, String password) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        DocumentSnapshot userSnapShot = await FirebaseFirestore.instance
            .collection("users")
            .doc(authResult.user?.uid)
            .get();
        if (userSnapShot.exists) {
          print(userSnapShot.data());
          loginSink.add({
            'status': 'success',
          });
        }
      }
    } catch (e) {
      loginSink.add({
        'status': 'failed',
      });
      print(e);
    }
  }
}
