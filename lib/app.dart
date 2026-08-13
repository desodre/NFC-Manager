import 'package:flutter/material.dart';

import 'services/history_service.dart';
import 'services/nfc_service.dart';
import 'viewmodels/home_view_model.dart';
import 'views/home_page.dart';

class NfcManagerApp extends StatefulWidget {
  const NfcManagerApp({super.key});

  @override
  State<NfcManagerApp> createState() => _NfcManagerAppState();
}

class _NfcManagerAppState extends State<NfcManagerApp> {
  late final HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(
      nfcService: NfcService(),
      historyService: HistoryService(),
    )..initialize();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NFC Manager',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff075e54)),
      useMaterial3: true,
    ),
    home: HomePage(viewModel: viewModel),
  );
}
