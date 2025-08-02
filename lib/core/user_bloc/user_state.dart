class UserBalanceState{}

class UserBalanceLoading extends UserBalanceState{}

class UserBalanceLoaded extends UserBalanceState {
  final double balance;

  UserBalanceLoaded({required this.balance});
}

class UserBalanceError extends UserBalanceState {
  final String message;

  UserBalanceError({required this.message});
}