import 'package:finances/components/conditional_tooltip.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class CategoryIconSquare extends StatelessWidget {
  final Color color;
  final IconPickerIcon icon;
  final void Function(Color, IconPickerIcon)? onChange;

  const CategoryIconSquare({
    super.key,
    required this.color,
    required this.icon,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ConditionalTooltip(
      message: 'Edit',
      showTooltip: onChange != null,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Material(
          child: InkWell(
            onTap: onChange != null
                ? () async {
                    await _onTap(context);
                  }
                : null,
            child: Ink(
              width: 40,
              height: 40,
              color: color,
              child: CategoryIcon(icon: icon, backgroundColor: color),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    var result = await showDialog<_DialogOption>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose what to change'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(_DialogOption.color),
            child: const Text('Color', textScaler: TextScaler.linear(1.3)),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(_DialogOption.icon),
            child: const Text('Icon', textScaler: TextScaler.linear(1.3)),
          ),
        ],
      ),
    );

    if (!context.mounted) {
      return;
    }

    var newIcon = icon;
    var newColor = color;

    switch (result) {
      case _DialogOption.color:
        newColor = await _colorPickerDialog(context);
        break;

      case _DialogOption.icon:
        if (!context.mounted) {
          return;
        }

        final icon = await showIconPicker(
          context,
          configuration: const SinglePickerConfiguration(
            closeChild: Text('Close'),
            iconSize: 35,
            showTooltips: true,
            iconPackModes: [
              IconPack.fontAwesomeIcons,
              IconPack.material,
            ],
          ),
        );

        if (icon != null) {
          newIcon = icon;
        }

        break;

      default:
        return;
    }

    onChange?.call(newColor, newIcon);
  }

  Future<Color> _colorPickerDialog(BuildContext context) async {
    return await showColorPickerDialog(
      context,
      color,
      barrierColor: Colors.black54,
      wheelDiameter: 172,
      wheelSquarePadding: 8,
      wheelSquareBorderRadius: 0,
      showColorCode: true,
      colorCodeHasColor: true,
      enableShadesSelection: false,
      enableTonalPalette: true,
      tonalColorSameSize: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
      ),
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 250,
      ),
      tonalSubheading: const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Tones'),
      ),
    );
  }
}

enum _DialogOption {
  color,
  icon,
}

class CategoryIcon extends StatelessWidget {
  final IconPickerIcon icon;
  final Color backgroundColor;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon.data,
      size: icon.pack == IconPack.fontAwesomeIcons ? 20 : 24,
      color: backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
    );
  }
}
