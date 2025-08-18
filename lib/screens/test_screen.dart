import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/providers/subdistrict_provider.dart';

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
    final subDistrictGetListstate = ref.watch(subDistrictGetList);
    //final authState = ref.watch(authProvider);
    //final accessToken = authState.accessToken;
    // ProductCategory product = ProductCategory(
    //   productCategoryName: "Product Category 1111",
    //   productCategoryDescription: "xxxxxxxxxxxxxxxx",
    //   isActive: true,
    //   createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    //   modifiedBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    //   createdDate: DateTime.now().toIso8601String(),
    //   modifiedDate: DateTime.now().toIso8601String(),
    // );
    // ProductCategoryService productCategoryService =
    //     new ProductCategoryService();
    // productCategoryService.add(accessToken.toString(), product);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod API Example')),
      body: Center(
        child: subDistrictGetListstate.when(
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.toList()[0].subDistrictName.toString(),
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
