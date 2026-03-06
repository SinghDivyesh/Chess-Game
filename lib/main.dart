import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_board.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  static var myNewFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: Colors.black, letterSpacing: 3));
  static var myNewFontWhite = GoogleFonts.pressStart2p(
      textStyle: TextStyle(
        color: Colors.white,
        letterSpacing: 3,
      ));
  @override
  Widget build(BuildContext context) {
   // final color = Colors.white;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                      child: Text(
                        textAlign: TextAlign.center,
                        "CHESS MANIA",
                        softWrap: true,
                        style: myNewFontWhite.copyWith(fontSize: 30),
                        
                      ),
                    ),
                  )),
             // SizedBox(height: 5,),
              Expanded(
                flex: 2,
                child: AvatarGlow(
                  endRadius: 140,
                  duration: Duration(seconds: 2),
                  glowColor: Colors.white,
                  repeat: true,
                  repeatPauseDuration: Duration(seconds: 1),
                  startDelay: Duration(seconds: 1),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          style: BorderStyle.none,
                        ),
                        shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      radius: 80.0,
                      child: Image.asset(
                        'assets/piece/intro.png',
                        //color: Colors.white,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              ),
             // SizedBox(height: -5,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "created by Divyesh ",
                    style: myNewFontWhite.copyWith(fontSize: 20),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameBoard()),
                  );
                },
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 40.0, right: 40, bottom: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                        padding: EdgeInsets.all(30),
                        color: Colors.white,
                        child: Center(
                            child: Text(
                              "PLAY GAME",
                              style: myNewFont,
                            ))),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

