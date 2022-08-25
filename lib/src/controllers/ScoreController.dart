import 'package:rx_notifier/rx_notifier.dart';

class ScoreController {

  final percentage = RxNotifier<int>(0);
  final bannerChecked = RxNotifier<bool>(false); // TODO: false
  final calculationIsFinished = RxNotifier<bool>(false);

  Future<int> calculatePercentage(int totalHits) async {

    double percentage = (totalHits / 65) * 100;
    int percentageFormated = int.parse(percentage.toStringAsFixed(0));

    return percentageFormated;
  }


// TODO: testar se quando chega na questão 65 vai finalizar o quiz

// TODO: testar o random das questões

// TODO: testar se ao passar a ser assinante o banner some o o timer aparece


// Falta desenvolver

// TODO: Criar historico dos simulados na tela resultado


}