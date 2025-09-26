import 'package:flutter/foundation.dart';
import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';

class AuthCubitListenable extends ChangeNotifier {
  final AuthCubit cubit;
  late final void Function() _listener;

  AuthCubitListenable(this.cubit) {
    _listener = () => notifyListeners();
    cubit.stream.listen((_) => _listener());
  }
}
