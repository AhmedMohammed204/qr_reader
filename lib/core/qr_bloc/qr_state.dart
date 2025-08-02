// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:qr_reader/core/DTOs/qr_dtos.dart';

class QrState {}

class QrInitial extends QrState {}

class QrCreated extends QrState {
  final String qrData;
  String passKey;
  QrCreated({required this.qrData, required this.passKey}) : super();
}

class QrScanning extends QrState {
  QrScanning() : super();
}

class QrDetected extends QrState {
  String encryptedQr;
  QrDetected({required this.encryptedQr}) : super();
}

class QrSuccessScan extends QrState {
  QrSuccessScan() : super();
}

class QrErrorScan extends QrState {
  final String message;
  QrErrorScan({required this.message}) : super();
}

class QrError extends QrState {
  final String message;
  QrError({required this.message}) : super();
}

class QrsLoading extends QrState {
  QrsLoading() : super();
}

class QrsLoaded extends QrState {
  final List<QrDTO> qrs;
  QrsLoaded({required this.qrs}) : super();
}

class MainQrState {}

class MainQrLoading extends MainQrState {}

class MainQrLoaded extends MainQrState {
  final String qr;
  final String passKey;
  MainQrLoaded({required this.qr, required this.passKey}) : super();
}

class MainQrNoEnoughBalance extends MainQrState {
  MainQrNoEnoughBalance() : super();
}

class CreatingCustomQr extends QrState {
  final double amount;
  final Duration duration;
  CreatingCustomQr({required this.amount, required this.duration}) : super();
}

class ManageQrState {}

class QrDeactivating extends ManageQrState {
  QrDeactivating() : super();
}

class QrDeactivated extends ManageQrState {
  final int qrId;
  QrDeactivated({required this.qrId}) : super();
}

class QrDeactivationError extends ManageQrState {
  final String message;
  QrDeactivationError({required this.message}) : super();
}