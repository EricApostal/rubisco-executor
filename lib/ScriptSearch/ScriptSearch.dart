import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ScriptSearch extends StatelessWidget {
  const ScriptSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
            width: MediaQuery.of(context).size.width - 80,
            height: MediaQuery.of(context).size.height - 60,
            decoration: const BoxDecoration(color: Color(0xFF13141A)),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Container(
                      height: 42,
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
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 13),
                              child: TextField(
                                cursorColor: Colors.white,
                                  style: TextStyle(
                                      color:
                                          Color(0xFFC8C8C8)),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  )

                                  //textColo: Color.fromARGB(255, 148, 149, 153),)
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: TextButton(
                              style: const ButtonStyle(splashFactory: NoSplash.splashFactory, ),
                              onPressed: () {},
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 11, 96, 214),
                                  borderRadius: BorderRadius.all( Radius.circular(12) )
                                ),
                                child: const Center(child: Text("Search",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 240, 240, 240)
                                ),
                                )),
                              ),
                            ),
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
                                      
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                              height: 120,
                              decoration: const BoxDecoration(
                                  color: Color(0xff222735),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
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
