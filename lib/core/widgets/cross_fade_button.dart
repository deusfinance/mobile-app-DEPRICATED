import 'package:deus/core/widgets/disabled_button.dart';
import 'package:deus/screens/stake_screen/stake_screen.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

import 'filled_gradient_selection_button.dart';

class CrossFadeButton extends StatelessWidget {
  final VoidCallback onPressed;

  final String mergedButtonLabel;
  final String offButtonLabel;
  final String gradientButtonLabel;

  final bool showLoading;
  final bool showBothButtons;

  CrossFadeButton(
      {this.onPressed,
      this.showBothButtons,
      this.showLoading,
      this.mergedButtonLabel,
      this.offButtonLabel,
      this.gradientButtonLabel});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: Row(
          children: [
            Expanded(
              child: FilledGradientSelectionButton(
                onPressed: onPressed,
                label: gradientButtonLabel,
                textStyle: MyStyles.blackMediumTextStyle,
                gradient: MyColors.blueToGreenGradient,
              ),
            ),
            if (showBothButtons)
              SizedBox(
                width: 10,
              ),
            Expanded(
              child: DisabledButton(
                label: offButtonLabel,
                child: showLoading
                    ? SizedBox(
                        height: 21,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : null,
              ),
            )
          ],
        ),
        secondChild: SizedBox(
          width: double.infinity,
          child: FilledGradientSelectionButton(
              gradient: MyColors.blueToGreenGradient,
              onPressed: onPressed,
              label: mergedButtonLabel,
              textStyle: MyStyles.blackMediumTextStyle),
        ),
        crossFadeState: !showBothButtons
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 150));
  }
}
