import '../../service/ethereum_service.dart';

import '../token.dart';

// ignore: must_be_immutable
class CryptoCurrency extends Token {
  String? _balance;
  String? _allowances;

  String get balance => _balance ?? "0";

  set balance(String? value) {
    _balance = value;
  }

  BigInt getBalance() {
    return EthereumService.getWei(balance, symbol.toLowerCase());
  }

  BigInt getAllowances() {
    return EthereumService.getWei(allowances, symbol.toLowerCase());
  }

  CryptoCurrency({
    required String name,
    required String symbol,
    required String logoPath,
  }) : super(name, symbol, logoPath);

  String get allowances => _allowances ?? "0";

  set allowances(String? value) {
    _allowances = value;
  }
}
