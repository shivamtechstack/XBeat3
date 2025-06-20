import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:xbeat3/pages/home_page.dart';
import 'package:xbeat3/providers/audio_player_provider.dart';
import 'package:xbeat3/providers/file_provider.dart';
import 'package:xbeat3/providers/folder_provider.dart';
import 'package:xbeat3/themes/theme_provider.dart';
import 'package:xbeat3/utils/permission_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.sycodes.xbeat3.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'drawable/bingicon',
    );
    if (kDebugMode) {
      print("JustAudioBackground initialized");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error initializing JustAudioBackground: $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FolderProvider()),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'An Audio Player',
          theme: themeProvider.themeData,
          home: const PermissionsGate(),
        );
      },
    );
  }
}

class PermissionsGate extends StatefulWidget {
  const PermissionsGate({super.key});
  @override
  State<PermissionsGate> createState() => _PermissionsGateState();
}

class _PermissionsGateState extends State<PermissionsGate> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await PermissionUtils.requestStoragePermissions();
    if (!granted) {
      await PermissionUtils.handlePermanentDenial();
    } else {
      setState(() => _hasPermission = true);
      context.read<FileProvider>().fetchFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _checkPermissions,
            child: const Text('Enable storage permission'),
          ),
        ),
      );
    } else {
      return const HomePage();
    }
  }
}
