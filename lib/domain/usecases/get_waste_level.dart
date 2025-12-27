import 'package:westo/domain/entities/waste_status.dart';
import 'package:westo/domain/repositories/waste_repository.dart';

/// Use case for fetching the current waste level and device status
class GetWasteLevel {
  final WasteRepository repository;

  /// Constructor receives repository dependency
  GetWasteLevel(this.repository);

  /// Executes the use case
  ///
  /// Returns the current [WasteStatus] of the waste bin
  Future<WasteStatus> call() async {
    return await repository.getWasteStatus();
  }
}
