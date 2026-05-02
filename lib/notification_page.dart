import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List notifications = [];
  bool isLoading = true;

  Future<void> fetchNotif() async {
    setState(() => isLoading = true);

    try {
      final res = await http.get(
        Uri.parse("https://your-api.com/notif.json"),
      );

      final data = jsonDecode(res.body);

      setState(() {
        notifications = data['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotif();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off,
                        size: 60, color: Colors.white54),
                    const SizedBox(height: 10),
                    const Text(
                      "Tidak Ada Notifikasi",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchNotif,
                      child: const Text("Refresh"),
                    )
                  ],
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (c, i) {
                    final n = notifications[i];
                    return ListTile(
                      leading: const Icon(Icons.notifications,
                          color: Colors.white),
                      title: Text(
                        n['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        n['message'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
    );
  }
}