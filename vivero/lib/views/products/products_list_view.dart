// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vivero/models/product.dart';
import 'package:vivero/services/product_service.dart';
import 'package:vivero/views/products/product_create.dart';

class ProductListView extends StatefulWidget {
  final bool isSelectionMode;
  final Function(Product)? onProductSelected;

  const ProductListView({
    Key? key,
    this.isSelectionMode = false,
    this.onProductSelected,
  }) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _filter = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Product>? _filteredProducts = [];
  List<Product>? _allProducts = [];
  bool _isLoading = false;
  bool _hasMore = true;

  int _pageSize = 10; // Número de productos por página
  int _currentPage = 0; // Página actual

  final Color themeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _getProducts();
    _filter.addListener(_filterProducts);
    _scrollController.addListener(_handleScroll);
  }

  Future<void> _getProducts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      List<Product> products = await ProductService().getAllProducts();
      _allProducts = List.from(products);
      _filteredProducts = _allProducts!.sublist(0, _pageSize);
      _currentPage = 0;
    } catch (e) {
      print("Error al obtener productos: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await Future.delayed(
          const Duration(seconds: 1)); // Simular carga de datos
      if (_allProducts!.length > (_currentPage + 1) * _pageSize) {
        _currentPage++;
        _filteredProducts!.addAll(
          _allProducts!.sublist(
              _currentPage * _pageSize, (_currentPage + 1) * _pageSize),
        );
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print("Error al cargar más productos: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final String searchTerm = _filter.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts!
          .where((product) => product.name.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  void _navigateAndCreateProduct() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductCreateView()),
    );
    if (result == true) {
      _getProducts();
    }
  }

  void _editProduct(Product product) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductCreateView(product: product)),
    );
    if (result == true) {
      _getProducts();
    }
  }

  void _deleteProduct(Product product) async {
    try {
      await ProductService().deleteProduct(product.id);
      setState(() {
        _allProducts!.remove(product);
        _filteredProducts!.remove(product);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        backgroundColor: themeColor,
        actions: [
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const SizedBox.shrink(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 10.0),
            child: Material(
              borderRadius: BorderRadius.circular(30.0),
              elevation: 2.0,
              child: TextField(
                controller: _filter,
                decoration: const InputDecoration(
                  hintText: 'Ingrese el nombre del producto',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                ),
                onChanged: (_) => _filterProducts(),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.green.shade100,
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndCreateProduct,
        backgroundColor: themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList() {
    if (_filteredProducts == null || _filteredProducts!.isEmpty) {
      return const Center(child: Text('No hay productos disponibles'));
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredProducts!.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _filteredProducts!.length) {
          return _buildCustomCard(_filteredProducts![index]);
        } else {
          return _buildLoader();
        }
      },
    );
  }

Widget _buildCustomCard(Product product) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    shadowColor: Colors.grey.withOpacity(0.5),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: InkWell(
      onTap: () {
        if (widget.isSelectionMode) {
          widget.onProductSelected?.call(product);
        }
      },
      child: Row(
        children: <Widget>[
          GestureDetector(
            onDoubleTap: () => _openImageFullScreen(product.imageUrl),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
                image: DecorationImage(
                  image: product.imageUrl != null && Uri.parse(product.imageUrl).isAbsolute
                      ? NetworkImage(product.imageUrl)
                      : const AssetImage('lib/images/no_content.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    product.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Status: ${product.status.name}',
                      style: const TextStyle(fontSize: 16, color: Colors.black)),
                  Text(
                    NumberFormat('#,##0.00', 'en_US').format(product.price),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  Text('Stock: ${product.stock}',
                      style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
          ),
          if (!widget.isSelectionMode)
            Column(
              children: [
                IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editProduct(product)),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteProduct(product)),
              ],
            ),
          if (widget.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
              onPressed: () => Navigator.pop(context, product),
            ),
        ],
      ),
    ),
  );
}


  Widget _buildLoader() {
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : const SizedBox.shrink();
  }

  void _openImageFullScreen(String? imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageUrl != null && Uri.parse(imageUrl).isAbsolute
                      ? NetworkImage(imageUrl)
                      : const AssetImage('lib/images/no_content.png')
                          as ImageProvider,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text(
              "¿Estás seguro de que quieres eliminar este producto?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(product);
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _filter.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
