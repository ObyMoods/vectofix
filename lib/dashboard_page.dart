import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'bugs/bug_sender.dart';
import 'package:audio_service/audio_service.dart';
import 'tools/spotify.dart';
import 'services/audio_handler.dart';
import 'manager/admin_page.dart';
import 'bugs/home_page.dart';
import 'manager/coins.dart';
import 'login_page.dart';
import 'info/tqto.dart';
import 'info/info.dart';
import 'update_page.dart';
import 'tools_gateway.dart';
import 'manager/change_password_page.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class UpdateItem {
  final String title;
  final String image;
  final String time;
  final bool isNew;
  final String link;

  UpdateItem({
    required this.title,
    required this.image,
    required this.time,
    required this.isNew,
    required this.link,
  });

  factory UpdateItem.fromJson(Map<String, dynamic> json) {
    return UpdateItem(
      title: json['title'],
      image: json['image'],
      time: json['time'],
      isNew: json['is_new'],
      link: json['link'],
    );
  }
}

class NotificationPage extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationPage({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.black,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text("Tidak ada notif", style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      notif.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      notif.message,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NotifikasiPage extends StatefulWidget {
  final List<NotificationItem> notifications;

  const NotifikasiPage({
    super.key,
    required this.notifications,
  });

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  late List<NotificationItem> notifications;

  @override
  void initState() {
    super.initState();
    notifications = List.from(widget.notifications); 
  }

  void _refreshNotif() {
    setState(() {
      notifications.add(
  NotificationItem(
    title: "Update Baru",
    message: "Notifikasi baru masuk 🔥",
  ),
);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil refresh notifikasi")),
    );
  }

  void _markAllRead() {
    setState(() {
      notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua notifikasi dibaca")),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
          child: const Icon(
            Icons.notifications_none,
            size: 40,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Tidak Ada Notifikasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Tidak ada notifikasi untuk ditampilkan saat ini",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _refreshNotif,
          icon: const Icon(Icons.refresh, color: Colors.white70),
          label: const Text(
            "Refresh",
            style: TextStyle(color: Colors.white70),
          ),
        )
      ],
    );
  }

  Widget _notifList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white70),
            title: Text(
  notifications[index].message,
  style: const TextStyle(color: Colors.white),
),
            subtitle: const Text(
              "Baru saja",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1C2C),
              Color(0xFF112D44),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_none,
                        color: Colors.white70),
                    const SizedBox(width: 10),
                    const Text(
                      "Notifikasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),

              // ===== CONTENT =====
              Expanded(
                child: Center(
                  child: notifications.isEmpty
                      ? _emptyState()
                      : _notifList(),
                ),
              ),

              // ===== FOOTER =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _markAllRead,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: const Center(
                            child: Text(
                              "Tandai Semua Dibaca",
                              style:
                                  TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _refreshNotif,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.red.withOpacity(0.2),
                        ),
                        child: const Icon(Icons.refresh,
                            color: Colors.red),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  String? sessionKey;
  late String username;
  late String password;
  late String role;
  late String expiredDate;
  late List<Map<String, dynamic>> listBug;
  late List<Map<String, dynamic>> listDoos;
  late List<dynamic> newsList;
  String androidId = "unknown";
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  File? _profileImage;
  List<NotificationItem> notifications = [];
  bool isLoadingNotif = false;
  List<UpdateItem> latestUpdates = [];
  bool isLoadingUpdates = true;

  // ===== LOKASI & DAERAH SHOLAT =====
  String _selectedCityName = "Jakarta";
  bool _isDetectingCity = false;
  int _selectedTabIndex = 0;
  Widget _getCurrentPage() {
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        _buildNewsPage(),
        sessionKey == null
            ? _buildNewsPage()
            : HomePage(
                username: username,
                password: password,
                sessionKey: sessionKey!,
                listBug: listBug,
                role: role,
                expiredDate: expiredDate,
                initialCoins: myCoins,
              ),
        sessionKey == null
            ? _buildNewsPage()
            : ToolsPage(
                username: username,
                userRole: role,
                sessionKey: sessionKey!,
                listDoos: listDoos,
              ),
      ],
    );
  }

Widget _buildStatCircle({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      const SizedBox(height: 10),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    ],
  );
}


  int onlineUsers = 0;
  int activeConnections = 0;
  Timer? _quoteTimer;

  final Color primaryDark = const Color(0xFF000000);
  final Color cardDark = const Color(0xFF1A1A1A);
  final Color cardDarker = const Color(0xFF0D0D0D);
  final Color accentColor = const Color(0xFF2D2D2D);
  final Color goldColor = const Color(0xFFFFD700);
  final Color blueColor = const Color(0xFF4A9EFF);
  final Color primaryColor = const Color(0xFF8B0000);  
  final Color primaryColorLight = const Color(0xFFB22222); 

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Color darkRed = Color(0xFF8B0000);
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // --- Shared audio player (dashboard mini player) ---
  AudioHandler? _dashAudioHandler;
  StreamSubscription<PlaybackState>? _dashPlaybackSub;
  StreamSubscription<MediaItem?>? _dashMediaSub;
  StreamSubscription<Duration>? _dashPositionSub;
  bool _dashIsPlaying = false;
  Map<String, dynamic>? _dashTrackData;
  Duration _dashDuration = Duration.zero;
  Duration _dashPosition = Duration.zero;

  List<Map<String, dynamic>> thanksToList = [];
  bool isLoadingThanksTo = false;

  String myCoins = "0";
  bool _isLoadingKey = false;
  bool isLoadingBalance = false;
  List<String> _arabicQuotes = [
    "وَأَقِيمُوا الصَّلَاةَ",
    "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ",
    "إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا",
    "حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَى",
    "وَأْمُرْ أَهْلَكَ بِالصَّلَاةِ وَاصْطَبِرْ عَلَيْهَا",
    "قَدْ أَفْلَحَ الْمُؤْمِنُونَ، الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ",
  ];
  String _currentArabicQuote = "";
  int _quoteIndex = 0;
  Map<String, Map<String, String>> _sholatTimes = {};
  bool _isLoadingSholat = false;
  bool _hasDetectedCityOnce = false;
  bool _hasShownLocationFallback = false;
  bool _isCheckingNotif = true;
  bool _hasNotif = false;
  String _notifMessage = "";
  String _nextPrayerName = "";
  String _nextPrayerTime = "";
  String _timeToNextPrayer = "";
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    fetchLatestUpdates();

    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

    _loadProfileImage();
    WidgetsBinding.instance.addObserver(this);

    // controller & animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _initAndroidIdAndConnect();

    // initialize shared audio handler for dashboard mini-player
    _initSharedAudio();

    _currentArabicQuote = _arabicQuotes[0];

    // ⏰ timer AMAN langsung
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });

    _quoteTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _arabicQuotes.length;
        _currentArabicQuote = _arabicQuotes[_quoteIndex];
      });
    });

    if (!_isDetectingCity) {
      _detectCityFromGPS();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;
  _getSessionKey();
  fetchNotifications();
});
  }
  
  Future<void> _initSharedAudio() async {
      try {
        final handler = await initAudioHandlerIfNeeded();
        _dashAudioHandler = handler;

        _dashPlaybackSub = handler.playbackState.listen((ps) {
          final playing = ps.playing;
          if (mounted) {
            setState(() {
              _dashIsPlaying = playing;
              _dashPosition = ps.updatePosition ?? _dashPosition;
            });
          }
        });

        _dashMediaSub = handler.mediaItem.listen((media) {
          if (mounted && media != null) {
            setState(() {
              final oldMeta = _dashTrackData?['result']?['metadata'] ?? {};
              _dashTrackData = {
                'result': {
                  'dlink': media.id,
                  'metadata': {
                    'title': media.title,
                    'artist': media.album ?? oldMeta['artist'] ?? '',
                    'cover': media.artUri?.toString() ?? oldMeta['cover'] ?? '',
                    'duration': _formatDurationString(media.duration),
                  },
                },
              };
            });
          }
        });

        try {
          final impl = handler as AudioPlayerHandler;
          _dashPositionSub = impl.positionStream.listen((p) {
            if (mounted) setState(() => _dashPosition = p);
          });
          impl.durationStream.listen((d) {
            if (d != null && mounted) setState(() => _dashDuration = d);
          });
        } catch (_) {}
      } catch (_) {}
    }

  Future<void> _getSessionKey() async {
    setState(() {
      _isLoadingKey = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              "http://kiluastecuuujirr.omdhanange.my.id:2251/getKey?username=${widget.username}",
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (!mounted) return;
          setState(() {
            sessionKey = data['key'];
            _isLoadingKey = false;
            _selectedTabIndex = 0;
            _fetchCoinBalance();
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingKey = false;
      });
    }
  }
  
  Future<void> fetchLatestUpdates() async {
  try {
    final response = await http.get(
      Uri.parse('http://kiluastecuuujirr.omdhanange.my.id:2251/api/latest_updates'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      setState(() {
        latestUpdates =
            data.map((e) => UpdateItem.fromJson(e)).toList();
        isLoadingUpdates = false;
      });
    }
  } catch (e) {
    print("Error latest updates: $e");
    setState(() {
      isLoadingUpdates = false;
    });
  }
}


  Future<String?> _reverseGeocode(double lat, double lon) async {
    final uri = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse"
      "?format=json"
      "&lat=$lat"
      "&lon=$lon"
      "&zoom=10"
      "&addressdetails=1",
    );

    final res = await http.get(
      uri,
      headers: {"User-Agent": "SadisticApp/1.0 (contact@sadistic.app)"},
    );

    if (res.statusCode != 200) return null;

    final json = jsonDecode(res.body);
    final address = json['address'];

    return address['city'] ??
        address['town'] ??
        address['municipality'] ??
        address['county'] ??
        address['state'];
  }

  Future<void> _fetchSholatTimesByGPS(double lat, double lon) async {
  setState(() => _isLoadingSholat = true);

  try {
    final res = await http
        .get(
          Uri.parse(
            "https://api.aladhan.com/v1/timings"
            "?latitude=$lat"
            "&longitude=$lon"
            "&method=3",
          ),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw "AlAdhan API error";
    }

    final json = jsonDecode(res.body);
    final times = json['data']['timings'];

    if (!mounted) return;
    setState(() {
      _sholatTimes = {
        'MAIN': {
          'Fajr': _cleanTime(times['Fajr']),
          'Dhuhr': _cleanTime(times['Dhuhr']),
          'Asr': _cleanTime(times['Asr']),
          'Maghrib': _cleanTime(times['Maghrib']),
          'Isha': _cleanTime(times['Isha']),
        },
      };

      _isLoadingSholat = false;
      _calculateNextPrayer();
      _startCountdownTimer();
    });
  } catch (e) {
    debugPrint("ALADHAN ERROR: $e");
    if (!mounted) return;
    setState(() => _isLoadingSholat = false);
  }
}

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_$username');

    if (path != null && File(path).existsSync()) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _fetchCoinBalance() async {
    if (isLoadingBalance) return;

    setState(() => isLoadingBalance = true);

    try {
      final response = await http.get(
        Uri.parse(
          'http://kiluastecuuujirr.omdhanange.my.id:2251/refreshCoins?key=$sessionKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          final newBCoins = data['coins'] ?? 0; // ⬅️ ambil dari response API

          if (!mounted) return;
          setState(() {
            myCoins = newBCoins.toString();
            isLoadingBalance = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            isLoadingBalance = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoadingBalance = false;
      });
    }
  }

  Future<void> _initAndroidIdAndConnect() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    androidId = deviceInfo.id ?? "unknown";
  }

  Future<void> _detectCityFromGPS() async {
    if (_isDetectingCity) return;

    setState(() => _isDetectingCity = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw "GPS mati";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw "Permission ditolak";
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // ===== NAMA WILAYAH (UI SAJA) =====
      final cityName = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedCityName = cityName ?? "Lokasi Anda";
        _hasDetectedCityOnce = true;
        _hasShownLocationFallback = false;
      });

      // ===== SHOLAT DARI GPS =====
      await _fetchSholatTimesByGPS(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("GPS ERROR: $e");

      if (!_hasShownLocationFallback) {
        _hasShownLocationFallback = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GPS gagal, cek izin lokasi")),
        );
      }
    } finally {
      setState(() => _isDetectingCity = false);
    }
  }
  
  Future<void> fetchNotifications() async {
  setState(() {
    isLoadingNotif = true;
    _isCheckingNotif = true;
  });

  try {
    final res = await http.get(
      Uri.parse("http://kiluastecuuujirr.omdhanange.my.id:2251/notification"),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // 🔥 HANDLE API SEDERHANA
      if (data['show'] == true) {
        setState(() {
          _hasNotif = true;
          _notifMessage = data['message'] ?? "";
          isLoadingNotif = false;
          _isCheckingNotif = false;
        });
      } else {
        setState(() {
          _hasNotif = false;
          isLoadingNotif = false;
          _isCheckingNotif = false;
        });
      }
    } else {
      throw Exception("Server error");
    }
  } catch (e) {
    setState(() {
      isLoadingNotif = false;
      _isCheckingNotif = false;
      _hasNotif = false;
    });
  }
}

  void _calculateNextPrayer() {
    if (_sholatTimes.isEmpty || _sholatTimes['MAIN'] == null) return;

    final now = DateTime.now();

    final prayers = [
      {'name': 'Subuh', 'time': _sholatTimes['MAIN']!['Fajr']!},
      {'name': 'Dzuhur', 'time': _sholatTimes['MAIN']!['Dhuhr']!},
      {'name': 'Ashar', 'time': _sholatTimes['MAIN']!['Asr']!},
      {'name': 'Maghrib', 'time': _sholatTimes['MAIN']!['Maghrib']!},
      {'name': 'Isya', 'time': _sholatTimes['MAIN']!['Isha']!},
    ];

    for (final p in prayers) {
      final parts = p['time']!.split(':');
      final t = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (t.isAfter(now)) {
        _nextPrayerName = p['name']!;
        _nextPrayerTime = p['time']!;
        _updateTimeToNextPrayer();
        return;
      }
    }

    // kalau semua lewat → subuh besok
    _nextPrayerName = 'Subuh';
    _nextPrayerTime = prayers.first['time']!;
    _updateTimeToNextPrayer();
  }

  void _updateTimeToNextPrayer() {
    if (!mounted || _nextPrayerTime.isEmpty) return;

    final now = DateTime.now();
    final parts = _nextPrayerTime.split(':');

    DateTime nextPrayer = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // ⏭️ Kalau sudah lewat → besok
    if (nextPrayer.isBefore(now)) {
      nextPrayer = nextPrayer.add(const Duration(days: 1));
    }

    final diff = nextPrayer.difference(now);

    if (diff.isNegative) return;

    setState(() {
      _timeToNextPrayer =
          '${diff.inHours.toString().padLeft(2, '0')}:'
          '${(diff.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
    });
  }

  void _startCountdownTimer() {
    if (_sholatTimes.isEmpty) return;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateTimeToNextPrayer();
    });
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: cardDarker,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "⚠️ Session Expired",
          style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              "OK",
              style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (sessionKey == null) return;

    setState(() {
      _selectedTabIndex = index; // 🔥 CUKUP INI SAJA
    });
  }
  
  Widget _buildSpotifyMiniCard() {
  if (_dashTrackData == null) return const SizedBox.shrink();

  final meta = _dashTrackData?['result']?['metadata'] ?? {};

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SpotifyPage()),
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              meta['cover'] ?? '',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 48, height: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta['title'] ?? '--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta['artist'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _dashIsPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: Colors.white,
              size: 34,
            ),
            onPressed: () async {
              if (_dashAudioHandler == null) return;
              _dashIsPlaying
                  ? await _dashAudioHandler!.pause()
                  : await _dashAudioHandler!.play();
            },
          ),
        ],
      ),
    ),
  );
}

