import 'package:flutter_test/flutter_test.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

void main() {
  test('formatMoney formats INR without paise for whole rupees', () {
    expect(formatMoney(200000), contains('2,000'));
  });
}
