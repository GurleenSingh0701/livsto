// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIVSTO Seller Portal',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: AuthService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data != null
                ? const SellerDashboard()
                : const LandingPage();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}

// -------------------- SCREENS --------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header Banner
                Container(
                  height: 500,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade800,
                        Colors.deepPurple.shade400,
                      ],
                    ),
                  ),
                  child: _buildHeaderContent(context),
                ),

                // 2. How It Works Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                    horizontal: 20,
                  ),
                  child: _buildHowItWorksSection(context),
                ),

                // 3. Testimonials
                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: _buildTestimonialsSection(context),
                ),

                // 4. Join Form Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                    horizontal: 20,
                  ),
                  child: _buildJoinFormSection(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'LIVSTO',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Live Commerce Platform',
            style: TextStyle(fontSize: 24, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Sell your products live and connect with customers in real-time',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Seller Registration')),
                    body: const SellerAuthPage(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Join as a Seller',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'How It Works',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildStepItems(),
              );
            }
            return Column(children: _buildStepItems());
          },
        ),
      ],
    );
  }

  List<Widget> _buildStepItems() {
    return [
      _buildStep(
        icon: Icons.videocam,
        title: 'Go Live',
        description: 'Start a live stream to showcase your products',
      ),
      const SizedBox(height: 30),
      _buildStep(
        icon: Icons.add_box,
        title: 'List Product',
        description: 'Add products during your live session',
      ),
      const SizedBox(height: 30),
      _buildStep(
        icon: Icons.shopping_cart,
        title: 'Sell',
        description: 'Customers purchase directly during the stream',
      ),
    ];
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.deepPurple),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'What Our Sellers Say',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildTestimonialItems(),
              );
            } else if (constraints.maxWidth > 700) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildTestimonialItems().sublist(0, 2),
                  ),
                  const SizedBox(height: 20),
                  Center(child: _buildTestimonialItems()[2]),
                ],
              );
            }
            return Column(children: _buildTestimonialItems());
          },
        ),
      ],
    );
  }

  List<Widget> _buildTestimonialItems() {
    return [
      _buildTestimonial(
        name: 'Sarah Johnson',
        business: 'Fashion Boutique',
        text: 'LIVSTO helped me triple my sales in just 2 months!',
      ),
      const SizedBox(height: 20),
      _buildTestimonial(
        name: 'Mike Chen',
        business: 'Tech Gadgets',
        text: 'Access to customers I could never reach before.',
      ),
      const SizedBox(height: 20),
      _buildTestimonial(
        name: 'Emma Rodriguez',
        business: 'Handmade Crafts',
        text: 'Customers love the live demonstrations of my products.',
      ),
    ];
  }

  Widget _buildTestimonial({
    required String name,
    required String business,
    required String text,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.format_quote,
                size: 40,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                business,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinFormSection() {
    return Column(
      children: [
        const Text(
          'Ready to Start Selling?',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Join thousands of sellers growing their business with LIVSTO',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: SellerAuthPage(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SellerAuthPage extends StatefulWidget {
  const SellerAuthPage({super.key});

  @override
  State<SellerAuthPage> createState() => _SellerAuthPageState();
}

class _SellerAuthPageState extends State<SellerAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      Map<String, dynamic> response;

      if (_isLogin) {
        response = await api.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        response = await api.register({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'business_name': _businessController.text.trim(),
        });
      }

      await AuthService.persistToken(response['token']);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin ? 'Login Successful!' : 'Registration Successful!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SellerDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _businessController,
                  decoration: const InputDecoration(labelText: 'Business Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (value.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isLogin ? 'Login' : 'Register'),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? 'Need an account? Register'
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  static const String _productsKey = 'sellerProducts';
  XFile? _pickedXFile;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _saveProductsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _products.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_productsKey, encodedData);
  }

  Future<void> _loadProductsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_productsKey);
    if (encodedData != null) {
      try {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        setState(() {
          _products = decodedData
              .map((item) => Product.fromJson(item))
              .toList();
        });
      } catch (e) {
        await prefs.remove(_productsKey);
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _api.fetchProducts();
      setState(() => _products = products);
      await _saveProductsLocally();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Products loaded from server.'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      await _loadProductsLocally();
      if (_products.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load from server. Displaying cached products.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addProduct(Product product) async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.addProduct(product, _pickedXFile);

      if (response['success'] == true && response['product'] != null) {
        setState(() {
          _products = [..._products, Product.fromJson(response['product'])];
        });
        await _saveProductsLocally();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _products = [..._products, product]);
        await _saveProductsLocally();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add product to server: ${response['message'] ?? 'Unknown error'}. Displaying locally.',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _products = [..._products, product]);
      await _saveProductsLocally();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add product: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _pickedXFile = null;
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<String?> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) {
        _pickedXFile = null;
        return null;
      }

      _pickedXFile = image;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return base64Encode(bytes);
      } else {
        return image.path;
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(_productsKey);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LandingPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading && _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('No products yet. Click + to add one!'))
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                padding: const EdgeInsets.all(10),
                itemCount: _products.length,
                itemBuilder: (context, index) =>
                    ProductCard(product: _products[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    String? imageData;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Product'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final newImageData = await _pickImage();
                      if (newImageData != null) {
                        setState(() => imageData = newImageData);
                      }
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imageData == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40),
                                Text('Add Image'),
                              ],
                            )
                          : kIsWeb
                          ? Image.memory(
                              base64Decode(imageData!),
                              fit: BoxFit.cover,
                            )
                          : Image.file(File(imageData!), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      categoryController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      _pickedXFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill all fields and select an image',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        category: categoryController.text,
        price: double.tryParse(priceController.text) ?? 0,
        imageUrl: '',
        localTempImagePath: imageData,
      );
      await _addProduct(newProduct);
    }
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: ProductImage(product: product),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String? localTempImagePath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.localTempImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'image_url': imageUrl,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'] ?? '',
      localTempImagePath: null,
    );
  }
}

