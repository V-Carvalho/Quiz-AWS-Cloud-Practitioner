import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:awsquiz/src/screens/Score.dart';
import 'package:awsquiz/src/helpers/Constants.dart';
import 'package:awsquiz/src/widgets/MySnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:awsquiz/src/helpers/MyInAppPurchase.dart';

class SimulatedController {

  final adsIsLoaded = RxNotifier<bool>(false);

  final bannerChecked = RxNotifier<bool>(false); // TODO: false
  final showSimulated = RxNotifier<bool>(false); // TODO: true

  final questionNumber = RxNotifier<int>(0);
  final indexQuestion = RxNotifier<int>(0);
  final indexAlternative = RxNotifier<int>(1);
  final totalHits = RxNotifier<int>(0);
  final totalErrors = RxNotifier<int>(0);

  final textQuestion = RxNotifier<String>('');

  final textFirstAlternative = RxNotifier<String>('');
  final textSecondAlternative = RxNotifier<String>('');
  final textThirdAlternative = RxNotifier<String>('');
  final textFourthAlternative = RxNotifier<String>('');

  final firstAlternativeColor = RxNotifier<Color>(borderDefaultColor);
  final secondAlternativeColor = RxNotifier<Color>(borderDefaultColor);
  final thirdAlternativeColor = RxNotifier<Color>(borderDefaultColor);
  final fourthAlternativeColor = RxNotifier<Color>(borderDefaultColor);

  final dialogIsOpen = RxNotifier<bool>(false);

  final responseIsCorrect = RxNotifier<bool>(false);

  final firstAlternativeIsCorrect = RxNotifier<bool>(false);
  final secondAlternativeIsCorrect = RxNotifier<bool>(false);
  final thirdAlternativeIsCorrect = RxNotifier<bool>(false);
  final fourthAlternativeIsCorrect = RxNotifier<bool>(false);

  final firstCheckboxIsSelected = RxNotifier<bool>(false);
  final secondCheckboxIsSelected = RxNotifier<bool>(false);
  final thirdCheckboxIsSelected = RxNotifier<bool>(false);
  final fourthCheckboxIsSelected = RxNotifier<bool>(false);

  static MySnackBar mySnackBar = MySnackBar();
  static MyInAppPurchase myInAppPurchase = MyInAppPurchase();

