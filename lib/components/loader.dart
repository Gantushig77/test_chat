import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool row;
  final double? height;
  final double? width;
  final double? progressHeight;
  final double? progressWidth;
  const Loader(
      {Key? key,
      this.row = false,
      this.height,
      this.width,
      this.progressHeight,
      this.progressWidth})
      : super(key: key);

  List<Widget> main({
    String? text,
    bool alignRow = false,
  }) {
    return [
      SizedBox(
        child: const CircularProgressIndicator(),
        width: progressWidth ?? 60,
        height: progressHeight ?? 60,
      ),
      Padding(
        padding: EdgeInsets.only(top: alignRow ? 0 : 16, left: alignRow ? 16 : 0),
        child: Text(
          text ?? 'Loading ...',
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height ?? MediaQuery.of(context).size.height - 250,
        width: width ?? MediaQuery.of(context).size.width,
        child: row
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: main(alignRow: row))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: main(alignRow: row)),
      ),
    );
  }
}
