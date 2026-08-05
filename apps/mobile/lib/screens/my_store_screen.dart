import 'package:flutter/material.dart';
import 'package:mobile/models/store.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class MyStoreScreen extends StatefulWidget {
  final AuthService authService;

  const MyStoreScreen({super.key, required this.authService});

  @override
  State<MyStoreScreen> createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  late Future<Store?> _storeFuture;

  @override
  void initState() {
    super.initState();
    _storeFuture = _loadStore();
  }

  Future<Store?> _loadStore() async {
    try {
      return await widget.authService.apiService.getMyStore();
    } catch (e) {
      return null;
    }
  }

  Future<void> _refreshStore() async {
    setState(() {
      _storeFuture = _loadStore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Store')),
      body: RefreshIndicator(
        onRefresh: _refreshStore,
        child: FutureBuilder<Store?>(
          future: _storeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final store = snapshot.data;
            if (store == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No store yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your store to get started',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.createStore,
                          arguments: {'authService': widget.authService},
                        );
                      },
                      child: const Text('Create Store'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Colors.deepPurple),
                    title: Text(store.name),
                    subtitle: Text(store.description),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone_outlined, color: Colors.blue),
                    title: const Text('Phone'),
                    subtitle: Text(store.phone),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Colors.green),
                    title: const Text('Address'),
                    subtitle: Text(store.address),
                  ),
                ),
                if (store.logo != null && store.logo!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.image_outlined, color: Colors.orange),
                      title: const Text('Logo'),
                      subtitle: Text(store.logo!),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                    title: const Text('Created'),
                    subtitle: Text(
                      store.createdAt != null
                          ? '${store.createdAt!.day}/${store.createdAt!.month}/${store.createdAt!.year}'
                          : 'N/A',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.createStore,
                      arguments: {
                        'authService': widget.authService,
                        'store': store,
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Store'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}