import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:awsquiz/src/screens/Score.dart';
import 'package:awsquiz/src/helpers/Constants.dart';
import 'package:awsquiz/src/widgets/MySnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:awsquiz/src/helpers/MyInAppPurchase.dart';

class SimulatedController {

  List<int> listIdQuestionsGenerated = [];

  final adsIsLoaded = RxNotifier<bool>(false);
  final isSubscriber = RxNotifier<bool>(false); // TODO: false


  final showSimulated = RxNotifier<bool>(false);

  final minutes = RxNotifier<int>(0);
  final seconds = RxNotifier<int>(0);

  final questionNumber = RxNotifier<int>(0);

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

  Timer timer;

  int totalHits = 0;
  int totalErrors = 0;
  int randomQuestionId = 0;

  bool idQuestionIsUnique = false;

  Random random = Random();
  static MySnackBar mySnackBar = MySnackBar();
  static MyInAppPurchase myInAppPurchase = MyInAppPurchase();

  void timerSimulated(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      seconds.value++;
      if (seconds.value == 60) {
        minutes.value++;
        seconds.value = 0;
      }
      if (minutes.value == 90) {
        timer.cancel();
        minutes.value = 0;
        mySnackBar.showSnackBar(context, 'Tempo esgotado', 3);
      }
    });
  }

  Future<int> sortQuestion() async {
    idQuestionIsUnique = false;

    // Pegando todas as questões que tem no firebase
    QuerySnapshot totalDatabaseQuestions = await FirebaseFirestore.instance.collection('questionsSimulated')
        .get(const GetOptions(source: Source.serverAndCache));

    // Verificando se essa questão ja saiu p/ não haver questão repetida durante o simulado
    while(idQuestionIsUnique == false){
      // Escolhendo uma questão aleatoriamente dentre o total de questões que tem no firebase
      randomQuestionId = random.nextInt(totalDatabaseQuestions.docs.length) + 1;

      // Verificando as questões sorteadas, caso ja tenha sido sorteada gerar outra
      if (!listIdQuestionsGenerated.contains(randomQuestionId)){
        idQuestionIsUnique = true;
        listIdQuestionsGenerated.add(randomQuestionId);
        debugPrint('QUESTÃO SORTEADA: $randomQuestionId');
      }
    }

    return randomQuestionId;
  }

  Future<void> loadQuestion(BuildContext context) async {
    // Verificando se as 65 questões ja foram realizadas
    if (questionNumber.value < 65) {

      // Sorteando uma questão
      sortQuestion().then((id) async {

        // Contabilizando a qtd de questões que já foram realizadas
        questionNumber.value++;

        // Mostrar loading enquanto carrega outra questão
        showSimulated.value = false;

        // Realizando um select no banco onde o retorno tem que ser a pergunta conforme o id
        QuerySnapshot questions = await FirebaseFirestore.instance.collection('questionsSimulated')
            .where('id', isEqualTo: id)
            .get(const GetOptions(source: Source.server));

        // Atribuindo texto da questão na variavel
        textQuestion.value = questions.docs[0]['question'];

        // Realizando um select no banco onde o retorno tem que ser as respostas conforme o id da questão
        QuerySnapshot answers = await FirebaseFirestore.instance.collection('questionsSimulated')
            .doc(questions.docs[0].id).collection('answers')
            .get(const GetOptions(source: Source.serverAndCache));

        // Percorrendo todos os docs(Respostas) retornados e atribuindo as variaveis
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

      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Score(
          totalHits: totalHits,
          totalErrors: totalErrors,
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
      mySnackBar.showSnackBar(context, 'Escolha uma alternativa!', 1);
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

    // quando usuario errar entrará nesse if
    if (responseIsCorrect.value == false) {
      validateIsWrong(context);
    }
  }

  // Verificando se o usuario errou
  void validateIsWrong(BuildContext context) {
    /*Verificando qual alternativa o usuario escolheu e pintando de vermelho,
     pois sua escolha esta errada
    */
    if (firstCheckboxIsSelected.value == true) {
      firstAlternativeColor.value = borderWrongColor;
    }
    if (secondCheckboxIsSelected.value == true) {
      secondAlternativeColor.value = borderWrongColor;
    }
    if (thirdCheckboxIsSelected.value == true) {
      thirdAlternativeColor.value = borderWrongColor;
    }
    if (fourthCheckboxIsSelected.value == true) {
      fourthAlternativeColor.value = borderWrongColor;
    }

    /*Verificando qual alternativa correta e pintando de verde,
     para mostrar ao usuario qual a resposta correta
    */
    if (firstAlternativeIsCorrect.value == true) {
      firstAlternativeColor.value = borderCorrectColor;
      dialogResponseWrong(context, textFirstAlternative.value);
    }
    if (secondAlternativeIsCorrect.value == true) {
      secondAlternativeColor.value = borderCorrectColor;
      dialogResponseWrong(context, textSecondAlternative.value);
    }
    if (thirdAlternativeIsCorrect.value == true) {
      thirdAlternativeColor.value = borderCorrectColor;
      dialogResponseWrong(context, textThirdAlternative.value);
    }
    if (fourthAlternativeIsCorrect.value == true) {
      fourthAlternativeColor.value = borderCorrectColor;
      dialogResponseWrong(context, textFourthAlternative.value);
    }
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
                  'Parabéns, continue assim 👏!',
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

  Future<void> dialogResponseWrong(BuildContext context, String responseCorrect) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Você Errou  😢',
            style: TextStyle(
              fontFamily: 'AWS',
              color: myRedColor,
              fontWeight: FontWeight.bold,
            ),textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'A resposta correta é: $responseCorrect',
                  style: const TextStyle(
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
      totalHits++;
      resetForm();
      indicateSignature(context);
    }
  }

  Future<void> calculateErros(BuildContext context) async {
    // Fechando dialog dialogResponseWrong
    Navigator.of(context).pop(false);

    // Somando a qtd de respostas erradas
    if (responseIsCorrect.value == false) {
      totalErrors++;
      resetForm();
      indicateSignature(context);
    }
  }

  void indicateSignature(BuildContext context) {
    // Verificando se está na hora de indicar uma assinatura
    if (questionNumber.value == 5  || questionNumber.value == 10 ||
        questionNumber.value == 15 || questionNumber.value == 20 ||
        questionNumber.value == 25 || questionNumber.value == 30 ||
        questionNumber.value == 35 || questionNumber.value == 40 ||
        questionNumber.value == 45 || questionNumber.value == 50 ||
        questionNumber.value == 55 || questionNumber.value == 60
    ) {
      // Verificando se é assinante
      myInAppPurchase.checkStatusSubscription().then((status) {
        // Se for assinante não mostra modal de assinatura
        if(status == true) {
          loadQuestion(context);
          // Se o usuario passou a ser assinante
          isSubscriber.value = true; // Removendo o banner da tela e mostrando o timer
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
                      Icons.access_time,
                      color: myDarkBlueColor,
                      size: MediaQuery.of(context).size.width * 8 / 100,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Timer durante os simulados.',
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
                        'Seja PREMIUM por apenas R\$ 7,99',
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
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // Resetando as variaveis do formulário sempre que uma nova questão é gerada
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

  // Resetando as variaveis de controle quando o simulado for encerrado
  void resetAccountants() {
    // Cancelando o timer instanciado
    timer.cancel();

    // Resetando variaveis com o total de erros e acertos
    totalHits = 0;
    totalErrors = 0;

    // Resetando variaveis do cronômetro
    seconds.value = 0;
    minutes.value = 0;

    // Resetando variavel que controla em qual questão o usuarios esta | 1/65...
    questionNumber.value = 0;
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

}