String _formatDurationString(Duration? d) {
  if (d == null) return '00:00';
  final two = (int n) => n.toString().padLeft(2, '0');
  return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
}

  Widget _buildNewsPage() {
  return FadeTransition(
    opacity: _fadeAnimation,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPanel(),
          const SizedBox(height: 12),
          
          _buildSpotifyMiniCard(),
          const SizedBox(height: 12),

          _buildBugSenderButton(),
          const SizedBox(height: 12),

          buildLatestUpdates(),
          const SizedBox(height: 24),
          
          _buildWaktuSholat(),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

Widget buildLatestUpdates() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "LATEST UPDATES",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                "${latestUpdates.length} Updates",
                style: const TextStyle(color: Colors.orange),
              ),
            )
          ],
        ),
      ),
      const SizedBox(height: 15),
      SizedBox(
        height: 260,
        child: isLoadingUpdates
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: latestUpdates.length,
                itemBuilder: (context, index) {
                  final item = latestUpdates[index];

                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            item.image,
                            height: 160,
                            width: 260,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.time,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
      )
    ],
  );
}

  Widget _buildBottomNav() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPadding + 12),
      child: SizedBox(
        height: 80,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // ===== BAR BELAKANG =====
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, 0, "Home"),
                  const SizedBox(width: 60), // ruang tombol tengah
                  _navItem(Icons.build, 2, "Tools"),
                ],
              ),
            ),

            // ===== TOMBOL BUG TENGAH =====
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => _onTabTapped(1), // BUG = index 1
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [darkRed, darkRed.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkRed.withOpacity(0.6),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bug_report,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _navItem(IconData icon, int index, String label) {
    final isActive = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? goldColor : Colors.white70,
              size: isActive ? 28 : 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? goldColor : Colors.white70,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toLocalTime(String utcTime) {
    final parts = utcTime.split(':');

    final utc = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final local = utc.toLocal(); // AUTO WIB/WITA/WIT
    return DateFormat('HH:mm').format(local);
  }
  
  String _cleanTime(String time) {
  return time.split(' ').first; // ambil HH:mm
}

  Widget _buildWaktuSholat() {
    final times = _sholatTimes['MAIN'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================= JAM & TANGGAL =================
          Text(
            DateFormat('HH:mm:ss').format(_now),
            style: TextStyle(
              color: goldColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_now),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 8),

          // ===== QUOTE ARAB =====
          Directionality(
            textDirection: ui.TextDirection.rtl, // FIX
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                _currentArabicQuote,
                key: ValueKey(_currentArabicQuote),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ================= COUNTDOWN AZAN =================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkRed.withOpacity(0.6), darkRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: darkRed.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ===== WILAYAH =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),

                    Text(
                      _selectedCityName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ===== TOMBOL GPS =====
                    GestureDetector(
                      onTap: _isDetectingCity
                          ? null
                          : () {
                              _hasDetectedCityOnce = false;
                              _detectCityFromGPS();
                            },
                      child: _isDetectingCity
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            )
                          : const Icon(
                              Icons.gps_fixed,
                              size: 16,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ===== MENUJU SHOLAT =====
                Text(
                  "Menuju $_nextPrayerName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // ===== COUNTDOWN TIMER =====
                Text(
                  _timeToNextPrayer,
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= ROW CARD SHOLAT =================
          if (_isLoadingSholat)
            const Center(child: CircularProgressIndicator())
          else if (times != null)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildPrayerCard(
                  "Subuh",
                  times['Fajr']!,
                  Icons.wb_sunny_outlined,
                  Colors.blue.shade400,
                ),
                _buildPrayerCard(
                  "Dzuhur",
                  times['Dhuhr']!,
                  Icons.wb_sunny,
                  Colors.orange.shade400,
                ),
                _buildPrayerCard(
                  "Ashar",
                  times['Asr']!,
                  Icons.sunny,
                  Colors.green.shade400,
                ),
                _buildPrayerCard(
                  "Maghrib",
                  times['Maghrib']!,
                  Icons.nights_stay,
                  Colors.deepOrange.shade400,
                ),
                _buildPrayerCard(
                  "Isya",
                  times['Isha']!,
                  Icons.nightlight_round,
                  Colors.purple.shade400,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(
    String name,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _rowSholat(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white)),
          Text(
            time,
            style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(
    String name,
    String time,
    IconData icon,
    Color color,
  ) {
    final currentTime = DateFormat('HH:mm').format(_now);
    final isCurrent = currentTime == time;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? color.withOpacity(0.3)
                  : color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isCurrent ? Colors.white : color,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: isCurrent ? color : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBugSenderButton() {
  return Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        colors: [primaryColor, primaryColorLight],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton.icon(
      icon: const Icon(Icons.bug_report, color: Colors.white),
      label: const Text(
        "MANAGE BUG SENDER",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // CEK SESSION KEY NULL ATAU TIDAK
        if (sessionKey == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session belum siap, coba lagi nanti"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BugSenderPage(
              sessionKey: sessionKey!, // PAKAI ! KARENA SUDAH DI CEK
              username: username,
              role: role,
            ),
          ),
        );
      },
    ),
  );
}
  Widget _buildBanner() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.red.shade900, Colors.red],
      ),
    ),
    child: Column(
      children: [
        Text(
          "doyang dashboard",
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "🌙 Marhaban Ya Ramadhan",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Ahlan Wa Sahlan Bro! Stay Halal!",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}

Widget _buildProfileCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  // 🔥 AVATAR GLOW
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.verified, color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ===== USER INFO =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back,",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Orbitron',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Orbitron',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 🔥 TIMER GLOW
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.timer,
                        color: Colors.greenAccent),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ===== RAMADHAN BADGE =====
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  "🌙 Marhaban Ya Ramadhan 1447H",
                  style: TextStyle(color: Colors.orange, fontFamily: 'Orbitron'),
                ),
              ),

              const SizedBox(height: 16),

              // ===== DIVIDER =====
              Divider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
              ),

              const SizedBox(height: 12),

              // ===== STATS =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(Icons.people, "$onlineUsers", "Online Users",
                      Colors.green),
                  _statItem(Icons.link, "$activeConnections",
                      "Connections", Colors.blue),
                  _statItem(Icons.calendar_today, expiredDate, "Expiration",
                      Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildHeaderPanel() {
  return Column(
    children: [
      // ===== BANNER ATAS (FULL IMAGE) =====
      Container(
        width: double.infinity,
        height: 220, 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/banner.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "DOYANG DASHBOARD",
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "🌙 Marhaban Ya Ramadhan",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Ahlan Wa Sahlan Bro! Stay Halal!",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== CARD PROFILE =====
      Transform.translate(
        offset: const Offset(0, -20),
        child: _buildProfileCard(),
      ),
    ],
  );
}

Widget _statItem(IconData icon, String value, String label, Color color) {
  return Column(
    children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white)),
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    ],
  );
}

  Widget _buildDrawer() {
  return Drawer(
    backgroundColor: Colors.black,
    child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===== HEADER DRAWER (YANG SUDAH ADA) =====
          Container(
            height: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/sadistic_core.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Vecto",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerInfo("User", username),
                  _buildDrawerInfo("Role", role),
                  _buildDrawerInfo("Expired", expiredDate),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== MENU MY INFO =====
          _buildDrawerItem(
            icon: Icons.person,
            label: "My Info",
            onTap: () {
              if (sessionKey == null) return;
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyInfoPage(
                    username: username,
                    password: password,
                    role: role,
                    expiredDate: expiredDate,
                    sessionKey: sessionKey!,
                    coins: myCoins,
                  ),
                ),
              );
            },
          ),

          // ===== MENU ADMIN PAGE =====
          if (role != "member")
            _buildDrawerItem(
              icon: Icons.admin_panel_settings,
              label: "Admin Page",
              onTap: () {
                if (sessionKey == null) return;
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPage(
                      sessionKey: sessionKey!,
                      currentUserRole: role,
                    ),
                  ),
                );
              },
            ),

          // ===== MENU THANKS TO =====
          _buildDrawerItem(
            icon: Icons.group,
            label: "Thanks To",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThanksToPage()),
              );
            },
          ),

 
          _buildDrawerItem(
            icon: Icons.system_update_alt,
            label: "Update APK",
            onTap: () {
              Navigator.pop(context); // tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdatePage(
                    nextPage: DashboardPage(
                      username: username,
                      password: password,
                      role: role,
                      expiredDate: expiredDate,
                      listBug: listBug,
                      listDoos: listDoos,
                      news: newsList,
                    ),
                  ),
                ),
              );
            },
          ),

          const Divider(color: Colors.white24),

 
          _buildDrawerItem(
            icon: Icons.logout,
            label: "Logout",
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDrawerInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: goldColor),
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildNotifPopup() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.6),
          blurRadius: 25,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ===== HEADER =====
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifikasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Pesan terbaru",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ❌ tombol close
            GestureDetector(
              onTap: () {
                setState(() {
                  _hasNotif = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ===== ISI =====
        Text(
          _notifMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // ===== TOMBOL =====
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: fetchNotifications,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasNotif = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Lanjut"),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  @override
Widget build(BuildContext context) {
  if (sessionKey == null && _isLoadingKey) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    backgroundColor: primaryDark,

    appBar: AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,

      title: null,

      flexibleSpace: SafeArea(
        child: Center(
          child: Image.asset(
            "assets/images/logo.png",
            height: 28,
          ),
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.music_note, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SpotifyPage(),
              ),
            );
          },
        ),

        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_none, color: Colors.white),

              if (notifications.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotifikasiPage(
                  notifications: notifications,
                ),
              ),
            );
          },
        ),

        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ],
    ),
    drawer: _buildDrawer(),

    body: Stack(
      children: [
        FadeTransition(
          opacity: _animation,
          child: _getCurrentPage(),
        ),

        if (_hasNotif)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.75),
              child: Center(
                child: _buildNotifPopup(),
              ),
            ),
          ),
      ],
    ),

    bottomNavigationBar: _buildBottomNav(),
  );
}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state); // ⬅️ WAJIB

    if (state == AppLifecycleState.resumed) {
      if (!_isDetectingCity && !_hasDetectedCityOnce) {
        _detectCityFromGPS();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _slideController.dispose();

    _quoteTimer?.cancel();
    _clockTimer?.cancel();
    _countdownTimer?.cancel();

    // cancel audio subs
    try {
      _dashPlaybackSub?.cancel();
      _dashMediaSub?.cancel();
      _dashPositionSub?.cancel();
    } catch (_) {}

    super.dispose();
  }
}

class NotificationItem {
  final String title;
  final String message;

  NotificationItem({
    required this.title,
    required this.message,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title']?.toString() ?? 'No Title',
      message: json['message']?.toString() ?? '',
    );
  }
}