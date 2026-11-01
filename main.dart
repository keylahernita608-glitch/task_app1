import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item_model.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<AppUser> users = [];
  List<InventoryItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromStorage();
  }

  Future<void> _loadDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Load Data Users dari SharedPreferences
    final String? usersStr = prefs.getString('saved_users');
    if (usersStr != null) {
      List decoded = jsonDecode(usersStr);
      users = decoded.map((e) => AppUser.fromJson(e)).toList();
    } 
    
    // Jika belum ada sama sekali, buat data default (admin1, keya, user1)
    if (users.isEmpty) {
      users = [
        AppUser(username: 'admin1', password: '12345678', role: UserRole.AdminSuper, isApproved: true),
        AppUser(username: 'keya', password: '12345678', role: UserRole.AdminBiasa, isApproved: true),
        AppUser(username: 'user1', password: '12345678', role: UserRole.User, isApproved: true),
      ];
      await prefs.setString('saved_users', jsonEncode(users.map((e) => e.toJson()).toList()));
    } else {
      // Pastikan admin1 selalu ada dan berstatus approved
      if (!users.any((u) => u.username == 'admin1')) {
        users.insert(0, AppUser(
          username: 'admin1',
          password: '12345678',
          role: UserRole.AdminSuper,
          isApproved: true,
        ));
      }
    }

    // 2. Load Data Items dari SharedPreferences
    final String? itemsStr = prefs.getString('saved_items');
    if (itemsStr != null) {
      List decoded = jsonDecode(itemsStr);
      items = decoded.map((e) => InventoryItem.fromJson(e)).toList();
    } else {
      // Data default pertama kali
      items = [
        InventoryItem(
          id: '1',
          title: 'Perbaikan PC Lab 1',
          category: ItemCategory.Inventaris,
          description: 'Perbaikan hardware dan OS pada PC Lab 1.',
          status: ItemStatus.Pending,
          createdBy: 'user1',
        ),
        InventoryItem(
          id: '2',
          title: 'Update Module Flutter',
          category: ItemCategory.Task,
          description: 'Pembaruan modul latihan koding.',
          status: ItemStatus.Proses,
          createdBy: 'user1',
        ),
      ];
      await prefs.setString('saved_items', jsonEncode(items.map((e) => e.toJson()).toList()));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Task Inventory App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        primarySwatch: Colors.teal,
      ),
      home: LoginScreen(users: users, items: items),
    );
  }
}