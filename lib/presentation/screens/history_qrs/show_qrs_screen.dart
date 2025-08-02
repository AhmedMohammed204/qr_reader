import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/core/qr_bloc/qr_state.dart';
import 'package:qr_reader/presentation/screens/history_qrs/qrs_list.dart';

class ShowQrsScreen extends StatefulWidget {
  const ShowQrsScreen({super.key});

  @override
  State<ShowQrsScreen> createState() => _ShowQrsScreenState();
}

class _ShowQrsScreenState extends State<ShowQrsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QrCubit>().getAllQrs();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<QrCubit, QrState>(
            builder: (context, state) {
              if (state is QrsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is QrsLoaded) {
                return QrsList(qrs: state.qrs);
              } else if (state is QrError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No QR codes found.'));
            },
          ),
        ),
      ],
    );
  }
}