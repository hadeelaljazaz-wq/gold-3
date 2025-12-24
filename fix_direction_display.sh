#!/bin/bash
# 🔧 Fix Direction Display Script
# يصلح عرض "شراء/بيع" في كل الـ widgets

echo "🔧 Fixing direction display in all widgets..."

cd "$(dirname "$0")"

# 1. Fix royal_scalp_card.dart
echo "✅ Fixing royal_scalp_card.dart..."
sed -i "170s/direction/direction == 'BUY' ? 'شراء' : 'بيع'/" \
    lib/features/unified_analysis/widgets/royal_scalp_card.dart

# 2. Fix royal_swing_card.dart  
echo "✅ Fixing royal_swing_card.dart..."
sed -i "179s/direction/direction == 'BUY' ? 'شراء' : direction == 'SELL' ? 'بيع' : direction/" \
    lib/features/unified_analysis/widgets/royal_swing_card.dart

# 3. Fix advanced_scalp_card.dart
echo "✅ Fixing advanced_scalp_card.dart..."
sed -i "177s/direction/direction == 'BUY' ? 'شراء' : 'بيع'/" \
    lib/features/unified_analysis/widgets/advanced_scalp_card.dart

# 4. Fix kabous_master_engine.dart (stopActivation text)
echo "✅ Fixing kabous_master_engine.dart..."
sed -i "989s/فوق الستوب → بيع/تحت الستوب → بيع/; 989s/تحت الستوب → شراء/فوق الستوب → شراء/" \
    lib/services/kabous_master_engine.dart

echo ""
echo "🎉 Done! All files fixed!"
echo ""
echo "Test with: flutter run"
