import 'package:in_app_purchase/in_app_purchase.dart';


// 1.상품 정보 가져오기
Future<void> fetchProducts() async{
  final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(Set<String>.from(['']));

  if (response.notFoundIDs.isNotEmpty){
    print('상품을 찾을 수 없습니다.');
  }
  final ProductDetails productDetails = response.productDetails.first; // productDetails를 사용하여 UI 업데이트
}

// 2. 결제 시도
Future<void> initiatePurchase() async {
  final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
  final PurchaseResult response = await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);

  if (response.error != null){
    print("결제 오류");
  }
  // 결제 성공처리
}

// 3. 구매 확인
bool isPurchased() {
  final QueryPurchaseDetailsResponse response = InAppPurchase.instance.queryPasPurchase();
  if(response.error != null){
    // 구매 정보 조회 오류 처리
    return false;
  }
  final List<ProductDetails> purchases = response.pastPurchases;
  for(ProductDetails purchase in purchases){
    if(purchase.productID == ''){
      return true;
    }
  }
  return false;
}