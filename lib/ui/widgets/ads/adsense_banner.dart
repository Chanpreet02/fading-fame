import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'adsense_banner_stub.dart'
if (dart.library.html) 'adsense_banner_web.dart';

class AdsenseBanner extends StatelessWidget {
  final String adSlot;
  final double height;

  const AdsenseBanner({
    super.key,
    required this.adSlot,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? AdsenseBannerImpl(adSlot: adSlot, height: height)
        : const SizedBox.shrink();
  }
}
