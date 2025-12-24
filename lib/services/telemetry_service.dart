import '../core/utils/logger.dart';

class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  // Signals
  int totalSignals = 0;
  int filteredSignals = 0;
  final Map<String, int> generatedByEngine = {};

  // Outcomes
  int totalOutcomes = 0;
  double totalPnl = 0.0;

  // API errors and timings
  final Map<String, int> apiErrors = {};
  final Map<String, List<int>> apiLatencies = {};

  void recordSignalGenerated(String engine, String type, double prob) {
    totalSignals++;
    generatedByEngine[engine] = (generatedByEngine[engine] ?? 0) + 1;
    AppLogger.info('🔔 Signal generated: engine=$engine type=$type prob=${(prob*100).toStringAsFixed(1)}%');
  }

  void recordSignalFiltered(String engine, String type, double prob, double threshold) {
    filteredSignals++;
    AppLogger.warn('⚖️ Signal filtered: engine=$engine type=$type prob=${(prob*100).toStringAsFixed(1)}% threshold=${(threshold*100).toStringAsFixed(1)}%');
  }

  void recordSignalOutcome(String engine, double profitLoss) {
    totalOutcomes++;
    totalPnl += profitLoss;
    AppLogger.success('✅ Signal outcome recorded: engine=$engine PnL=${profitLoss.toStringAsFixed(2)}');
  }

  void recordApiError(String service, int statusCode) {
    final key = '\$service:\$statusCode';
    apiErrors[key] = (apiErrors[key] ?? 0) + 1;
    AppLogger.error('❌ API error recorded: $service status=$statusCode', null);
  }

  void recordAICall(String service, int latencyMs, int? statusCode) {
    apiLatencies.putIfAbsent(service, () => []).add(latencyMs);
    AppLogger.info('⏱️ $service call latency: ${latencyMs}ms (status: ${statusCode ?? 'N/A'})');
  }

  double get averagePnlPerSignal => totalOutcomes == 0 ? 0.0 : totalPnl / totalOutcomes;

  double get overallSignalHitRate {
    // best-effort: uses trade outcomes if available
    if (totalOutcomes == 0) return 0.0;
    // We treat positive PnL as 'hit'
    // This is simplified; richer metrics can be added later
    return (totalPnl > 0 ? 1.0 : 0.0);
  }

  void logSnapshot() {
    AppLogger.info('📊 Telemetry Snapshot: totalSignals=$totalSignals filtered=$filteredSignals totalOutcomes=$totalOutcomes avgPnL=${averagePnlPerSignal.toStringAsFixed(2)}');
  }
}
