import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_reader/core/user_bloc/user_state.dart';
import 'package:qr_reader/data/repository/balance_repo.dart';

class UserCubit extends Cubit<UserBalanceState> {
  UserCubit() : super(UserBalanceLoading());

  Future<void> fetchUserBalance() async {
    emit(UserBalanceLoading());
    final balance = await BalanceRepo.getBalance();
    if (balance >= 0) {
      emit(UserBalanceLoaded(balance: balance));
    } else {
      emit(UserBalanceError(message: "No internet"));
    }
  }
}
