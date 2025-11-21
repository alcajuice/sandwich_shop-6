class PricingRepository {
  double calculatePrice({required int quantity, required bool isFootlong}) {
    double price = 0.0;

    if (isFootlong) {
      price = 11.00;
    } else {
      price = 7.00;
    }

    return quantity * price;
  }
}
