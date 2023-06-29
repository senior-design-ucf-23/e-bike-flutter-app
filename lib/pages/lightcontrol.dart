import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class LightPage extends StatefulWidget {
  const LightPage({super.key});

  final String title = 'Light Control';

  @override
  State<LightPage> createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  late Color dialogSelectColor;

  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

  @override
  void initState() {
    dialogSelectColor = const Color(0xFFA239CA);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          children: <Widget>[
            Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Select light color: ',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  )),
              ColorIndicator(
                  width: 40,
                  height: 40,
                  borderRadius: 0,
                  color: dialogSelectColor,
                  elevation: 1,
                  onSelectFocus: false,
                  onSelect: () async {
                    // Wait for the dialog to return color selection result.
                    final Color newColor = await showColorPickerDialog(
                      // The dialog needs a context, we pass it in.
                      context,
                      // We use the dialogSelectColor, as its starting color.
                      dialogSelectColor,
                      title: Text('Select Color',
                          style: Theme.of(context).textTheme.titleMedium),
                      width: 40,
                      height: 40,
                      spacing: 0,
                      runSpacing: 0,
                      borderRadius: 0,
                      wheelDiameter: 165,
                      enableOpacity: true,
                      showColorCode: true,
                      colorCodeHasColor: true,
                      pickersEnabled: <ColorPickerType, bool>{
                        ColorPickerType.wheel: true,
                      },
                      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                        copyButton: false,
                        pasteButton: false,
                        longPressMenu: true,
                      ),
                      actionButtons: const ColorPickerActionButtons(
                        okButton: true,
                        closeButton: true,
                        dialogActionButtons: false,
                      ),
                      transitionBuilder: (BuildContext context,
                          Animation<double> a1,
                          Animation<double> a2,
                          Widget widget) {
                        final double curvedValue =
                            Curves.easeInOutBack.transform(a1.value) - 1.0;
                        return Transform(
                          transform: Matrix4.translationValues(
                              0.0, curvedValue * 200, 0.0),
                          child: Opacity(
                            opacity: a1.value,
                            child: widget,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                      constraints: const BoxConstraints(
                          minHeight: 480, minWidth: 320, maxWidth: 320),
                    );
                    setState(() {
                      dialogSelectColor = newColor;
                    });
                  }),
            ]),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back')),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  '', //'${ColorTools.materialNameAndCode(dialogSelectColor, colorSwatchNomeMap: colorsNameMap)}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                )),
          ],
        ),
      ),
    );
  }
}
