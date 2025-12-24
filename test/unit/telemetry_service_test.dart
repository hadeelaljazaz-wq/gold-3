import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/telemetry_service.dart';

void main() {
  test('telemetry records signals and outcomes', () {
    final t = TelemetryService.instance;

    // Reset internal fields (for test isolation)
    t.totalSignals = 0;
    t.filteredSignals = 0;
    t.totalOutcomes = 0;
    t.totalPnl = 0.0;

    t.recordSignalGenerated('scalping', 'royal', 0.75);
    t.recordSignalFiltered('scalping', 'royal', 0.25, 0.4);
    t.recordSignalOutcome('scalping', 12.5);

    expect(t.totalSignals, 1);
    expect(t.filteredSignals, 1);
    expect(t.totalOutcomes, 1);
    expect(t.averagePnlPerSignal, 12.5);
  });
}
