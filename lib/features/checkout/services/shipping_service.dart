import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/shipping_rate.dart';

class ShippingService {
  Future<List<ShippingRate>> getRates({
    required String addressId,
    required String cartToken,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.shippingRates,
      body: {
        'addressId': addressId,
        'cartToken': cartToken,
      },
    );
    final ratesJson = response['rates'] as List;
    return ratesJson.map((r) => ShippingRate.fromJson(r)).toList();
  }

  Future<ShippingRate> selectRate({
    required String rateId,
    required String cartToken,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.selectShippingRate,
      body: {
        'rateId': rateId,
        'cartToken': cartToken,
      },
    );
    return ShippingRate.fromJson(response['selectedRate']);
  }
}