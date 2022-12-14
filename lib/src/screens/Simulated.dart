import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:awsquiz/src/helpers/Constants.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:awsquiz/src/helpers/MyInAppPurchase.dart';
import 'package:awsquiz/src/controllers/SimulatedController.dart';

class Simulated extends StatefulWidget {
  const Simulated({Key key}) : super(key: key);

  @override
  _SimulatedState createState() => _SimulatedState();
}

class _SimulatedState extends State<Simulated> {

  static MyInAppPurchase myInAppPurchase = MyInAppPurchase();
  static SimulatedController simulatedController = SimulatedController();

  @override
  void initState() {
    super.initState();
    simulatedController.loadRewardAdsUnity();
    simulatedController.loadQuestion(context);
    // Iniciando o timer do simulado -> 90 min
    simulatedController.timerSimulated(context);

    myInAppPurchase.checkStatusSubscription().then((status) {
      if(status == true) {
        simulatedController.isSubscriber.value = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return simulatedController.closeSimulated(context);
      },
      child: Scaffold(
        backgroundColor: myDarkBlueColor,
        body: RxBuilder(
          builder: (BuildContext context){
            return SafeArea(
              child: simulatedController.showSimulated.value
                ?
              myBody(context)
                :
              myCircularProgressIndicator(context, myWhiteColor),
            );
          },
        ),
      ),
    );
  }

  Widget myBody(BuildContext context) {
    return RxBuilder(
      builder: (BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded( // banner
                flex: 0,
                child: Container(
                  // color: Colors.purpleAccent,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top:10, bottom: 10),
                  child: simulatedController.isSubscriber.value
                    ?
                  noBanner()
                    :
                  myBannerUnity(), // TODO: BANNER ADS
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  // color: Colors.yellow,
                  alignment: Alignment.center,
                  child: simulatedController.isSubscriber.value
                    ?
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.tealAccent,
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(bottom: 10, right: 2),
                          child: Text(
                            '${simulatedController.minutes.value.toString()} m',
                            style: TextStyle(
                              fontFamily: 'AWS',
                              color: myWhiteColor,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible,
                              fontSize: MediaQuery.of(context).size.height * 2 / 100,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.deepOrange,
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(bottom: 10, left: 2),
                          child: Text(
                            '${simulatedController.seconds.value.toString()} s',
                            style: TextStyle(
                              fontFamily: 'AWS',
                              color: myWhiteColor,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible,
                              fontSize: MediaQuery.of(context).size.height * 2 / 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                    :
                  noTimer()
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  // color: Colors.yellow,
                  alignment: Alignment.center,
                  child: Text(
                    'QUEST??O ${simulatedController.questionNumber.value.toString()}/65',
                    style: TextStyle(
                      fontFamily: 'AWS',
                      color: myWhiteColor,
                      fontWeight: FontWeight.normal,
                      overflow: TextOverflow.visible,
                      fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top:10, bottom: 10),
                  decoration: const BoxDecoration(
                    color: myWhiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        blurRadius: 10,
                        color: myShadowColor,
                        offset: Offset(0.0, 0.75),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          // color: Colors.purple,
                          alignment: Alignment.center,
                          child: Text(
                            simulatedController.textQuestion.value.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'AWS',
                              color: myDarkBlueColor,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.visible,
                              fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            // color: Colors.yellow,
                            borderRadius: BorderRadius.circular(25),
                            border:  Border.all(
                              width: 3,
                              color: simulatedController.firstAlternativeColor.value,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  // color: Colors.tealAccent,
                                  margin: const EdgeInsets.all(5),
                                  child: Text(
                                    simulatedController.textFirstAlternative.value.toString(),
                                    style: TextStyle(
                                      fontFamily: 'AWS',
                                      color: myDarkBlueColor,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.visible,
                                      fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  child: Checkbox(
                                    activeColor: myGreenColor,
                                    value: simulatedController.firstCheckboxIsSelected.value,
                                    onChanged: (checked) {
                                      simulatedController.firstCheckboxIsSelected.value = checked;
                                      simulatedController.secondCheckboxIsSelected.value = false;
                                      simulatedController.thirdCheckboxIsSelected.value = false;
                                      simulatedController.fourthCheckboxIsSelected.value = false;
                                      print('check box 1 ticado: ${simulatedController.firstCheckboxIsSelected.value.toString()}');
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            // color: Colors.purpleAccent,
                            borderRadius: BorderRadius.circular(25),
                            border:  Border.all(
                              width: 3,
                              color: simulatedController.secondAlternativeColor.value,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  // color: Colors.tealAccent,
                                  margin: const EdgeInsets.all(5),
                                  child: Text(
                                    simulatedController.textSecondAlternative.value.toString(),
                                    style: TextStyle(
                                      fontFamily: 'AWS',
                                      color: myDarkBlueColor,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.visible,
                                      fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  child: Checkbox(
                                    activeColor: myGreenColor,
                                    value: simulatedController.secondCheckboxIsSelected.value,
                                    onChanged: (checked) {
                                      simulatedController.secondCheckboxIsSelected.value = checked;
                                      simulatedController.firstCheckboxIsSelected.value = false;
                                      simulatedController.thirdCheckboxIsSelected.value = false;
                                      simulatedController.fourthCheckboxIsSelected.value = false;
                                      print('check box 2 ticado: ${simulatedController.secondCheckboxIsSelected.value.toString()}');
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            // color: Colors.yellow,
                            borderRadius: BorderRadius.circular(25),
                            border:  Border.all(
                              width: 3,
                              color: simulatedController.thirdAlternativeColor.value,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  // color: Colors.lightGreen,
                                  margin: const EdgeInsets.all(5),
                                  child: Text(
                                    simulatedController.textThirdAlternative.value.toString(),
                                    style: TextStyle(
                                      fontFamily: 'AWS',
                                      color: myDarkBlueColor,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.visible,
                                      fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  child: Checkbox(
                                    activeColor: myGreenColor,
                                    value: simulatedController.thirdCheckboxIsSelected.value,
                                    onChanged: (checked) {
                                      simulatedController.thirdCheckboxIsSelected.value = checked;
                                      simulatedController.firstCheckboxIsSelected.value = false;
                                      simulatedController.secondCheckboxIsSelected.value = false;
                                      simulatedController.fourthCheckboxIsSelected.value = false;
                                      print('check box 3 ticado: ${simulatedController.thirdCheckboxIsSelected.value.toString()}');
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            // color: Colors.black54,
                            borderRadius: BorderRadius.circular(25),
                            border:  Border.all(
                              width: 3,
                              color: simulatedController.fourthAlternativeColor.value,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  // color: Colors.tealAccent,
                                  margin: const EdgeInsets.all(5),
                                  child: Text(
                                    simulatedController.textFourthAlternative.value.toString(),
                                    style: TextStyle(
                                      fontFamily: 'AWS',
                                      color: myDarkBlueColor,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.visible,
                                      fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  child: Checkbox(
                                    activeColor: myGreenColor,
                                    value: simulatedController.fourthCheckboxIsSelected.value,
                                    onChanged: (checked) {
                                      simulatedController.fourthCheckboxIsSelected.value = checked;
                                      simulatedController.firstCheckboxIsSelected.value = false;
                                      simulatedController.secondCheckboxIsSelected.value = false;
                                      simulatedController.thirdCheckboxIsSelected.value = false;
                                      print('check box 4 ticado: ${simulatedController.fourthCheckboxIsSelected.value.toString()}');
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  // color: Colors.purple,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    child: Text(
                      'CONFIRMAR',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myDarkBlueColor,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.visible,
                        fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: myOrangeColor,
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      simulatedController.validateForm(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget noTimer() {
    return Container();
  }

  Widget noBanner() {
    return Container();
  }

  Widget myBannerUnity() {
    return UnityBannerAd(
      placementId: 'Banner_Android',
      onLoad: (placementId) {
        debugPrint('Banner loaded: $placementId');
      } ,
      onClick: (placementId) {
        debugPrint('Banner clicked: $placementId');
      } ,
      onFailed: (placementId, error, message) {
        debugPrint('Banner failed to load');
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
    simulatedController.resetAccountants();
    print('DISPOSED SIMULATED SCREEN');
  }

}