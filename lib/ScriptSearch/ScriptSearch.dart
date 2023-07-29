import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_network/image_network.dart';

class SearchItem extends StatelessWidget {
  SearchItem({super.key, required this.scriptJson});

  var scriptJson;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 120,
        decoration: const BoxDecoration(
          color: Color(0xff222735),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: ImageNetwork(
                    image: "https://scriptblox.com/" + scriptJson["game"]["imageUrl"],
                    height: 150,
                    width: 150,
                    duration: 100,
                    curve: Curves.easeIn,
                    onPointer: true,
                    debugPrint: false,
                    fullScreen: false,
                    fitAndroidIos: BoxFit.cover,
                    fitWeb: BoxFitWeb.cover,
                    borderRadius: BorderRadius.circular(8),
                    onLoading: const CircularProgressIndicator(
                      color: Colors.indigoAccent,
                    ),
                    onError: const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    onTap: () {
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        scriptJson["title"],
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        scriptJson["game"]["name"],
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Color(0xFF969696), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScriptSearch extends StatefulWidget {
  const ScriptSearch({Key? key}) : super(key: key);

  @override
  State<ScriptSearch> createState() => _ScriptSearchState();
}

class _ScriptSearchState extends State<ScriptSearch> {
  String searchTerm = '';

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
                                  Color(0xFF41D1FE),
                                  BlendMode.srcIn,
                                ),
                                semanticsLabel: 'Search',
                              ),
                            ),
                          ),
                          Expanded(
                            // Search box
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 13),
                              child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchTerm = value;
                                    });
                                  },
                                  cursorColor: Colors.white,
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  )

                                  //textColo: Color.fromARGB(255, 148, 149, 153),)
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: TextButton(
                              style: const ButtonStyle(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              onPressed: () {},
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 11, 96, 214),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                child: const Center(
                                    child: Text(
                                  "Search",
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 240, 240, 240)),
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
                    child: FutureBuilder(
                      future: http.get(Uri.https(
                          'scriptblox.com',
                          'api/script/search',
                          {'q': searchTerm, 'mode': 'free'})),
                      builder: (context, snapshot) {
                        // if (snapshot.connectionState ==
                        //     ConnectionState.waiting) {
                        //   return Center(child: CircularProgressIndicator());
                        // }
                        var snapdata = snapshot.data;
                        if (snapdata == null) {
                          // print("DATA IS NULL, VERY BAD, PROGRAM WILL NOT WORK VERY WELL");
                          return Center(child: CircularProgressIndicator());
                        }
                        // print( snapdata.body);
                        dynamic data = json.decode(snapdata.body);
                        List allScripts = [];
                        data["result"]["scripts"].forEach((scriptData) {
                          allScripts.add(scriptData);
                        });

                        return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: allScripts.length,
                            itemBuilder: (BuildContext context, int index) {
                              // print(allScripts[index]["game"]["name"]);
                              return SearchItem(scriptJson: allScripts[index]);
                            });
                      },
                    ),
                  ),
                )
              ],
            )));
  }
}
