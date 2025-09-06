import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment.dart';

class AppointmentListPage extends ConsumerStatefulWidget {
  const AppointmentListPage({super.key});

  @override
  ConsumerState<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends ConsumerState<AppointmentListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointment List")),
      body: FutureBuilder<List<Appointment>>(
        future: ref.read(appointmentProvider).fetchAppointments(),
        builder: (_, snapshot) {
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) return const Center(child: Text("No data"));

          return ListView.separated(
            itemCount: appointments.length,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () => (),
                child: Container(padding: const EdgeInsets.all(8.0), child: Column(children: [Text(appointments[index].appointmentTitle)])),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }
}
