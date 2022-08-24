import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:awsquiz/src/helpers/Constants.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:awsquiz/src/helpers/MyInAppPurchase.dart';
import 'package:awsquiz/src/controllers/ScoreController.dart';

class Score extends StatefulWidget {
  final int totalHits;
  final int totalErrors;

  const Score({Key key, this.totalHits, this.totalErrors}) : super(key: key);

  @override
  _ScoreState createState() => _ScoreState();
}

class _ScoreState extends State<Score> {

  static MyInAppPurchase myInAppPurchase = MyInAppPurchase();
  static ScoreController scoreController = ScoreController();

  @override
  void initState() {
    super.initState();

    myInAppPurchase.checkStatusSubscription().then((isSubscriber) {
      if(isSubscriber == true) {
        scoreController.bannerChecked.value = true;
      }
    });

   scoreController.calculatePercentage(widget.totalHits).then((percentage) {
     scoreController.percentage.value = percentage;
     scoreController.calculationIsFinished.value = true;
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myDarkBlueColor,
      body: RxBuilder(
        builder: (BuildContext context){
          return SafeArea(
            child: scoreController.calculationIsFinished.value
              ?
            myBody(context)
              :
            myCircularProgressIndicator(context, myWhiteColor),
          );
        },
      ),
    );
  }

  Widget myBody(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded( // banner
            flex: 0,
            child: Container(
              // color: Colors.purpleAccent,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top:10, bottom: 10),
              child: scoreController.bannerChecked.value
                ?
              noBanner()
                :
              myBannerUnity(), // TODO: BANNER ADS
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              // color: Colors.purpleAccent,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 5),
              child: scoreController.percentage.value >= 70
                ?
              Text(
                'Parabéns, você foi APROVADO 👏! Seu percentual de acerto foi de ${scoreController.percentage.value}%.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AWS',
                  color: myWhiteColor,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible,
                  fontSize: MediaQuery.of(context).size.height * 2 / 100,
                ),
              )
                :
              Text(
                'Você foi REPROVADO, Seu percentual de acerto foi de apenas ${scoreController.percentage.value}%. '
                    '\n Para obter a certificação é necessário acertar no mínimo 70% das questões.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AWS',
                  color: myWhiteColor,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible,
                  fontSize: MediaQuery.of(context).size.height * 2 / 100,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              // color: Colors.lightGreenAccent,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      // color: Colors.black,
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Pontuação',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AWS',
                          color: myWhiteColor,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.visible,
                          fontSize: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      // color: Colors.yellow,
                      alignment: Alignment.center,
                      child: Text(
                        'Total de erros: ${widget.totalErrors}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AWS',
                          color: myWhiteColor,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.visible,
                          fontSize: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      // color: Colors.teal,
                      alignment: Alignment.center,
                      child: Text(
                        'Total de acertos: ${widget.totalHits}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AWS',
                          color: myWhiteColor,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.visible,
                          fontSize: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
          Expanded( // banner
            flex: 0,
            child: Container(
              // color: Colors.purpleAccent,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top:10, bottom: 10),
              child: scoreController.bannerChecked.value
                ?
              noBanner()
                :
              myBannerUnity(), // TODO: BANNER ADS
            ),
          ),
        ],
      )
    );
  }

  Widget noBanner() {
    return Container();
  }

  Widget myBannerUnity() {
    return UnityBannerAd(
      placementId: 'Banner_Android',
      onLoad: (placementId) {
        print('Banner loaded: $placementId');
      } ,
      onClick: (placementId) {
        print('Banner clicked: $placementId');
      } ,
      onFailed: (placementId, error, message) {
        print('Banner failed to load');
      },
    );
  }

  Widget myCircularProgressIndicator(BuildContext context, Color color) {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
