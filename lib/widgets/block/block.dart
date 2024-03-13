import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:treatyourtree/widgets/block/block_piece.dart';


// ignore: must_be_immutable
class Boxes extends StatelessWidget {

  Boxes({super.key, required this.color,required this.blocktype, });
  var color;
  BlockType blocktype;

  Widget _buildSvgForType(BlockType type) {
    switch (type) {
      case BlockType.Water:
        return SvgPicture.asset("assets/images/WaterElement_block.svg");
      case BlockType.Land:
        return SvgPicture.asset("assets/images/LandElement_block.svg");
      // case BlockType.Fire:
      //   return SvgPicture.asset("assets/images/FireElement_block.svg");
      case BlockType.Seed:
        return SvgPicture.asset("assets/images/SeedElement_block.svg");
      default:
        return Container(); // Return a default widget if type is not recognized
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
      ), 
      child:_buildSvgForType(BlockType.Seed),
    );
  }
}