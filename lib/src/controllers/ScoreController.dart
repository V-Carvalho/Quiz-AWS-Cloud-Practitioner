import 'package:flutter/material.dart';
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

// TODO: Parei aqui... Falta gerar o random das questões

// TODO: Criar um timer na tela do simulado

// TODO: Criar historico dos simulados na tela resultado


}