import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:westo/data/repositories/waste_repository_impl.dart';
import 'package:westo/presentation/viewmodels/device_viewmodel.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeviceViewModel(
        repository: context.read<WasteRepositoryImpl>(),
      )..loadDeviceInfo(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Device Information'),
        ),
        body: Consumer<DeviceViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Text(vm.errorMessage!),
              );
            }

            final device = vm.deviceInfo;
            if (device == null) {
              return const Center(
                child: Text('No device data available'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoTile(
                  title: 'Device Name',
                  value: device.deviceName,
                ),
                _InfoTile(
                  title: 'Firmware Version',
                  value: device.firmwareVersion,
                ),
                _InfoTile(
                  title: 'MAC Address',
                  value: device.macAddress,
                ),
                _InfoTile(
                  title: 'IP Address',
                  value: device.ipAddress,
                ),
                _InfoTile(
                  title: 'Mode',
                  value: device.mode,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Reusable info tile widget
class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
