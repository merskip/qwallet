import 'package:flutter/cupertino.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/business_entity.dart';
import 'package:qwallet/whitelist_api.dart';

class BusinessEntityRepository {
  final WhitelistAPI whiteListApi = WhitelistAPI();
  final FirebaseService firebaseService = FirebaseService.instance;

  Future<BusinessEntity> getBusinessEntity({@required String nip}) async {
    final cachedEntity = await firebaseService.getBusinessEntity(nip);
    if (cachedEntity != null) return cachedEntity;

    final entityName = await whiteListApi.fetchEntityNameByNip(nip);
    await firebaseService.addBusinessEntity(nip, entityName);
    return BusinessEntity(nip: nip, name: entityName);
  }
}
