# 👑 Gold Nightmare Pro v3.0

<div align="center">

![Gold Nightmare Pro](assets/images/icons/app_icon.png)

**Advanced Gold Trading Analysis Platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)]()

*تطبيق احترافي لتحليل الذهب باستخدام تقنيات الذكاء الاصطناعي*

[English](#english) | [العربية](#arabic)

</div>

---

## 📋 Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Architecture](#architecture)
- [Trading Engines](#trading-engines)
- [Configuration](#configuration)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

---

## ✨ Features

### 🎯 Core Features

- **🔮 Golden Nightmare Engine**: Advanced market analysis using liquidity zones, market structure, and momentum detection
- **⚡ Scalping Engine V2**: High-frequency trading signals with micro-trend analysis
- **📊 Swing Trading Engine V2**: Multi-timeframe analysis for position trading
- **🤖 AI-Powered Analysis**: Claude AI integration for intelligent trade recommendations
- **📈 Real-time Gold Prices**: Live XAU/USD pricing with historical data
- **🎨 Royal UI Theme**: Luxurious dark theme with gold accents and smooth animations

### 🛠️ Technical Features

- **Multi-Engine Architecture**: Three independent analysis engines working in harmony
- **Strictness Levels**: 5 configurable strictness modes (Conservative → Aggressive)
- **Smart Caching**: Optimized API calls with intelligent cache management
- **Auto-Refresh**: Configurable automatic data refresh intervals
- **Comprehensive Testing**: 60%+ unit, 50%+ widget, and 40%+ integration test coverage
- **CI/CD Pipeline**: Automated testing and deployment via GitHub Actions
- **Responsive Design**: Full support for mobile, tablet, and landscape modes

### 📊 Analysis Capabilities

- **Technical Indicators**: RSI, MACD, ATR, Moving Averages (20/50/100/200)
- **Market Structure**: Break of Structure (BOS) and Change of Character (CHOCH) detection
- **Supply & Demand Zones**: Automatic zone detection with strength analysis
- **Fibonacci Retracements**: Key levels for entry/exit planning
- **Risk Management**: Automated stop-loss and take-profit calculations
- **QCF Score**: Qualitative Confluence Factor for trade validation

---

## 🖼️ Screenshots

<div align="center">

| Home Screen | Analysis | Royal Analysis |
|------------|----------|----------------|
| ![Home](screenshots/home.png) | ![Analysis](screenshots/analysis.png) | ![Royal](screenshots/royal.png) |

| Settings | Charts | Trade History |
|----------|--------|---------------|
| ![Settings](screenshots/settings.png) | ![Charts](screenshots/charts.png) | ![History](screenshots/history.png) |

</div>

---

## 🚀 Installation

### Prerequisites

- Flutter SDK 3.16 or higher
- Dart 3.2 or higher
- Android Studio / VS Code with Flutter extensions
- API Keys:
  - Anthropic API (Claude AI)
  - GoldAPI.io

### Setup Steps

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/gold_nightmare_pro.git
cd gold_nightmare_pro
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure environment variables**

Create a `project.env` file in the root directory:

```env
ANTHROPIC_API_KEY=your_anthropic_key_here
GOLD_PRICE_API_KEY=your_goldapi_key_here
ENVIRONMENT=development
IS_PRODUCTION=false
ENABLE_LOGGING=true
ENABLE_ANALYTICS=false
```

4. **Generate code**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Run the app**

```bash
flutter run
```

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── app/                      # App configuration
│   ├── app.dart             # Main app widget
│   ├── routes.dart          # Navigation routes
│   └── theme.dart           # Theme configuration
├── core/                     # Core utilities
│   ├── config/              # Environment & API config
│   ├── constants/           # Constants & settings
│   ├── theme/               # UI theme & colors
│   └── utils/               # Helper utilities
├── features/                 # Feature modules
│   ├── analysis/            # Golden Nightmare analysis
│   ├── charts/              # Chart visualization
│   ├── home/                # Home dashboard
│   ├── royal_analysis/      # Royal (dual-engine) analysis
│   ├── settings/            # App settings
│   └── trade_history/       # Trade management
├── models/                   # Data models
├── services/                 # Business logic
│   ├── engines/             # Trading engines
│   └── golden_nightmare/    # Golden Nightmare components
└── widgets/                  # Reusable widgets
    └── animations/          # Animation widgets
```

### State Management

- **Riverpod**: Primary state management solution
- **Provider Pattern**: Clean separation of UI and business logic
- **State Notifiers**: For complex state with side effects

### Design Patterns

- **Repository Pattern**: Data layer abstraction
- **Strategy Pattern**: Multiple analysis engines
- **Observer Pattern**: Real-time updates
- **Factory Pattern**: Model creation
- **Singleton Pattern**: Service instances

---

## 🎯 Trading Engines

### 1. Golden Nightmare Engine

The flagship analysis engine combining multiple advanced techniques:

- **Liquidity Detection**: Identifies liquidity pools and sweep points
- **Market Structure**: BOS/CHOCH detection for trend confirmation
- **Momentum Analysis**: Multi-timeframe momentum scoring
- **Zone Detection**: Supply/demand zones with strength calculation
- **Smart Confluence**: QCF scoring system for trade validation

**Use Case**: Medium to long-term position trading with high confidence

### 2. Scalping Engine V2

Optimized for short-term trading:

- **Micro-Trend Analysis**: Fast trend detection on 1m-15m timeframes
- **RSI Zones**: Overbought/oversold detection
- **MACD Signals**: Quick momentum changes
- **ATR-Based Stops**: Dynamic stop-loss calculation
- **Quick Entries**: Rapid signal generation

**Use Case**: Day trading and scalping (1-15 minute timeframes)

### 3. Swing Engine V2

For position traders:

- **Multi-Timeframe Analysis**: 4H-Daily trend confirmation
- **MA Alignment**: 20/50/100/200 MA confluence
- **Fibonacci Levels**: Key retracement zones
- **Divergence Detection**: RSI/Price divergences
- **Structure Breaks**: Major support/resistance breaks

**Use Case**: Swing trading (1-7 day holds)

---

## ⚙️ Configuration

### Strictness Levels

Control analysis precision and signal frequency:

- **🛡️ Conservative**: Highest confidence, fewer signals
- **⚖️ Moderate**: Balanced approach
- **🎯 Balanced**: Optimal risk/reward
- **⚡ Aggressive**: More signals, accept higher risk
- **🔥 Strict**: Maximum signal frequency

### Auto-Refresh Settings

Configure automatic data updates:

- Default: 60 seconds
- Range: 30-300 seconds
- Battery-saving mode: Available

### Notifications

- Trade signals
- Price alerts
- Analysis updates
- Sound & vibration options

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Unit Tests

```bash
flutter test test/unit/
```

### Widget Tests

```bash
flutter test test/widget/
```

### Integration Tests

```bash
flutter test test/integration/
```

### Coverage Report

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Current Coverage**:
- Unit Tests: 60%+
- Widget Tests: 50%+
- Integration Tests: 40%+

---

## 🔧 Build & Deployment

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

---

## 📖 Documentation

### Code Documentation

All major classes and methods include comprehensive Dart Doc comments:

```dart
/// Analyzes gold price and generates trading signals
/// 
/// This method uses the Golden Nightmare engine to perform
/// multi-factor analysis including liquidity, structure, and momentum.
/// 
/// Returns [GoldenNightmareSignal] with entry, SL, TP levels
Future<GoldenNightmareSignal> analyze(List<Candle> candles);
```

### Additional Resources

- [Architecture Guide](docs/ARCHITECTURE.md)
- [API Documentation](docs/API.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 👥 Team

**Lead Developer**: [Your Name]  
**AI Integration**: Claude AI (Anthropic)  
**Design**: Royal Theme System

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/gold_nightmare_pro/issues)
- **Email**: support@goldnightmarepro.com
- **Discord**: [Join our community](https://discord.gg/goldnightmare)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Anthropic for Claude AI API
- GoldAPI.io for real-time gold prices
- The open-source community

---

<div align="center">

**⚠️ Trading Disclaimer**

*This application is for educational and informational purposes only. Trading gold and other financial instruments carries risk. Past performance does not guarantee future results. Always conduct your own research and consult with licensed financial advisors before making trading decisions.*

---

Made with ❤️ and ☕ by the Gold Nightmare Pro Team

⭐ **Star this repo if you find it useful!** ⭐

</div>
