import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview/const.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? appWebViewController;
  PullToRefreshController? pullToRefreshController;
  ConnectivityResult? result;
  StreamSubscription? subscription;
  bool isConnected = false;

  checkInternet() async {
    result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      isConnected = true;
    } else {
      isConnected = false;
      showDialogBox();
    }
    setState(() {});
  }

  showDialogBox() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("No internet"),
              content: Text("Please check your internet"),
              actions: [
                CupertinoButton(
                    child: Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onPressed: () async {
                      Navigator.pop(context);
                      checkInternet();
                    })
              ],
            ));
  }

  startSubscription() {
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      checkInternet();
    });
  }

  @override
  void initState() {
    pullToRefreshController = PullToRefreshController(
        onRefresh: () {
          appWebViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: mainColor, backgroundColor: Colors.white));
    startSubscription();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Expanded(
                    child: InAppWebView(
                  pullToRefreshController: pullToRefreshController,
                  onLoadStart:(controller, url){

                  },
                  onLoadStop: (controller, url) {
                    pullToRefreshController!.endRefreshing();

                  },
                  onWebViewCreated: (controller) =>
                      appWebViewController = controller,
                  initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),

                )),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
