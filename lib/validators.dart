import 'package:Amplessimus/values.dart';

//this is currently unused, possible lists:
//['5','6','7','8','9','10','11','12','13','']
//['a','b','c','d','e','f','g','h','i','q','']
String Function(String) makeListValidator(List<String> list) {
  return (value) => list.contains(value.trim().toLowerCase())
      ? null
      : CustomValues.lang.widgetValidatorInvalid;
}

//only used in dev_options, so it might be removed some time
String numberValidator(String value) {
  value = value.trim();
  if (value.isEmpty) return CustomValues.lang.widgetValidatorFieldEmpty;
  final n = num.tryParse(value);
  return n == null || n < 0 ? CustomValues.lang.widgetValidatorInvalid : null;
}
