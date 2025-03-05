import 'package:flutter/material.dart';

class NavBarWidget extends StatefulWidget {
  final double height;
  const NavBarWidget({super.key, this.height = 40});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  int numItems = 5;
  double iconSize = 36;
  double iconScale = 1;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.height),
        child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(24))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    numItems,
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
      ),
    );
  }
}
