import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/clientstatus_provider.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod API Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ClientStatusGetListState = ref.watch(ClientStatusGetList);
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    // Company company = Company(
    //   isActive: true,
    //   createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    //   modifiedBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    //   createdDate: DateTime.now(),
    //   modifiedDate: DateTime.now(),
    //   companyID: "",
    //   salesTerritoryID: "",
    //   taxID: "",
    //   companyName: "",
    //   noted: "",
    // );
    // CompanyService companyService = new CompanyService();
    // companyService.Add(accessToken.toString(), company);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod API Example')),
      body: Center(
        child: ClientStatusGetListState.when(
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.toList()[0].clientStatusName.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () => ref.refresh(activityProvider),
              //   child: const Text('โหลดใหม่'),
              // )
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('เกิดข้อผิดพลาด: $err'),
        ),
      ),
    );
  }
}
