import 'dart:convert';
import 'dart:core';

import 'package:deus_mobile/models/synthetics/stock_price.dart';
import 'package:deus_mobile/models/synthetics/stock_price_detail.dart';
import 'package:deus_mobile/models/synthetics/xdai_contract_input_data.dart';
import 'package:http/http.dart' as http;

import '../models/synthetics/stock.dart';
import '../models/synthetics/stock_address.dart';
import '../models/token.dart';
import 'backend_endpoints.dart';

abstract class XDaiStockData {
  static const _basePath = 'images/stocks';

  static List<Stock> values = [];
  static List<StockAddress> addresses = [];

  static StockAddress getStockAddress(Token stock) {
    for (var i = 0; i < addresses.length; i++) {
      if (addresses[i].id.toLowerCase() == stock.getTokenName()) {
        return addresses[i];
      }
    }
    return null;
  }

  static Future<Map> getPrices() async {
    var response = await http.get(BackendEndpoints.PRICE_JSON_XDAI_1);
    if (response.statusCode == 200) {
      final Map<String, dynamic> map = json.decode(response.body);
      Map<String, StockPrice> prices = new Map();
      map.forEach((key, value) {
        StockPrice p =
            new StockPrice(new StockPriceDetail.fromJson(value["Long"]), new StockPriceDetail.fromJson(value['Short']));
        prices.addEntries([new MapEntry(key.toLowerCase(), p)]);
      });
      return prices;
    } else {
      return null;
    }
  }

  static Future<bool> getData() async {
    if (values.isNotEmpty) return true;
    final response = await http.get("https://oracle1.deus.finance/registrar-detail.json");
    if (response.statusCode == 200) {
      final Map<String, dynamic> map = json.decode(response.body);
      values.clear();
      map.forEach((key, value) {
        values.add(Stock.fromJson(value));
      });
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> getStockAddresses() async {
    if (addresses.isNotEmpty) return true;
    var response = await http.get("https://oracle1.deus.finance/xdai/conducted.json");
    if (response.statusCode == 200) {
      var js = json.decode(response.body);
      var map = js['tokens'];
      addresses.clear();
      map.forEach((value) {
        addresses.add(StockAddress.fromJson(value));
      });
      return true;
    } else {
      return false;
    }
  }

  static Future<List<XDaiContractInputData>> getContractInputData(String address) async {
    Map<String, XDaiContractInputData> oracle1 = await getInfoOracle1();
    Map<String, XDaiContractInputData> oracle2 = await getInfoOracle2();
    Map<String, XDaiContractInputData> oracle3 = await getInfoOracle3();

    List<XDaiContractInputData> list = [];
    if (oracle1 != null && oracle1.containsKey(address)) {
      list.add(oracle1[address]);
    }
    if (oracle2 != null && oracle2.containsKey(address)) {
      list.add(oracle2[address]);
    }
    if (oracle3 != null && oracle3.containsKey(address)) {
      list.add(oracle3[address]);
    }
    return list;
  }

  static Future<Map> getInfoOracle1() async {
    var response = await http.get(BackendEndpoints.SIGNATURES_JSON_XDAI_1);
    if (response.statusCode == 200) {
      Map<String, XDaiContractInputData> contractInputData = new Map();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        XDaiContractInputData c = XDaiContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }

  static Future<Map> getInfoOracle2() async {
    var response = await http.get(BackendEndpoints.SIGNATURES_JSON_XDAI_2);
    if (response.statusCode == 200) {
      Map<String, XDaiContractInputData> contractInputData = new Map();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        XDaiContractInputData c = XDaiContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }

  static Future<Map> getInfoOracle3() async {
    var response = await http.get(BackendEndpoints.SIGNATURES_JSON_XDAI_3);
    if (response.statusCode == 200) {
      Map<String, XDaiContractInputData> contractInputData = new Map();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        XDaiContractInputData c = XDaiContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }
}
