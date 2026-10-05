import '../model/productModel.dart';

const products = [
  Product(
    id: 'regular-fit-slogan',
    name: 'Regular Fit Slogan',
    price: 1190,
    imageUrl:
        'https://images.unsplash.com/photo-1740711152088-88a009e877bb?q=80&w=880&auto=format&fit=crop',
    category: ProductCategory.tshirts,
  ),

  Product(
    id: 'regular-fit-polo',
    name: 'Regular Fit Polo',
    price: 1100,
    discount: '-52%',
    imageUrl:
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=687&auto=format&fit=crop',
    category: ProductCategory.tshirts,
  ),

  Product(
    id: 'regular-fit-black',
    name: 'Regular Fit Black',
    price: 1690,
    imageUrl:
        'https://images.unsplash.com/photo-1607345366928-199ea26cfe3e?q=80&w=687&auto=format&fit=crop',
    category: ProductCategory.jeans,
  ),

  Product(
    id: 'regular-fit-v-neck',
    name: 'Regular Fit V-Neck',
    price: 1290,
    imageUrl:
        'https://images.unsplash.com/photo-1607345366928-199ea26cfe3e?q=80&w=687&auto=format&fit=crop',
    category: ProductCategory.shoes,
  ),
];