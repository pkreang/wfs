import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/providers/purposetypegroup_provider.dart';

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
    final perposeTypeGroupGetListState = ref.watch(perposeTypeGroupGetList);

    //final accessToken = authState.accessToken;

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod API Example')),
      body: Center(
        child: perposeTypeGroupGetListState.when(
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.toList()[0].purposeTypeGroupsName.toString(),
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
      //Text("dsfsaf"),
    );
  }
}
