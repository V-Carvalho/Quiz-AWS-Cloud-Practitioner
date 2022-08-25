import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:awsquiz/src/widgets/MySnackBar.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class MyInAppPurchase {

  // Status da assinatura
  bool statusSubscription;

  // Resualtdo ao validar compra da assinatura
  String finishTransaction;

  // Assinatura comprada
  List<IAPItem> subscriptionPurchased = [];

  // Lista de assinaturas disponíveis
  List<IAPItem> subscriptionsAvailableForSale = [];

  // Quando a compra da certo
  StreamSubscription<PurchasedItem> purchaseUpdatedSubscription;

  // Quando a compra da errado
  StreamSubscription<PurchaseResult> purchaseErrorSubscription;

  static MySnackBar mySnackBar = MySnackBar();

  // Iniciando conexão com a loja de assinaturas
  Future<void> initConnectionSubscriptionStore(BuildContext context) async {
    await FlutterInappPurchase.instance.initialize();

    // Listener - disparado quando a compra da certo
    purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((purchasedItemDetails) {
      finishTransactionBuySubscription(context, purchasedItemDetails.purchaseToken);
    });

    // Listener - disparado quando ocorre algo de errado no momento da compra
    purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      mySnackBar.showSnackBar(context, 'Falha ao processar assinatura!', 1);
    });
  }

  // Solicitando todas as assinaturas disponíveis
  Future<void> getSubscriptionsAvailableForSale(BuildContext context) async {
    subscriptionsAvailableForSale = await FlutterInappPurchase.instance.getSubscriptions(['premium_access']);

    if (subscriptionsAvailableForSale.length == 0) {
      mySnackBar.showSnackBar(context, 'Serviço indisponível', 1);
    } else {
      buySubscription(context, subscriptionsAvailableForSale[0].productId);
    }
  }

  // Comprando a assinatura
  Future<void> buySubscription(BuildContext context, String productId) async {
    try {
      // O retorno da compra será mostrado nos listener dentro de initConnectionSubscriptionStore
      await FlutterInappPurchase.instance.requestSubscription(productId);
    } catch (error) {

    }
  }

  // Finalizando/Validando compra da assinatura
  Future<void> finishTransactionBuySubscription(BuildContext context, String purchaseToken) async {
    finishTransaction = await FlutterInappPurchase.instance.acknowledgePurchaseAndroid(purchaseToken);

    var statusTransaction = json.decode(finishTransaction);

    print(statusTransaction['code']);

    if (statusTransaction['code'] == 'OK') {
      mySnackBar.showSnackBar(context, 'Parabéns, você é um usuário PREMIUM!', 1);
    } else {
      mySnackBar.showSnackBar(context, 'Falha ao processar assinatura!', 1);
    }
  }

  // Checando status da assinatura
  Future<bool> checkStatusSubscription() async {
    statusSubscription = await FlutterInappPurchase.instance.checkSubscribed(sku: 'premium_access');
    return statusSubscription;
  }

  void disposeStreamSubscription() {
    purchaseErrorSubscription.cancel();
    purchaseUpdatedSubscription.cancel();
    FlutterInappPurchase.instance.finalize();
  }

}