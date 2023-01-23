import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myfirst/widgets/card_info.dart';
import 'package:myfirst/utils/game_utils.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //setting text style
  TextStyle whiteText = TextStyle(color: Colors.white);
  bool hideTest = false;
  int i = 0; // keeping track of live lines
  Game _game = Game();

  //game stats
  int tries = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _game.initGame();
  }

  void reset() {
    Navigator.pop(context, 'PLAY AGAIN'); // dismisses the alert dialog
    setState(() {
      score = 0;
      tries = 0;
      _game.initGame();
    });
  }

  void gamewon() {
    setState(() {
      if (score == 800) {
        _showdialog();
      }
    });
  }

  void _showdialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title:
              Text("YOU WON", selectionColor: Colors.blue[900], maxLines: 35),
          actionsPadding: EdgeInsets.only(right: 8, bottom: 8),
          content: Container(
            //height: 10.0,
            child: Lottie.asset("assets/images/youwon.json", fit: BoxFit.cover),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.pinkAccent)),
              child: const Text('PLAY AGAIN'),
              onPressed: () => reset(), //dismisses the alert box
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE55870),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "Memory Game",
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          //GridView.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder)
          Container(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _game.lives_lines.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Image.asset(_game.lives_lines[index]),
                    );
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // custom wigdet for score board
              card_info("Tries", "$tries"),
              card_info("Score", "$score"),
            ],
          ),
          SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                  itemCount: _game.gameImg!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  padding: EdgeInsets.all(18.0),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // here is all the game logic
                        print(_game.matchCheck);
                        setState(() {
                          //incrementing the clicks
                          if (_game.lives_lines.isNotEmpty) {
                            tries++;
                            _game.gameImg![index] = _game.cards_list[index];
                            _game.matchCheck
                                .add({index: _game.cards_list[index]});
                            print(_game.matchCheck.first);
                          }
                        });
                        // Timer.periodic(const Duration(milliseconds: 60),
                        //     (timer) {
                        //   if (score == 800) {
                        //     _showdialog();
                        //   }
                        // });
                        if (_game.matchCheck.length == 2) {
                          if (_game.matchCheck[0].values.first ==
                              _game.matchCheck[1].values.first) {
                            print("true");
                            //incrementing the score
                            score += 100;
                            gamewon();
                            _game.matchCheck.clear();
                          } else if (_game.lives_lines.isNotEmpty) {
                            // wrong cards flipped
                            print("false");
                            _game.lives_lines.remove(index);
                            index--;
                            Future.delayed(Duration(milliseconds: 500), () {
                              print(_game.gameColors);
                              setState(() {
                                _game.gameImg![_game.matchCheck[0].keys.first] =
                                    _game.hiddenCardpath;
                                _game.gameImg![_game.matchCheck[1].keys.first] =
                                    _game.hiddenCardpath;
                                _game.matchCheck.clear();
                              });
                            });
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                  title: Text("YOU LOST",
                                      selectionColor: Colors.blue[900],
                                      maxLines: 35),
                                  actionsPadding:
                                      EdgeInsets.only(right: 8, bottom: 8),
                                  content: Container(
                                    //height: 10.0,
                                    child: Lottie.asset(
                                        "assets/images/gameover.json",
                                        fit: BoxFit.cover),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.pinkAccent)),
                                      child: const Text('PLAY AGAIN'),
                                      onPressed: () =>
                                          reset(), //dismisses the alert box
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFB46A),
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: AssetImage(_game.gameImg![index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
