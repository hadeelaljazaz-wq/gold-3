import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../core/theme/royal_colors.dart';

/// 📊 TradingView Chart Widget
/// رسم بياني احترافي للذهب من TradingView
class TradingViewChart extends StatefulWidget {
  final String symbol;
  final String interval;
  
  const TradingViewChart({
    super.key,
    this.symbol = 'XAUUSD',
    this.interval = '15', // 15 minutes
  });

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getTradingViewUrl()));
  }

  String _getTradingViewUrl() {
    // TradingView Advanced Chart
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #0A0E1A;
      overflow: hidden;
    }
    #tradingview_widget {
      width: 100%;
      height: 100vh;
    }
  </style>
</head>
<body>
  <div class="tradingview-widget-container" id="tradingview_widget">
    <div id="tradingview_chart"></div>
  </div>

  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
    new TradingView.widget({
      "width": "100%",
      "height": "100%",
      "symbol": "OANDA:${widget.symbol}",
      "interval": "${widget.interval}",
      "timezone": "Etc/UTC",
      "theme": "dark",
      "style": "1",
      "locale": "ar_AE",
      "toolbar_bg": "#0A0E1A",
      "enable_publishing": false,
      "hide_top_toolbar": false,
      "hide_legend": false,
      "save_image": false,
      "container_id": "tradingview_chart",
      "studies": [
        "RSI@tv-basicstudies",
        "MACD@tv-basicstudies",
        "BB@tv-basicstudies"
      ],
      "backgroundColor": "#0A0E1A",
      "gridColor": "rgba(255, 255, 255, 0.06)",
      "overrides": {
        "mainSeriesProperties.candleStyle.upColor": "#00FF88",
        "mainSeriesProperties.candleStyle.downColor": "#FF3366",
        "mainSeriesProperties.candleStyle.borderUpColor": "#00FF88",
        "mainSeriesProperties.candleStyle.borderDownColor": "#FF3366",
        "mainSeriesProperties.candleStyle.wickUpColor": "#00FF88",
        "mainSeriesProperties.candleStyle.wickDownColor": "#FF3366"
      }
    });
  </script>
</body>
</html>
    ''';

    // Convert to data URL
    final bytes = utf8.encode(htmlContent);
    final base64 = base64Encode(bytes);
    return 'data:text/html;base64,$base64';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RoyalColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RoyalColors.royalGold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            if (_isLoading)
              Container(
                color: RoyalColors.background.withValues(alpha: 0.9),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(RoyalColors.royalGold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

