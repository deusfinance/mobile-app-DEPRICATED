import '../../../core/database/wallet_asset.dart';
import '../../../core/widgets/default_screen/default_screen.dart';
import '../../../core/widgets/selection_button.dart';
import '../../../locator.dart';
import '../../../models/wallet/wallet_asset_api.dart';
import '../../../routes/navigation_service.dart';
import 'cubit/add_wallet_asset_state.dart';
import '../../wallet_intro_screen/widgets/form/paper_input.dart';
import '../../../service/address_service.dart';
import '../../../statics/my_colors.dart';
import '../../../statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/add_wallet_asset_cubit.dart';

class AddWalletAssetScreen extends StatefulWidget {
  static const route = "/add_wallet_asset";

  @override
  _AddWalletAssetScreenState createState() => _AddWalletAssetScreenState();
}

class _AddWalletAssetScreenState extends State<AddWalletAssetScreen> {
  final darkGrey = const Color(0xFF1C1C1C);

  @override
  void initState() {
    context.read<AddWalletAssetCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddWalletAssetCubit, AddWalletAssetState>(
        builder: (context, state) {
      if (state is AddWalletAssetLoadingState) {
        return DefaultScreen(
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is AddWalletAssetErrorState) {
        return DefaultScreen(
          child: Center(
            child: Icon(Icons.refresh, color: MyColors.White),
          ),
        );
      } else {
        return DefaultScreen(
          child: _buildBody(state),
          // chainSelector: WalletChainSelector(
          //   selectedChain: state.selectedChain,
          //   chains: state.chains,
          //   onChainSelected: onChainSelected,
          //   addChain: addChain,
          //   deleteChain: deleteChain,
          // )
        );
      }
    });
  }

  Widget searchAssets(AddWalletAssetState state) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: darkGrey,
          ),
          child: PaperInput(
            textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
            hintText: 'Network Name or Address',
            maxLines: 1,
            controller: state.tokenSearchController,
          ),
        ),
        ListView.builder(
            itemCount: state.searchedWalletAssetApis?.length ?? 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final WalletAssetApi wa = state.searchedWalletAssetApis![index];
              return walletAssetApiCard(wa, state);
            }),
      ],
    );
  }

  Widget addCustomAsset(AddWalletAssetState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                'Token Contract Address',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: darkGrey,
              ),
              child: PaperInput(
                textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                hintText: '0x..',
                maxLines: 1,
                controller: state.tokenAddressController,
              ),
            ),
            Visibility(
              visible:
                  state.tokenAddressController.text.toString().isNotEmpty ||
                      state.visibleErrors,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 5, top: 6),
                child: Text(
                  state.addressConfirmed
                      ? 'token address confirmed'
                      : 'token address is not valid',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          state.addressConfirmed ? Colors.green : Colors.red),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                'Token Symbol',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: darkGrey,
              ),
              child: PaperInput(
                textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                hintText: '',
                maxLines: 1,
                controller: state.tokenSymbolController,
              ),
            ),
            Visibility(
              visible: state.tokenSymbolController.text.toString().isNotEmpty ||
                  state.visibleErrors,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 5, top: 6),
                child: Text(
                  state.symbolConfirmed
                      ? 'confirmed'
                      : 'symbol must be 11 characters or fewer',
                  style: TextStyle(
                      fontSize: 12,
                      color: state.symbolConfirmed ? Colors.green : Colors.red),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                'Token Decimal',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: darkGrey,
              ),
              child: PaperInput(
                textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                hintText: '18',
                maxLines: 1,
                controller: state.tokenDecimalController,
              ),
            ),
            Visibility(
              visible:
                  state.tokenDecimalController.text.toString().isNotEmpty ||
                      state.visibleErrors,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 5, top: 6),
                child: Text(
                  state.decimalConfirmed
                      ? 'confirmed'
                      : 'token decimal required',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          state.decimalConfirmed ? Colors.green : Colors.red),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: SelectionButton(
                label: 'Add Token',
                onPressed: (bool selected) async {
                  try {
                    if (state.decimalConfirmed &&
                        state.symbolConfirmed &&
                        state.addressConfirmed) {
                      final WalletAsset walletAsset = new WalletAsset(
                          walletAddress: (await locator<AddressService>()
                                  .getPublicAddress())
                              .hex,
                          chainId: state.chain.id,
                          tokenAddress:
                              state.tokenAddressController.text.toString(),
                          tokenDecimal: int.tryParse(state
                                  .tokenDecimalController.text
                                  .toString()) ??
                              18,
                          tokenSymbol:
                              state.tokenSymbolController.text.toString());
                      locator<NavigationService>().goBack(context, walletAsset);
                    } else {
                      context.read<AddWalletAssetCubit>().visibleErrors(true);
                    }
                    // ignore: empty_catches
                  } on Exception {}
                },
                selected: true,
                gradient: MyColors.greenToBlueGradient,
                textStyle: MyStyles.blackMediumTextStyle,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildBody(AddWalletAssetState state) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              context.read<AddWalletAssetCubit>().changeTab(0);
                            });
                          },
                          child: Center(
                              child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Search",
                              overflow: TextOverflow.ellipsis,
                              style: state is AddWalletAssetSearchState
                                  ? TextStyle(
                                      fontFamily: MyStyles.kFontFamily,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      foreground: Paint()
                                        ..shader = MyColors.greenToBlueGradient
                                            .createShader(const Rect.fromLTRB(
                                                0, 0, 50, 30)))
                                  : TextStyle(
                                      fontFamily: MyStyles.kFontFamily,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: MyColors.HalfWhite,
                                    ),
                            ),
                          )),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              context.read<AddWalletAssetCubit>().changeTab(1);
                            });
                          },
                          child: Center(
                              child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Custom Token",
                              overflow: TextOverflow.ellipsis,
                              style: state is AddWalletAssetCustomState
                                  ? TextStyle(
                                      fontFamily: MyStyles.kFontFamily,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      foreground: Paint()
                                        ..shader = MyColors.greenToBlueGradient
                                            .createShader(const Rect.fromLTRB(
                                                0, 0, 50, 30)))
                                  : TextStyle(
                                      fontFamily: MyStyles.kFontFamily,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: MyColors.HalfWhite,
                                    ),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: state is AddWalletAssetSearchState,
                          child: Container(
                              margin: const EdgeInsets.only(top: 3),
                              height: 2.0,
                              width: 40,
                              decoration: MyStyles.greenToBlueDecoration),
                        ),
                      ),
                      Expanded(
                        child: Visibility(
                          visible: state is AddWalletAssetCustomState,
                          child: Container(
                              margin: const EdgeInsets.only(top: 3),
                              height: 2.0,
                              width: 60,
                              decoration: MyStyles.greenToBlueDecoration),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              height: 25,
              thickness: 1,
              color: Colors.black,
            ),
            state is AddWalletAssetSearchState
                ? searchAssets(state)
                : addCustomAsset(state),
          ],
        ),
      ),
    );
  }

  Widget walletAssetApiCard(WalletAssetApi wa, AddWalletAssetState state) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child:
                CircleAvatar(radius: 20, backgroundImage: NetworkImage(wa.img)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(wa.symbol, overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    wa.address,
                    style: MyStyles.lightWhiteSmallTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              final WalletAsset walletAsset = new WalletAsset(
                  walletAddress:
                      (await locator<AddressService>().getPublicAddress()).hex,
                  chainId: state.chain.id,
                  tokenAddress: wa.address,
                  tokenSymbol: wa.symbol,
                  logoPath: wa.img,
                  // ignore: avoid_dynamic_calls
                  tokenDecimal: wa.decimals.runtimeType == int
                      ? wa.decimals
                      : int.tryParse(wa.decimals));
              locator<NavigationService>().goBack(context, walletAsset);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  borderRadius: const BorderRadius.all(Radius.circular(6))),
              child: const Text("ADD"),
            ),
          ),
        ],
      ),
    );
  }
}
