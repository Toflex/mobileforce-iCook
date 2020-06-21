import 'package:icook_mobile/ui/ui_helper.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// List of providers that provider transforms into a widget tree
/// with the main app as the child of that tree, so that the entire
/// app can use these streams anywhere there is a [BuildContext]
List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders
];

List<SingleChildWidget> independentServices = [];

List<SingleChildWidget> dependentServices = [];

//Place All ChangeNotifierProvider's separated by a comma ","
List<SingleChildWidget> uiConsumableProviders = [
  //example
  ChangeNotifierProvider<ThemeNotifier>(create: (context) => ThemeNotifier()),
];