import '../../core/database/chain.dart';
import '../../core/widgets/selection_button.dart';
import '../../locator.dart';
import '../../routes/navigation_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

// ignore: must_be_immutable
class AddChainScreen extends StatefulWidget {
  Chain? chain;

  AddChainScreen({this.chain});

  @override
  _AddChainScreenState createState() => _AddChainScreenState();
}

class _AddChainScreenState extends State<AddChainScreen> {
  final darkGrey = const Color(0xFF1C1C1C);
  late TextEditingController chainNameController;
  late TextEditingController blockExplorerUrlController;
  late TextEditingController chainIdController;
  late TextEditingController RPCController;
  late TextEditingController currencySymbolController;

  bool? rpcConfirmed;

  @override
  void initState() {
    super.initState();
    chainNameController =
        new TextEditingController(text: widget.chain?.name ?? "");
    blockExplorerUrlController =
        new TextEditingController(text: widget.chain?.blockExplorerUrl ?? "");
    chainIdController =
        new TextEditingController(text: widget.chain?.id.toString() ?? "");
    RPCController =
        new TextEditingController(text: widget.chain?.RPC_url ?? "");
    currencySymbolController =
        new TextEditingController(text: widget.chain?.currencySymbol ?? "");

    rpcConfirmed = false;

    // ignore: invalid_use_of_protected_member
    if (!RPCController.hasListeners) {
      RPCController.addListener(() async {
        try {
          final String url = RPCController.text.toString();
          final Client httpClient = new Client();
          final Web3Client ethClient = new Web3Client(url, httpClient);
          final bool isActive = await ethClient.isListeningForNetwork();
          if (isActive) {
            final int chainId = await ethClient.getNetworkId();
            setState(() {
              rpcConfirmed = true;
              chainIdController.text = chainId.toString();
            });
          } else {
            setState(() {
              rpcConfirmed = false;
            });
          }
        } catch (e) {
          setState(() {
            rpcConfirmed = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(MyColors.kAddressBorder).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(MyColors.kAddressBorder))),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        widget.chain != null ? "Edit Network" : 'Add Network',
                        style: MyStyles.whiteMediumTextStyle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        locator<NavigationService>().goBack(context);
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 18,
                              ),
                              Text(
                                'BACK',
                                style: MyStyles.whiteMediumTextStyle,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              form(),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: SelectionButton(
                  label: widget.chain != null ? "Save Changes" : 'Add Network',
                  onPressed: (bool selected) async {
                    if (rpcConfirmed ?? false) {
                      try {
                        final Chain chain = new Chain(
                            id: int.parse(chainIdController.text.toString()),
                            name: chainNameController.text.toString(),
                            RPC_url: RPCController.text.toString(),
                            blockExplorerUrl:
                                blockExplorerUrlController.text.toString());
                        locator<NavigationService>().goBack(context, chain);
                        // ignore: empty_catches
                      } on Exception {}
                    }
                  },
                  selected: true,
                  gradient: MyColors.greenToBlueGradient,
                  textStyle: MyStyles.blackMediumTextStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Network Name',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                color: const Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: chainNameController,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'New RPC Url',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                color: const Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: RPCController,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )),
        Visibility(
          visible: RPCController.text.toString().isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 5, top: 6),
            child: Text(
              rpcConfirmed ?? false
                  ? 'RPC url confirmed'
                  : 'RPC url is not valid',
              style: TextStyle(
                  fontSize: 12,
                  color: rpcConfirmed ?? false ? Colors.green : Colors.red),
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Chain Id',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                color: const Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: chainIdController,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Currency Symbol (Optional)',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                color: const Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: currencySymbolController,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Block Explorer Url (Optional)',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                color: const Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: blockExplorerUrlController,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )),
        const SizedBox(
          height: 24,
        ),
      ],
    );
  }
}
