import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const ShoppingCartApp(),
    ),
  );
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final IconData icon;
  final Color color;
}

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get subtotal => product.price * quantity;
}

class CartModel extends ChangeNotifier {
  final List<Product> products = const [
    Product(
      id: 1,
      name: 'Fone Bluetooth',
      description: 'Audio limpo para estudar e programar.',
      price: 129.90,
      icon: Icons.headphones,
      color: Color(0xFF4F8A8B),
    ),
    Product(
      id: 2,
      name: 'Teclado Compacto',
      description: 'Layout leve para levar na mochila.',
      price: 189.50,
      icon: Icons.keyboard,
      color: Color(0xFFE07A5F),
    ),
    Product(
      id: 3,
      name: 'Mouse Sem Fio',
      description: 'Precisao e bateria de longa duracao.',
      price: 89.99,
      icon: Icons.mouse,
      color: Color(0xFF3D405B),
    ),
    Product(
      id: 4,
      name: 'Carregador USB-C',
      description: 'Carga rapida para celular e notebook.',
      price: 74.90,
      icon: Icons.battery_charging_full,
      color: Color(0xFF81B29A),
    ),
    Product(
      id: 5,
      name: 'Suporte para Celular',
      description: 'Base ajustavel para chamadas e aulas.',
      price: 39.90,
      icon: Icons.phone_android,
      color: Color(0xFFF2CC8F),
    ),
  ];

  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  int quantityFor(Product product) => _items[product.id]?.quantity ?? 0;

  void add(Product product) {
    final item = _items[product.id];
    if (item == null) {
      _items[product.id] = CartItem(product: product);
    } else {
      item.quantity++;
    }
    notifyListeners();
  }

  void removeOne(Product product) {
    final item = _items[product.id];
    if (item == null) {
      return;
    }

    if (item.quantity == 1) {
      _items.remove(product.id);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class ShoppingCartApp extends StatelessWidget {
  const ShoppingCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carrinho de Compras',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8A8B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7F3),
      ),
      home: const StoreHomePage(),
    );
  }
}

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final totalItems = context.watch<CartModel>().totalItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja Tech'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              isLabelVisible: totalItems > 0,
              label: Text('$totalItems'),
              child: IconButton(
                tooltip: 'Abrir carrinho',
                onPressed: () => setState(() => _selectedIndex = 1),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [ProductListPage(), CartPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Produtos',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Carrinho',
          ),
        ],
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.read<CartModel>().products;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final quantity = cart.quantityFor(product);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: product.color,
              foregroundColor: Colors.white,
              child: Icon(product.icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(product.price),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            quantity == 0
                ? FilledButton.icon(
                    onPressed: () => cart.add(product),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Adicionar'),
                  )
                : QuantitySelector(
                    quantity: quantity,
                    onAdd: () => cart.add(product),
                    onRemove: () => cart.removeOne(product),
                  ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    if (cart.items.isEmpty) {
      return const EmptyCart();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return CartItemTile(item: item);
            },
          ),
        ),
        CartSummary(
          totalItems: cart.totalItems,
          totalPrice: cart.totalPrice,
          onClear: cart.clear,
        ),
      ],
    );
  }
}

class CartItemTile extends StatelessWidget {
  const CartItemTile({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartModel>();

    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: CircleAvatar(
        backgroundColor: item.product.color,
        foregroundColor: Colors.white,
        child: Icon(item.product.icon),
      ),
      title: Text(item.product.name),
      subtitle: Text(
        '${item.quantity} x ${formatCurrency(item.product.price)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatCurrency(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            tooltip: 'Remover produto',
            onPressed: () => cart.removeProduct(item.product),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({
    required this.totalItems,
    required this.totalPrice,
    required this.onClear,
    super.key,
  });

  final int totalItems;
  final double totalPrice;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E2D8))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$totalItems itens no carrinho'),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(totalPrice),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Limpar'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compra finalizada com sucesso!'),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Diminuir quantidade',
            onPressed: onRemove,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: 'Aumentar quantidade',
            onPressed: onAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 76,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Seu carrinho esta vazio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione produtos na aba Produtos para ver o estado sendo compartilhado entre as telas.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String formatCurrency(double value) {
  return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}
