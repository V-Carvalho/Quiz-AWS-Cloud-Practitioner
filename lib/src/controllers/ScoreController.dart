import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:awsquiz/src/screens/Home.dart';
import 'package:awsquiz/src/helpers/Constants.dart';

class ScoreController {

  final percentage = RxNotifier<int>(0);
  final isSubscriber = RxNotifier<bool>(false); // TODO: false
  final calculationIsFinished = RxNotifier<bool>(false);

  Future<int> calculatePercentage(int totalHits) async {

    double percentage = (totalHits / 65) * 100;
    int percentageFormated = int.parse(percentage.toStringAsFixed(0));

    return percentageFormated;
  }

  Future<bool> closeSimulated(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              'Finalizar Simulado?',
              style: TextStyle(
                fontFamily: 'AWS',
                fontWeight: FontWeight.normal,
                color: const Color(0xFF182A50),
                fontSize: MediaQuery.of(context).size.width * 4 / 100,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Não',
                style: TextStyle(
                  fontFamily: 'AWS',
                  color: myDarkBlueColor,
                  fontWeight: FontWeight.normal,
                  fontSize: MediaQuery.of(context).size.width * 4 / 100,
                ),
              ),
              onPressed: (){
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Sim',
                style: TextStyle(
                  fontFamily: 'AWS',
                  color: myDarkBlueColor,
                  fontWeight: FontWeight.normal,
                  fontSize: MediaQuery.of(context).size.width * 4 / 100,
                ),
              ),
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),
          ],
        );
      },
    );
  }


}