  Future<void> loadQuestion(BuildContext context) async {

    // Se questão atual for menor que 65, carrega uma nova questão
    if (questionNumber.value < 65) {
      questionNumber.value += 1;

      // Mostrar loading enquanto carrega outra questão
      showSimulated.value = false;

      // Realizando um select no banco onde o retorno tem que ser a pergunta conforme o id
      QuerySnapshot questions = await FirebaseFirestore.instance.collection('questionsSimulated')
          .where('id', isEqualTo: questionNumber.value)
          .get(const GetOptions(source: Source.serverAndCache));

      textQuestion.value = questions.docs[0]['question'];

      // Realizando um select no banco onde o retorno tem que ser as respostas conforme o id da questão
      QuerySnapshot answers = await FirebaseFirestore.instance.collection('questionsSimulated')
          .doc(questions.docs[0].id).collection('answers')
          .get(const GetOptions(source: Source.serverAndCache));

      // Percorrendo todos os docs(Respostas) retornados
      for( var i = 0 ; i < answers.docs.length; i++ ) {
        if (i == 0) {
          textFirstAlternative.value = answers.docs[i]['answer'];
          firstAlternativeIsCorrect.value = answers.docs[i]['correct'];
        }
        if (i == 1) {
          textSecondAlternative.value = answers.docs[i]['answer'];
          secondAlternativeIsCorrect.value = answers.docs[i]['correct'];
        }
        if (i == 2) {
          textThirdAlternative.value = answers.docs[i]['answer'];
          thirdAlternativeIsCorrect.value = answers.docs[i]['correct'];
        }
        if (i == 3) {
          textFourthAlternative.value = answers.docs[i]['answer'];
          fourthAlternativeIsCorrect.value = answers.docs[i]['correct'];
        }
      }

      // Mostrar simulado, questão já carregada
      showSimulated.value = true;

    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Score(
          totalHits: totalHits.value,
          totalErrors: totalErrors.value,
        )),
      );
    }

  }

  void validateForm(BuildContext context) {
    // Verificando se algum checkbox foi selecionado
    if (
        firstCheckboxIsSelected.value == true ||
        secondCheckboxIsSelected.value == true||
        thirdCheckboxIsSelected.value == true ||
        fourthCheckboxIsSelected.value == true
    ) {
      validateIsCorrect(context);
    } else {
      mySnackBar.showSnackBar(context, 'Escolha uma alternativa!');
    }
  }

  // Verificando se o usuario acertou
  void validateIsCorrect(BuildContext context) {
    // Verificando se deu match entre a escolha do usuario e a resposta correta
    if (firstCheckboxIsSelected.value == true && firstAlternativeIsCorrect.value == true) {
      responseIsCorrect.value = true;
      firstAlternativeColor.value = borderCorrectColor;
      dialogResponseCorrect(context);
    }
    if (secondCheckboxIsSelected.value == true && secondAlternativeIsCorrect.value == true) {
      responseIsCorrect.value = true;
      secondAlternativeColor.value = borderCorrectColor;
      dialogResponseCorrect(context);
    }
    if (thirdCheckboxIsSelected.value == true && thirdAlternativeIsCorrect.value == true) {
      responseIsCorrect.value = true;
      thirdAlternativeColor.value = borderCorrectColor;
      dialogResponseCorrect(context);
    }
    if (fourthCheckboxIsSelected.value == true && fourthAlternativeIsCorrect.value == true) {
      responseIsCorrect.value = true;
      fourthAlternativeColor.value = borderCorrectColor;
      dialogResponseCorrect(context);
    }

    // quando usuario errar entrará no if
    if (responseIsCorrect.value == false) {
      validateIsWrong(context);
    }
  }

  // Verificando se o usuario errou
  void validateIsWrong(BuildContext context) {
    /*verificando qual alternativa o usuario escolheu e pintando de vermelho,
     pois sua escolha esta errada
    */
    if (firstCheckboxIsSelected.value == true) {
      firstAlternativeColor.value = borderWrongColor;
      dialogResponseWrong(context);
    }
    if (secondCheckboxIsSelected.value == true) {
      secondAlternativeColor.value = borderWrongColor;
      dialogResponseWrong(context);
    }
    if (thirdCheckboxIsSelected.value == true) {
      thirdAlternativeColor.value = borderWrongColor;
      dialogResponseWrong(context);
    }
    if (fourthCheckboxIsSelected.value == true) {
      fourthAlternativeColor.value = borderWrongColor;
      dialogResponseWrong(context);
    }

    /*Verificando qual alternativa correta e pintando de verde,
     mostrando ao usuario qual a resposta corrreta
    */
    if (firstAlternativeIsCorrect.value == true) {
      firstAlternativeColor.value = borderCorrectColor;
    }
    if (secondAlternativeIsCorrect.value == true) {
      secondAlternativeColor.value = borderCorrectColor;
    }
    if (thirdAlternativeIsCorrect.value == true) {
      thirdAlternativeColor.value = borderCorrectColor;
    }
    if (fourthAlternativeIsCorrect.value == true) {
      fourthAlternativeColor.value = borderCorrectColor;
    }

  }

  void resetForm() {
    // Resetando variavel que valida questão
    responseIsCorrect.value = false;

    // Tirando a seleção dos checkboxs
    firstCheckboxIsSelected.value = false;
    secondCheckboxIsSelected.value = false;
    thirdCheckboxIsSelected.value = false;
    fourthCheckboxIsSelected.value = false;

    // Voltando a cor da borda das alternativas para a cor padrão
    firstAlternativeColor.value = borderDefaultColor;
    secondAlternativeColor.value = borderDefaultColor;
    thirdAlternativeColor.value = borderDefaultColor;
    fourthAlternativeColor.value = borderDefaultColor;
  }

  void resetAccountants() {
    // Resetando variaveis com os index do array de questões
    indexQuestion.value = 0;
    indexAlternative.value = 1;

    // Resetando variaveis com o total de erros e acertos
    totalHits.value = 0;
    totalErrors.value = 0;

    // Resetando variavel que controla em qual questão o usuarios esta | 1/65...
    questionNumber.value = 0;
  }

  Future<void> dialogResponseCorrect(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Acertou 👍',
            style: TextStyle(
              fontFamily: 'AWS',
              color: myGreenColor,
              fontWeight: FontWeight.bold,
            ),textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Parabéns, você acertou 👏!',
                  style: TextStyle(
                    fontFamily: 'AWS',
                    color: myDarkBlueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Próxima',
                style: TextStyle(
                  fontFamily: 'AWS',
                  color:myDarkBlueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                calculateHits(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> dialogResponseWrong(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Errou  😢',
            style: TextStyle(
              fontFamily: 'AWS',
              color: myRedColor,
              fontWeight: FontWeight.bold,
            ),textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Ops, infelizmente essa você errou, continue estudando!',
                  style: TextStyle(
                    fontFamily: 'AWS',
                    color: myDarkBlueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Próxima',
                style: TextStyle(
                  fontFamily: 'AWS',
                  color:myDarkBlueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                calculateErros(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> calculateHits(BuildContext context) async {
    // Fechando dialog dialogResponseCorrect
    Navigator.of(context).pop(false);

    // Somando a qtd de respostas corretas
    if (responseIsCorrect.value == true) {
      totalHits.value += 1;
      resetForm();
      indicateSignature(context);
    }
  }

  Future<void> calculateErros(BuildContext context) async {
    // Fechando dialog dialogResponseWrong
    Navigator.of(context).pop(false);

    // Somando a qtd de respostas erradas
    if (responseIsCorrect.value == false) {
      totalErrors.value += 1;
      resetForm();
      indicateSignature(context);
    }
  }

  Future<bool> closeSimulated(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              'Encerrar Simulado?',
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
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadRewardAdsUnity() async {
    // Carregando um anuncio
    UnityAds.load(
      placementId: 'Rewarded_Android',
      onComplete: (placementId) {
        adsIsLoaded.value = true;
      } ,
      onFailed: (placementId, error, message) {
        adsIsLoaded.value = false;
      },
    );
  }

  Future<void> showRewardAdsUnity() async {
    // Se o anuncio estiver carregado mostrar anuncio
    if (adsIsLoaded.value == true) {
      UnityAds.showVideoAd(
        placementId: 'Rewarded_Android',
        onStart: (placementId) {
          loadRewardAdsUnity();
          showSimulated.value = true;
        },
        onClick: (placementId) {
          loadRewardAdsUnity();
          showSimulated.value = true;
        },
        onSkipped: (placementId) {
          loadRewardAdsUnity();
          showSimulated.value = true;
        },
        onComplete: (placementId) {
          loadRewardAdsUnity();
          showSimulated.value = true;
        },
        onFailed: (placementId, error, message) {
          loadRewardAdsUnity();
          showSimulated.value = true;
        },
      );
    } else {
      loadRewardAdsUnity();
      showSimulated.value = true;
    }
  }

  void indicateSignature(BuildContext context) {
    // Verificando se está na hora de indicar uma assinatura
    if (questionNumber.value == 5 || questionNumber.value == 10 ||
        questionNumber.value == 15 || questionNumber.value == 20 ||
        questionNumber.value == 25 || questionNumber.value == 30
    ) {
      // Verificando se é assinante
      myInAppPurchase.checkStatusSubscription().then((isSubscriber) {
        // Se for assinante não mostra modal de assinatura
        if(isSubscriber == true) {
          loadQuestion(context);
          // Removendo o banner se o usuario passou a ser assinante
          bannerChecked.value = true;
        } else {
          myModalPremiumSubscription(context);
        }
      });
    } else {
      loadQuestion(context);
    }
  }

  void myModalPremiumSubscription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context){
        return WillPopScope(
          onWillPop: () {
            return null;
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rate_outlined,
                      color: myGoldColor,
                      size: MediaQuery.of(context).size.width * 8 / 100,
                    ),
                    Text(
                      'Seja um assinante PREMIUM!',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myDarkBlueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 5 / 100,
                      ),
                    ),
                    Icon(
                      Icons.star_rate_outlined,
                      color: myGoldColor,
                      size: MediaQuery.of(context).size.width * 8 / 100,
                    ),
                  ],
                ),
                const Divider(color: myDarkBlueColor, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.block,
                      color: myDarkBlueColor,
                      size: MediaQuery.of(context).size.width * 8 / 100,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Remoção dos anúncios.',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myRedColor,
                        fontWeight: FontWeight.normal,
                        fontSize: MediaQuery.of(context).size.width * 4 / 100,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.assignment,
                      color: myDarkBlueColor,
                      size: MediaQuery.of(context).size.width * 8 / 100,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Histórico dos simulados (Em breve).',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myRedColor,
                        fontWeight: FontWeight.normal,
                        fontSize: MediaQuery.of(context).size.width * 4 / 100,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: myDarkBlueColor,
                      size: MediaQuery.of(context).size.width * 8 / 100,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Timer durante os simulados (Em breve).',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myRedColor,
                        fontWeight: FontWeight.normal,
                        fontSize: MediaQuery.of(context).size.width * 4 / 100,
                      ),
                    ),
                  ],
                ),
                const Divider(color: myDarkBlueColor, thickness: 1.5),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        enableFeedback: true,
                        primary: myGoldColor,
                        alignment: Alignment.center,
                      ),
                      child: Text(
                        'Seja PREMIUM por apenas R\$ 9,99',
                        style: TextStyle(
                          fontFamily: 'AWS',
                          color: myRedColor,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 5 / 100,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        myInAppPurchase.getSubscriptionsAvailableForSale(context);
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    child: Text(
                      'Continuar',
                      style: TextStyle(
                        fontFamily: 'AWS',
                        color: myWhiteColor,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.visible,
                        fontSize: MediaQuery.of(context).size.height * 1.8 / 100,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: myDarkBlueColor,
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      // Fechando modal PremiumSubscription
                      Navigator.of(context).pop(false);

                      // Mudando o estado da variavel p/ assim aparecer um loading na tela enquanto carrega anúncio
                      showSimulated.value = false;

                      // Carrega outra questão nas variaveis
                      loadQuestion(context);

                      await Future.delayed(const Duration(seconds: 1));

                      // Mostrar anuncio
                      showRewardAdsUnity();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}