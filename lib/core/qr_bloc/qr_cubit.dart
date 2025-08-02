import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_reader/core/DTOs/qr_dtos.dart';
import 'package:qr_reader/core/qr_bloc/qr_state.dart';
import 'package:qr_reader/data/repository/qr_repo.dart';

class QrCubit extends Cubit<QrState> {
  QrCubit() : super(QrInitial());

  Future<void> createQrData(double amount, Duration expirationDuration) async {
    emit(CreatingCustomQr(amount: amount, duration: expirationDuration));

    final random = Random();
    final passKeyNumber = random.nextInt(10000);
    final String passKey = passKeyNumber.toString().padLeft(4, '0');
    var qrData = await QrRepository.createQr(
      amount: amount,
      expiry: DateTime.now().add(expirationDuration),
      passkey: passKey,
    );
    if (qrData.isEmpty) {
      emit(QrError(message: "Failed to create QR code"));
      return;
    }
    emit(QrCreated(qrData: qrData, passKey: passKey));
  }

  void detectQr(String encryptedQr) {
    emit(QrDetected(encryptedQr: encryptedQr));
  }

  void scanningError() {
    emit(QrErrorScan(message: "Failed to scan QR code"));
  }

  Future scanQr({
    required String encryptedQr,
    required double amount,
    required String passkey,
  }) async {
    emit(QrScanning());
    final isSuccess = await QrRepository.scanQr(
      encryptedQr: encryptedQr,
      amount: amount,
      passkey: passkey,
    );

    if (isSuccess) {
      emit(QrSuccessScan());
    } else {
      emit(QrErrorScan(message: "Failed to scan QR code"));
    }
  }

  Future getAllQrs() async {
    emit(QrsLoading());
    try {
      final response = await QrRepository.getAllQrs();
      final qrList = response.map((e) => QrDTO.fromJson(e)).toList();

      emit(QrsLoaded(qrs: qrList));
    } catch (e) {
      emit(QrError(message: e.toString()));
    }
  }
}

class MainQrCubit extends Cubit<MainQrState> {
  MainQrCubit() : super(MainQrState());

  void createMainQr({
    required double amount,
    required DateTime expiration,
  }) async {
    final random = Random();
    final passKeyNumber = random.nextInt(10000);
    final String passKey = passKeyNumber.toString().padLeft(4, '0');

    emit(MainQrLoading());

    expiration.add(const Duration(seconds: 10));

    String result = await QrRepository.generateQrData(
      amount: amount,
      expiresAt: expiration,
      passkey: passKey,
    );

    emit(MainQrLoaded(qr: result, passKey: passKey));
  }

  void notifiMainQrNoEnoughBalance() {
    emit(MainQrNoEnoughBalance());
  }
}

class ManageQrCubit extends Cubit<ManageQrState> {
  ManageQrCubit() : super(ManageQrState());

  void deactivateQr(int qrId) async {
    emit(QrDeactivating());
    bool res = await QrRepository.deactivateQr(qrId);
    if (res) {
      emit(QrDeactivated(qrId: qrId));
    } else {
      emit(QrDeactivationError(message: "Failed to deactivate QR code"));
    }
  }
}