class AuthService {
  static const _tokenKey = 'auth_token';

  static Future<void> persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

class ApiService {
  static const _baseUrl = 'https://livsto-1.onrender.com/api/';

  Future<Map<String, String>> _getHeadersWithAuth() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Product>> fetchProducts() async {
    final headers = await _getHeadersWithAuth();
    final response = await http.get(
      Uri.parse('$_baseUrl/products'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        'Failed to load products: ${errorData['message'] ?? response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> addProduct(
    Product product,
    XFile? imageFile,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    Uri uri = Uri.parse('$_baseUrl/products');

    if (imageFile != null) {
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['name'] = product.name;
      request.fields['category'] = product.category;
      request.fields['price'] = product.price.toString();

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.fields['image_base64'] =
            'data:${imageFile.mimeType};base64,${base64Encode(bytes)}';

        var response = await http.post(
          uri,
          headers: await _getHeadersWithAuth(),
          body: jsonEncode({
            'name': product.name,
            'category': product.category,
            'price': product.price,
            'image_base64':
                'data:${imageFile.mimeType};base64,${base64Encode(bytes)}',
          }),
        );

        if (response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(
            'Failed to add product (Web): ${errorData['message'] ?? response.statusCode}',
          );
        }
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          return jsonDecode(responseBody);
        } else {
          final errorData = jsonDecode(responseBody);
          throw Exception(
            'Failed to add product (Mobile): ${errorData['message'] ?? response.statusCode}',
          );
        }
      }
    } else {
      final headers = await _getHeadersWithAuth();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'name': product.name,
          'category': product.category,
          'price': product.price,
          'image': 'default_product.jpg',
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to add product (No Image): ${errorData['message'] ?? response.statusCode}',
        );
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }
}

class ProductImage extends StatelessWidget {
  final Product product;
  final double? height;
  final double? width;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.product,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    try {
      if (product.localTempImagePath != null) {
        if (kIsWeb) {
          return Image.memory(
            base64Decode(product.localTempImagePath!),
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildErrorWidget(),
          );
        } else {
          return Image.file(
            File(product.localTempImagePath!),
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildErrorWidget(),
          );
        }
      }

      if (product.imageUrl.isNotEmpty) {
        return Image.network(
          product.imageUrl,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
        );
      }
    } catch (e) {
      debugPrint('Error loading product image: $e');
    }

    return _buildPlaceholder();
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
