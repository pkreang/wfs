import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/productcategory_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/country_provider.dart';
import 'package:wfs/providers/productcategory_provider.dart';
import 'package:wfs/providers/province_provider.dart';
import 'package:wfs/services/productcategory_service.dart';

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
    final provinceGetListState = ref.watch(provinceGetList);
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
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
        child: provinceGetListState.when(
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.toList()[0].provinceName.toString(),
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
