import 'package:cartiva/features/home/model/productModel.dart';
import 'package:cartiva/core/superbase/superbase_client.dart';

class ProductRepository {
  Future<List<Product>> getProducts() async {

    final data = await supabase.from('products')
        .select()
        .order('created_at', ascending: false);

    return data
        .map((json) => Product.fromJson(json))
        .toList();
  }
}
