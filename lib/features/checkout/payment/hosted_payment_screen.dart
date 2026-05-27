import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HostedPaymentScreen extends StatefulWidget {
  final String hostedUrl;
  final String paymentToken;
  final String redirectScheme;

  const HostedPaymentScreen({
    super.key,
    required this.hostedUrl,
    required this.paymentToken,
    required this.redirectScheme,
  });

  @override
  State<HostedPaymentScreen> createState() => _HostedPaymentScreenState();
}

class _HostedPaymentScreenState extends State<HostedPaymentScreen> {
  bool _isLoading = true;
  double _progress = 0;

  String _buildFormHtml(String url, String token) {
  final encoded = Uri.encodeComponent(token);
  return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #fff; }
    #load_payment {
      width: 100%; height: 100vh;
      border: none; display: block;
    }
  </style>
</head>
<body>

  <!-- The form POSTs into the iframe, not the top-level page -->
  <form id="f" method="POST" action="$url"
        target="load_payment"
        enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="token" value="$encoded"/>
  </form>

  <iframe id="load_payment" name="load_payment"></iframe>

  <script>
    // CommunicationHandler — Auth.net calls this via the communicator iframe
    var CommunicationHandler = {};
    CommunicationHandler.onReceiveCommunication = function(argument) {
      var params = parseQueryString(argument.qstr);
      switch(params['action']) {
        case 'resizeWindow':
          document.getElementById('load_payment').style.height =
            parseInt(params['height']) + 'px';
          break;
        case 'successfulSave':
          break;
        case 'cancel':
          // Tell Flutter the user cancelled
          window.flutter_inappwebview.callHandler('onPaymentEvent', 'cancel');
          break;
        case 'transactResponse':
          // Payment complete — pass the response JSON to Flutter
          window.flutter_inappwebview.callHandler(
            'onPaymentEvent',
            params['response']
          );
          break;
      }
    };

    function parseQueryString(str) {
      var vars = {};
      var pairs = str.split('&');
      for (var i = 0; i < pairs.length; i++) {
        var pair = pairs[i].split('=');
        vars[decodeURIComponent(pair[0])] =
          decodeURIComponent(pair[1] || '');
      }
      return vars;
    }

    // Submit the form into the iframe
    document.getElementById('f').submit();
  </script>
</body>
</html>''';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Secure Checkout',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, 'cancelled'),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
  initialData: InAppWebViewInitialData(
    data: _buildFormHtml(widget.hostedUrl, widget.paymentToken),
    mimeType: 'text/html',
    encoding: 'utf-8',
  ),
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
  ),
  onWebViewCreated: (controller) {
    // Register the handler that Auth.net's communicator calls back into
    controller.addJavaScriptHandler(
      handlerName: 'onPaymentEvent',
      callback: (args) {
        final event = args.isNotEmpty ? args[0].toString() : '';
        debugPrint('💳 PAYMENT EVENT: $event');
        if (event == 'cancel') {
          Navigator.pop(context, 'cancelled');
        } else {
          // event is the transactResponse JSON string
          Navigator.pop(context, event);
        }
      },
    );
  },
  onConsoleMessage: (controller, msg) {
    debugPrint('🌐 WEBVIEW [${msg.messageLevel}]: ${msg.message}');
  },
  onLoadStop: (controller, url) {
    debugPrint('🟢 LOAD STOP: $url');
    if (mounted) setState(() => _isLoading = false);
  },
  onLoadError: (controller, url, code, message) {
    debugPrint('🔴 LOAD ERROR $code: $message @ $url');
  },
),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                value: _progress < 0.1 ? null : _progress,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}