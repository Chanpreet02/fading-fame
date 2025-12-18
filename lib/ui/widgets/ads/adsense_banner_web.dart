// ignore_for_file: avoid_web_libraries_in_flutter, undefined_prefixed_name

import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

final Set<String> _registeredAds = {};

class AdsenseBannerImpl extends StatelessWidget {
  final String adSlot;
  final double height;

  const AdsenseBannerImpl({
    super.key,
    required this.adSlot,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final viewId = 'adsense-$adSlot';

    if (!_registeredAds.contains(viewId)) {
      _registeredAds.add(viewId);

      ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final ins = html.Element.tag('ins')
          ..setAttribute('class', 'adsbygoogle')
          ..setAttribute('style', 'display:block')
          ..setAttribute(
            'data-ad-client',
            'ca-pub-XXXXXXXXXXXXXXX', // client replace karega
          )
          ..setAttribute('data-ad-slot', adSlot)
          ..setAttribute('data-ad-format', 'auto')
          ..setAttribute('data-full-width-responsive', 'true');

        final script = html.ScriptElement()
          ..type = 'text/javascript'
          ..innerHtml =
              '(adsbygoogle = window.adsbygoogle || []).push({});';

        return html.DivElement()
          ..style.width = '100%'
          ..style.height = '${height}px'
          ..children.add(ins)
          ..children.add(script);
      });
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: HtmlElementView(viewType: viewId),
    );
  }
}
