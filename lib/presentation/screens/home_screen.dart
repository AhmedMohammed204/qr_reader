import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/data/general/cls_general.dart';
import 'package:qr_reader/presentation/screens/create_qr.dart';
import 'package:qr_reader/presentation/screens/history_qrs/show_qrs_screen.dart';
import 'package:qr_reader/presentation/screens/scan.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/wid_hider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A variable to keep track of the currently selected tab index
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => QrCubit()),
        BlocProvider(create: (_) => MainQrCubit()),
        BlocProvider(create: (_) => ManageQrCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text("Flex Pay"), actions: [_buildBalance]),
        body: Builder(
          builder: (_) {
            switch (_selectedIndex) {
              case 0:
                return CreateQR();
              case 1:
                return QrScannerWidget();
              case 2:
                return ShowQrsScreen();
              default:
                return Container();
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Create QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Scan & Receive',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'My QR Codes',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: clsColors.cardBackground,
          selectedItemColor: clsColors.gradientStart,
          unselectedItemColor: clsColors.secondaryText,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
    );
  }

  Widget get _buildBalance {
    return FutureBuilder<double>(
      future: clsGeneral.balance,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(
            'no internet connection',
            style: TextStyle(color: clsColors.errorRed),
          );
        } else if (snapshot.data! < 0) {
          return Text(
            'no internet connection',
            style: TextStyle(color: clsColors.errorRed),
          );
        } else {
          return widHider(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: clsColors.primaryText),
                  const SizedBox(width: 5),
                  Text(
                    '\$${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(color: clsColors.primaryText),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
