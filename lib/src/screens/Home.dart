import 'package:flutter/material.dart';
import 'package:awsquiz/src/screens/Simulated.dart';
import 'package:awsquiz/src/helpers/Constants.dart';
import 'package:awsquiz/src/helpers/MyInAppPurchase.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  static MyInAppPurchase myInAppPurchase = MyInAppPurchase();

  @override
  void initState() {
    super.initState();
    // Realizando conexão com a Google Play
    myInAppPurchase.initConnectionSubscriptionStore(context).whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: myBody(context),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children:  [
                Expanded(
                  flex: 1,
                  child: Container(
                    //color: Colors.yellow,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Image.asset(
                      'assets/images/title.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    //color: Colors.pink,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Potencialize as suas chances de SUCESSO conquistando a sua primeira Certificação AWS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myWhiteColor,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.visible,
                        fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              //color: Colors.purpleAccent,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'O que você vai aprender?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AWS',
                  color: myWhiteColor,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible,
                  fontSize: MediaQuery.of(context).size.height * 1.5 / 100,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              //color: Colors.orange,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 5),
              child: ListView.builder(
                itemCount: contentList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* ${contentList[index]['content']}',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myWhiteColor,
                        fontWeight: FontWeight.normal,
                        overflow: TextOverflow.visible,
                        fontSize: MediaQuery.of(context).size.height * 1.5 / 100,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              //color: Colors.green,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 5),
              child: ElevatedButton(
                child: Text(
                  'Iniciar Simulado',
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
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Simulated()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}
