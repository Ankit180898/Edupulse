import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:edupulse/app/core/values/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final LoadingType type;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 50.0,
    this.color,
    this.type = LoadingType.pulse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppColors.primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoader(loadingColor),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader(Color loadingColor) {
    switch (type) {
      case LoadingType.pulse:
        return SpinKitPulse(
          color: loadingColor,
          size: size,
        );
      case LoadingType.doubleBounce:
        return SpinKitDoubleBounce(
          color: loadingColor,
          size: size,
        );
      case LoadingType.wave:
        return SpinKitWave(
          color: loadingColor,
          size: size / 2,
        );
      case LoadingType.fadingCircle:
        return SpinKitFadingCircle(
          color: loadingColor,
          size: size,
        );
      case LoadingType.cubeGrid:
        return SpinKitCubeGrid(
          color: loadingColor,
          size: size,
        );
      case LoadingType.foldingCube:
        return SpinKitFoldingCube(
          color: loadingColor,
          size: size,
        );
      case LoadingType.threeInOut:
        return SpinKitThreeBounce(
          color: loadingColor,
          size: size / 3,
        );
      case LoadingType.ring:
        return SpinKitRing(
          color: loadingColor,
          lineWidth: 4.0,
          size: size,
        );
      case LoadingType.simple:
      default:
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
        );
    }
  }
}

enum LoadingType {
  simple,
  pulse,
  doubleBounce,
  wave,
  fadingCircle,
  cubeGrid,
  foldingCube,
  threeInOut,
  ring,
}
