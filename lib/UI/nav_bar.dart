import 'package:flutter/material.dart';

class navBarWidget extends StatefulWidget {
  const navBarWidget({super.key});

  @override
  State<navBarWidget> createState() => _navBarWidgetState();
}

class _navBarWidgetState extends State<navBarWidget> {
  int items = 5;
  double iconSize = 36;
  double iconScale = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.all(Radius.circular(24))),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  items,
                  (index) => GestureDetector(
                        onTap: () => print('Tapped on $index'),
                        child: SizedBox(
                            height: iconSize,
                            width: iconSize,
                            child: Transform.scale(
                              scale: iconScale,
                              child: const Icon(Icons.home),
                            )),
                      )))),
    );
  }
}
