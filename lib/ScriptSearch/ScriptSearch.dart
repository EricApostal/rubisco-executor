import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_search/dropdown_search.dart';



class ScriptSearchWidget extends StatelessWidget {
  const ScriptSearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
            width: MediaQuery.of(context).size.width - 80,
            height: MediaQuery.of(context).size.height - 50,
            decoration: const BoxDecoration(color: Color(0xFF13141A)),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Color(0xff222735),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: SvgPicture.asset(
                                "assets/search.svg",
                                colorFilter: const ColorFilter.mode(
                                  Color.fromARGB(255, 255, 255, 255),
                                  BlendMode.srcIn,
                                ),
                                semanticsLabel: 'Search',
                              ),
                            ),
                          ),
                          Container(
                      height: 50,
                      width: 300,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 148, 149, 153),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                          )
                        ],
                      )),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 80,
                    height: MediaQuery.of(context).size.height - 124,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                              height: 120,
                              decoration: const BoxDecoration(
                                  color: Color(0xff222735),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )));
  }
}
