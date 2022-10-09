import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview/WebView/Helper/Helper.dart';
import 'package:webview/WebView/Login/Event.dart';
import 'package:webview/WebView/Login/Login.dart';
import 'package:webview/WebView/Login/LoginBloc.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final loginBloc = LoginBloc();
  bool isSuccess = false;
  String? referralCode;

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    dynamicLinks.onLink.listen((dynamicLinkData) {
      handleDeepLink(dynamicLinkData);
    }).onError((error) {
      print(error.message);
    });
  }

  Future<void> handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data.link;
    var isRefer = deepLink.hasQuery;
    if (isRefer) {
      var code = deepLink.queryParameters['refer'];
      if (code != null) {
        referralCode = code;
      }
    }
  }

  @override
  void initState() {
    setState(() {
      initDynamicLinks();
    });
    super.initState();
  }

  bool status = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFd1c9f3),
        body: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 100),
              child: Container(
                height: MediaQuery.of(context).size.height * .5,
                width: MediaQuery.of(context).size.width * .9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextFormField(
                          controller: _username,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Username',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: StreamBuilder<Map>(
                                stream: loginBloc.regsiterStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!['status'] ==
                                          'processing') {
                                    isSuccess = true;
                                    status = false;
                                  } else if (snapshot.hasData &&
                                      snapshot.data!['status'] == 'failed' &&
                                      !status) {
                                    isSuccess = false;
                                    WidgetsBinding.instance
                                        ?.addPostFrameCallback((_) {
                                      Helper.alertDialogWithCloseBtn(
                                          context,
                                          "Error!",
                                          "email already exists or password must be more then 6 character");
                                    });
                                    status = true;
                                  } else if (snapshot.hasData &&
                                      snapshot.data!['status'] == 'success' &&
                                      !status) {
                                    WidgetsBinding.instance
                                        ?.addPostFrameCallback((_) {
                                      Helper.alertDialogWithCloseBtn(
                                          context,
                                          "Error!",
                                          "User successfully registered");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()));
                                    });
                                    status = true;
                                  }
                                  return ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        loginBloc.eventSink.add(RegisterEvent(
                                            _username.text,
                                            _email.text,
                                            _password.text,
                                            referralCode ?? ''));
                                      }
                                    },
                                    child: isSuccess
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Register'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(100, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // <-- Radius
                                      ),
                                    ),
                                  );
                                })),
                      ]),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()),
                                );
                              },
                              child: const Text('Login'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // <-- Radius
                                ),
                              ),
                            )),
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
