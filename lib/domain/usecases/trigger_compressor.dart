import 'package:westo/domain/repositories/waste_repository.dart';

/// Use case for triggering the waste compressor
class TriggerCompressor {
  final WasteRepository repository;

  /// Constructor receives repository dependency
  TriggerCompressor(this.repository);

  /// Executes the compressor action
  Future<void> call() async {
    await repository.triggerCompressor();
  }
}
