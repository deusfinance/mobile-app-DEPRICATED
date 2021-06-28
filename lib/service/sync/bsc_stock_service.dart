import 'dart:math';

import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/service/sync/sync_service.dart';
import 'package:deus_mobile/service/sync/xdai_stock_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import '../ethereum_service.dart';

class BscStockService extends SyncService {
  String marketMaker = "0x3b62F3820e0B035cc4aD602dECe6d796BC325325";

  BscStockService({required ethService, required privateKey})
      : super(ethService, privateKey);

  @override
  Future<String> getAllowances(tokenAddress) async {
    if (tokenAddress != await ethService.getTokenAddrHex('busd', 'token')) {
      return "1000000000000000";
    }
    DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));
    final res = await ethService.query(tokenContract, "allowance",
        [await address, EthereumAddress.fromHex(marketMaker)]);

    return EthereumService.fromWei(res.single);
  }
  @override
  Future<String> approve(tokenAddress, gas) async {
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));

    var res = ethService.submit(await credentials, tokenContract, "approve",
        [EthereumAddress.fromHex(marketMaker), EthereumService.getWei(amount)],
        gas: gas);
    return res;
  }
  @override
  Future<Transaction> makeApproveTransaction(tokenAddress) async {
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));
    var res = ethService.makeTransaction(
        await credentials,
        tokenContract,
        "approve",
        [EthereumAddress.fromHex(marketMaker), EthereumService.getWei(amount)]);
    return res;
  }
  @override
  Future<String> getTokenBalance(tokenAddress) async {
    if (tokenAddress == XDaiStockService.xdaiTokenAddress) {
      var res = await ethService.getEtherBalance(await credentials);
      return EthereumService.fromWei(res.getInWei);
    }
    DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));
    final res =
        await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res.single);
  }
  @override
  Future<String> buy(
      tokenAddress, String amount, List<ContractInputData> oracles, Gas gas,
      {String? maxPrice}) async {
    DeployedContract contract = await ethService.loadContractWithGivenAddress(
        "bscSynchronizer", EthereumAddress.fromHex(this.marketMaker));
    ContractInputData info = oracles[0];

    return await ethService.submit(
        await credentials,
        contract,
        "buyFor",
        [
          await address,
          info.getMultiplier(),
          EthereumAddress.fromHex(tokenAddress),
          EthereumService.getWei(amount),
          info.getFee(),
          [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
          [oracles[0].getPrice(), oracles[1].getPrice()],
          [oracles[0].signs['buy']!.getV(), oracles[1].signs['buy']!.getV()],
          [oracles[0].signs['buy']!.getR(), oracles[1].signs['buy']!.getR()],
          [oracles[0].signs['buy']!.getS(), oracles[1].signs['buy']!.getS()],
        ],
        gas: gas);
  }
  @override
  Future<String> sell(tokenAddress, String amount,
      List<ContractInputData> oracles, Gas gas) async {
    DeployedContract contract = await ethService.loadContractWithGivenAddress(
        "bscSynchronizer", EthereumAddress.fromHex(this.marketMaker));
    ContractInputData info = oracles[0];

    return ethService.submit(
        await credentials,
        contract,
        "sellFor",
        [
          await address,
          info.getMultiplier(),
          EthereumAddress.fromHex(tokenAddress),
          EthereumService.getWei(amount),
          info.getFee(),
          [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
          [oracles[0].getPrice(), oracles[1].getPrice()],
          [oracles[0].signs['sell']!.getV(), oracles[1].signs['sell']!.getV()],
          [oracles[0].signs['sell']!.getR(), oracles[1].signs['sell']!.getR()],
          [oracles[0].signs['sell']!.getS(), oracles[1].signs['sell']!.getS()],
        ],
        gas: gas);
  }
  @override
  Future<String> getUsedCap() async {
    DeployedContract contract = await ethService.loadContractWithGivenAddress(
        "bscSynchronizer", EthereumAddress.fromHex(this.marketMaker));
    final res = await ethService.query(contract, "remainingDollarCap", []);
    return EthereumService.fromWei(res.single, "ether");
  }
  @override
  Future<Transaction> makeBuyTransaction(
      String tokenAddress, String amount, List<ContractInputData> oracles,
      {String? maxPrice}) async {
    DeployedContract contract = await ethService.loadContractWithGivenAddress(
        "bscSynchronizer", EthereumAddress.fromHex(this.marketMaker));
    ContractInputData info = oracles[0];

    return await ethService.makeTransaction(
      await credentials,
      contract,
      "buyFor",
      [
        await address,
        info.getMultiplier(),
        EthereumAddress.fromHex(tokenAddress),
        EthereumService.getWei(amount),
        info.getFee(),
        [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
        [oracles[0].getPrice(), oracles[1].getPrice()],
        [oracles[0].signs['buy']!.getV(), oracles[1].signs['buy']!.getV()],
        [oracles[0].signs['buy']!.getR(), oracles[1].signs['buy']!.getR()],
        [oracles[0].signs['buy']!.getS(), oracles[1].signs['buy']!.getS()],
      ],
    );
  }
  @override
  Future<Transaction> makeSellTransaction(
      tokenAddress, String amount, List<ContractInputData> oracles) async {
    DeployedContract contract = await ethService.loadContractWithGivenAddress(
        "bscSynchronizer", EthereumAddress.fromHex(this.marketMaker));
    ContractInputData info = oracles[0];

    return ethService.makeTransaction(await credentials, contract, "sellFor", [
      await address,
      info.getMultiplier(),
      EthereumAddress.fromHex(tokenAddress),
      EthereumService.getWei(amount),
      info.getFee(),
      [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
      [oracles[0].getPrice(), oracles[1].getPrice()],
      [oracles[0].signs['sell']!.getV(), oracles[1].signs['sell']!.getV()],
      [oracles[0].signs['sell']!.getR(), oracles[1].signs['sell']!.getR()],
      [oracles[0].signs['sell']!.getS(), oracles[1].signs['sell']!.getS()],
    ]);
  }
}
