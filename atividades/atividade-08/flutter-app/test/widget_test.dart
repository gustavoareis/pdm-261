import 'package:carrinho_compras_estado/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('adiciona produto e atualiza carrinho', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartModel(),
        child: const ShoppingCartApp(),
      ),
    );

    expect(find.text('Loja Tech'), findsOneWidget);
    expect(find.text('Fone Bluetooth'), findsOneWidget);

    await tester.tap(find.text('Adicionar').first);
    await tester.pump();

    expect(find.text('1'), findsWidgets);

    await tester.tap(find.text('Carrinho'));
    await tester.pumpAndSettle();

    expect(find.text('1 itens no carrinho'), findsOneWidget);
    expect(find.text('R\$ 129,90'), findsWidgets);
  });
}
