import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:archive/archive.dart';

class BuildApkFlutter extends StatefulWidget {
  final String? sessionKey;
  final String? username;
  final String? role;

  const BuildApkFlutter({
    super.key,
    this.sessionKey,
    this.username,
    this.role,
  });

  @override
  State<BuildApkFlutter> createState() => _BuildApkFlutterState();
}

class _BuildApkFlutterState extends State<BuildApkFlutter> with TickerProviderStateMixin {
  final TextEditingController _ghpTokenController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  File? _selectedZipFile;
  String? _selectedZipFileName;
  
  bool _isLoading = false;
  bool _isBuildRunning = false;
  String? _errorMessage;
  String? _successMessage;
  String? _apkDownloadUrl;
  String? _currentRepoName;
  String? _currentUsername;
  List<String> _buildLogs = [];
  ScrollController _terminalScrollController = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final Color primaryDark = const Color(0xFF0A0E27);
  final Color primaryBlue = const Color(0xFFB91C1C);
  final Color accentBlue = const Color(0xFFEF4444);
  final Color lightBlue = const Color(0xFFFCA5A5);
  final Color cardDark = const Color(0xFF151932);
  final Color cardDarker = const Color(0xFF0F1330);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initNotifications();
  }

  void _initAnimations() {
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'build_channel',
      'Build APK Notifications',
      description: 'Notifikasi status build APK',
      importance: Importance.high,
    );
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == 'download_apk') {
      _showDownloadDialog();
    }
  }

  void _showDownloadDialog() {
    if (_apkDownloadUrl == null) return;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.download, color: Colors.green),
            SizedBox(width: 10),
            Text("APK Siap Download!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Build APK telah selesai. Download dan install sekarang?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Nanti", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAPK();
            },
            style: ElevatedButton.styleFrom(backgroundColor: successGreen),
            child: const Text("DOWNLOAD"),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    required bool isSuccess,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'build_channel',
      'Build APK Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload ?? (isSuccess ? 'download_apk' : null),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("✅ Build Berhasil!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("APK telah selesai dibuild!", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download & Install"),
                style: ElevatedButton.styleFrom(backgroundColor: successGreen),
                onPressed: () {
                  Navigator.pop(context);
                  _downloadAPK();
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text("❌ Build Gagal!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showInstallDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 10),
            Text("Instalasi APK", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "APK sudah diunduh. Ikuti petunjuk di layar untuk menginstal aplikasi.\n\n"
          "Jika diminta, aktifkan 'Izinkan instalasi dari sumber ini'.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(File apkFile) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.orange),
            SizedBox(width: 10),
            Text("Bagikan APK", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Tidak bisa membuka installer. Bagikan file APK?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Share.shareXFiles([XFile(apkFile.path)], text: 'APK File');
            },
            style: ElevatedButton.styleFrom(backgroundColor: successGreen),
            child: const Text("Bagikan"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _ghpTokenController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _addBuildLog(String message, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    setState(() {
      _buildLogs.add("[${DateTime.now().toString().substring(11, 19)}] ${isError ? '❌ ' : isSuccess ? '✅ ' : '➜ '}$message");
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_terminalScrollController.hasClients) {
        _terminalScrollController.animateTo(
          _terminalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickZipFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    
    if (result != null) {
      setState(() {
        _selectedZipFile = File(result.files.single.path!);
        _selectedZipFileName = result.files.single.name;
      });
      _addBuildLog("File ZIP dipilih: $_selectedZipFileName", isSuccess: true);
    }
  }

  Future<void> _buildAPK() async {
    final ghpToken = _ghpTokenController.text.trim();
    final username = _usernameController.text.trim();

    if (_selectedZipFile == null) {
      _addBuildLog("Pilih file ZIP terlebih dahulu!", isError: true);
      return;
    }
    
    if (ghpToken.isEmpty || username.isEmpty) {
      _addBuildLog("Semua field harus diisi!", isError: true);
      return;
    }

    if (_isBuildRunning) {
      _addBuildLog("Build sedang berjalan!", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _isBuildRunning = true;
      _errorMessage = null;
      _successMessage = null;
      _apkDownloadUrl = null;
      _buildLogs = [];
      _currentRepoName = null;
      _currentUsername = username;
    });

    _addBuildLog("Memulai build APK dari ZIP: $_selectedZipFileName");
    _addBuildLog("Username GitHub: $username");
    
    try {
      _addBuildLog("Membuat repository GitHub...");
      
      final repoName = "flutter_build_${DateTime.now().millisecondsSinceEpoch}";
      _currentRepoName = repoName;
      
      final createRepoResponse = await http.post(
        Uri.parse("https://api.github.com/user/repos"),
        headers: {
          'Authorization': 'token $ghpToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': repoName,
          'description': 'Flutter App',
          'private': false,
          'auto_init': true,
        }),
      );
      
      if (createRepoResponse.statusCode != 201 && createRepoResponse.statusCode != 422) {
        _addBuildLog("Gagal membuat repository! Status: ${createRepoResponse.statusCode}", isError: true);
        await _showNotification(
          title: "Build APK Gagal",
          body: "Gagal membuat repository GitHub!",
          isSuccess: false,
        );
        setState(() {
          _isLoading = false;
          _isBuildRunning = false;
        });
        return;
      }
      _addBuildLog("Repository berhasil dibuat: $repoName ✅", isSuccess: true);
      
      _addBuildLog("Membaca file ZIP...");
      final zipBytes = await _selectedZipFile!.readAsBytes();
      
      _addBuildLog("Mengupload ZIP ke repository...");
      final base64Zip = base64Encode(zipBytes);
      
      final uploadZip = await http.put(
        Uri.parse("https://api.github.com/repos/$username/$repoName/contents/project.zip"),
        headers: {
          'Authorization': 'token $ghpToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Upload Flutter project',
          'content': base64Zip,
        }),
      );
      
      if (uploadZip.statusCode != 201 && uploadZip.statusCode != 200) {
        _addBuildLog("Gagal upload ZIP! Status: ${uploadZip.statusCode}", isError: true);
        await _showNotification(
          title: "Build APK Gagal",
          body: "Gagal upload ZIP ke GitHub!",
          isSuccess: false,
        );
        setState(() {
          _isLoading = false;
          _isBuildRunning = false;
        });
        return;
      }
      _addBuildLog("ZIP berhasil diupload ✅", isSuccess: true);
      
      _addBuildLog("Membuat workflow GitHub Actions...");
      
      final workflowContent = '''name: Build Flutter APK

on:
  workflow_dispatch:

jobs:
  build-android:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Disable analytics
        run: flutter config --no-analytics

      - name: Extract ZIP
        run: |
          if [ -f "project.zip" ]; then
            unzip -o project.zip -d .
            rm project.zip
          fi
          ls -la

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 30''';
      
      await _createFileInRepo(username, repoName, ghpToken, '.github/workflows/build.yml', workflowContent);
      _addBuildLog("Workflow berhasil dibuat ✅", isSuccess: true);
      
      _addBuildLog("Trigger build via GitHub Actions...");
      
      final triggerResponse = await http.post(
        Uri.parse("https://api.github.com/repos/$username/$repoName/actions/workflows/build.yml/dispatches"),
        headers: {
          'Authorization': 'token $ghpToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ref': 'main',
        }),
      );
      
      if (triggerResponse.statusCode == 204) {
        _addBuildLog("Build dimulai! Menunggu proses selesai (3-8 menit)...", isSuccess: true);
        await _showNotification(
          title: "Build APK Dimulai",
          body: "Proses build APK sedang berjalan. Anda akan diberitahu saat selesai.",
          isSuccess: true,
        );
        
        setState(() { _isLoading = false; });
        
        bool buildCompleted = false;
        int attempts = 0;
        
        while (!buildCompleted && attempts < 120 && _isBuildRunning) {
          await Future.delayed(const Duration(seconds: 5));
          
          if (!_isBuildRunning) break;
          
          try {
            final runsResponse = await http.get(
              Uri.parse("https://api.github.com/repos/$username/$repoName/actions/runs?per_page=1"),
              headers: {'Authorization': 'token $ghpToken'},
            );
            
            if (runsResponse.statusCode == 200) {
              final runsData = jsonDecode(runsResponse.body);
              if (runsData['workflow_runs'] != null && runsData['workflow_runs'].isNotEmpty) {
                final latestRun = runsData['workflow_runs'][0];
                final status = latestRun['status'];
                final conclusion = latestRun['conclusion'];
                
                if (status == 'completed') {
                  buildCompleted = true;
                  if (conclusion == 'success') {
                    _addBuildLog("Build berhasil! Mengambil APK...", isSuccess: true);
                    
                    final artifactsResponse = await http.get(
                      Uri.parse("https://api.github.com/repos/$username/$repoName/actions/runs/${latestRun['id']}/artifacts"),
                      headers: {'Authorization': 'token $ghpToken'},
                    );
                    
                    if (artifactsResponse.statusCode == 200) {
                      final artifactsData = jsonDecode(artifactsResponse.body);
                      if (artifactsData['artifacts'] != null && artifactsData['artifacts'].isNotEmpty) {
                        final artifact = artifactsData['artifacts'][0];
                        final downloadUrl = artifact['archive_download_url'];
                        
                        if (mounted) {
                          setState(() {
                            _apkDownloadUrl = downloadUrl;
                            _successMessage = "APK siap didownload!";
                            _isBuildRunning = false;
                          });
                        }
                        _addBuildLog("APK siap didownload!", isSuccess: true);
                        
                        await _showNotification(
                          title: "✅ Build APK Berhasil!",
                          body: "APK telah selesai dibuild. Klik notifikasi untuk download.",
                          isSuccess: true,
                          payload: 'download_apk',
                        );
                        
                        if (mounted) {
                          _showSuccessDialog();
                        }
                      } else {
                        _addBuildLog("Tidak ada artifact ditemukan", isError: true);
                        await _showNotification(
                          title: "Build APK Gagal",
                          body: "Tidak ada artifact ditemukan.",
                          isSuccess: false,
                        );
                        setState(() { _isBuildRunning = false; });
                      }
                    }
                  } else {
                    _addBuildLog("Build gagal dengan status: $conclusion.", isError: true);
                    await _showNotification(
                      title: "❌ Build APK Gagal",
                      body: "Build gagal: $conclusion",
                      isSuccess: false,
                    );
                    _showErrorDialog("Build gagal: $conclusion\nCek GitHub Actions.");
                    setState(() { _isBuildRunning = false; });
                  }
                } else {
                  if (attempts % 12 == 0) {
                    _addBuildLog("Build sedang berjalan... (${attempts * 5}s)");
                  }
                }
              }
            }
          } catch (e) {
            _addBuildLog("Error checking build status: $e", isError: true);
          }
          attempts++;
        }
        
        if (!buildCompleted && _isBuildRunning) {
          _addBuildLog("Build memakan waktu lama. Cek GitHub Actions secara manual.", isError: true);
          await _showNotification(
            title: "Build APK Timeout",
            body: "Build memakan waktu lama. Cek GitHub Actions secara manual.",
            isSuccess: false,
          );
          setState(() { _isBuildRunning = false; });
        }
      } else {
        _addBuildLog("Gagal menjalankan workflow! Status: ${triggerResponse.statusCode}", isError: true);
        await _showNotification(
          title: "Build APK Gagal",
          body: "Gagal menjalankan workflow!",
          isSuccess: false,
        );
        setState(() { _isBuildRunning = false; });
      }
      
    } catch (e) {
      _addBuildLog("Error: $e", isError: true);
      await _showNotification(
        title: "Build APK Error",
        body: "Terjadi error: $e",
        isSuccess: false,
      );
      _showErrorDialog("Terjadi error: $e");
      setState(() { _isBuildRunning = false; });
    } finally {
      if (mounted) {
        setState(() { 
          _isLoading = false;
          _isBuildRunning = false;
        });
      }
    }
  }
  
  Future<void> _createFileInRepo(String username, String repoName, String ghpToken, String path, String content) async {
    final response = await http.put(
      Uri.parse("https://api.github.com/repos/$username/$repoName/contents/$path"),
      headers: {
        'Authorization': 'token $ghpToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': 'Add $path',
        'content': base64Encode(utf8.encode(content)),
        'branch': 'main',
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      _addBuildLog("File $path berhasil dibuat", isSuccess: true);
    } else {
      _addBuildLog("Gagal membuat file $path: ${response.statusCode}", isError: true);
    }
  }

  Future<void> _downloadAPK() async {
    if (_apkDownloadUrl == null) return;

    setState(() { _isLoading = true; });
    
    try {
      _addBuildLog("Mengunduh APK dari: $_apkDownloadUrl");
      
      final token = _ghpTokenController.text.trim();
      
      final response = await http.get(
        Uri.parse(_apkDownloadUrl!),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      if (response.statusCode != 200) {
        _addBuildLog("Gagal download! Status: ${response.statusCode}", isError: true);
        return;
      }
      
      _addBuildLog("Ukuran download: ${response.bodyBytes.length} bytes");
      
      if (response.bodyBytes.length < 10000) {
        _addBuildLog("File terlalu kecil (corrupt)!", isError: true);
        _addBuildLog("Coba download manual dari GitHub Actions.", isError: true);
        return;
      }
      
      final tempDir = await getTemporaryDirectory();
      final zipFile = File('${tempDir.path}/artifact_${DateTime.now().millisecondsSinceEpoch}.zip');
      await zipFile.writeAsBytes(response.bodyBytes);
      
      _addBuildLog("Ekstrak ZIP...");
      
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      File? apkFile;
      for (final file in archive) {
        if (file.name.endsWith('.apk') && !file.isFile) {
          final extractedFile = File('${tempDir.path}/${file.name}');
          await extractedFile.writeAsBytes(file.content as List<int>);
          apkFile = extractedFile;
          _addBuildLog("APK ditemukan: ${file.name}", isSuccess: true);
          break;
        }
      }
      
      if (apkFile == null) {
        _addBuildLog("Tidak ditemukan APK dalam ZIP", isError: true);
        return;
      }
      
      final fileSize = await apkFile.length();
      _addBuildLog("Ukuran APK: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB", isSuccess: true);
      
      await _installAPK(apkFile);
      
    } catch (e) {
      _addBuildLog("Error download APK: $e", isError: true);
      _addBuildLog("Coba download manual dari GitHub Actions.", isError: true);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _installAPK(File apkFile) async {
    try {
      _addBuildLog("Meminta izin instalasi...");
      
      if (await Permission.requestInstallPackages.isDenied) {
        await Permission.requestInstallPackages.request();
      }
      
      _addBuildLog("Membuka APK untuk instalasi...");
      
      final result = await OpenFilex.open(apkFile.path);
      
      if (result.type == ResultType.done) {
        _addBuildLog("Instalasi dimulai!", isSuccess: true);
        _showInstallDialog();
      } else {
        _addBuildLog("Gagal membuka APK: ${result.message}", isError: true);
        _showShareDialog(apkFile);
      }
    } catch (e) {
      _addBuildLog("Error install APK: $e", isError: true);
      _showShareDialog(apkFile);
    }
  }

  Widget _buildTerminal() {
    if (_buildLogs.isEmpty && !_isLoading && !_isBuildRunning) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                const Text("Build Logs", style: TextStyle(color: Colors.white70)),
                const Spacer(),
                if (_isBuildRunning)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
              ],
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              controller: _terminalScrollController,
              itemCount: _buildLogs.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  _buildLogs[index],
                  style: TextStyle(
                    color: _buildLogs[index].contains('❌') ? dangerRed : (_buildLogs[index].contains('✅') ? successGreen : Colors.white),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isBuildRunning,
      onPopInvoked: (didPop) {
        if (_isBuildRunning) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Build sedang berjalan, tidak bisa keluar!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: primaryDark,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accentBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.folder_zip, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text("Builder APK Flutter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: primaryDark,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
                    ),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, _) => Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                              child: const Icon(Icons.folder_zip, color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("Builder APK Flutter", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Build APK dari file ZIP", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isBuildRunning ? null : _pickZipFile,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardDarker,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentBlue.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.folder_zip, color: accentBlue, size: 30),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedZipFileName ?? "Pilih File ZIP",
                                        style: TextStyle(
                                          color: _selectedZipFileName != null ? Colors.white : Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (_selectedZipFileName != null)
                                        Text(
                                          "Klik untuk ganti file",
                                          style: TextStyle(color: accentBlue, fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.upload_file, color: accentBlue),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildField(_ghpTokenController, "GitHub Token (ghp_)", Icons.vpn_key, obscure: true, enabled: !_isBuildRunning),
                        const SizedBox(height: 12),
                        _buildField(_usernameController, "GitHub Username", Icons.person, enabled: !_isBuildRunning),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(colors: [accentBlue, lightBlue]),
                          ),
                          child: ElevatedButton(
                            onPressed: (_isLoading || _isBuildRunning) ? null : _buildAPK,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
                            child: _isLoading || _isBuildRunning
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("BUILD APK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (_apkDownloadUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(colors: [successGreen, Color(0xFF34D399)]),
                              ),
                              child: ElevatedButton(
                                onPressed: _downloadAPK,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
                                child: const Text("Download & Install", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: successGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: successGreen),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_successMessage!, style: const TextStyle(color: Colors.white))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildTerminal(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint, IconData icon, {bool obscure = false, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(color: cardDarker, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: c,
        obscureText: obscure,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: accentBlue),
        ),
      ),
    );
  }
}
