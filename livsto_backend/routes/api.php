<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash; // Import Hash facade

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Helper functions for JSON file operations (Ensure these exist or adapt)
// You might put these in app/Helpers/FileHelpers.php and include them,
// or define them directly here for this simple setup.
if (!function_exists('get_json_data')) {
    function get_json_data($filename) {
        if (!Storage::exists($filename)) {
            return [];
        }
        $contents = Storage::get($filename);
        return json_decode($contents, true) ?? [];
    }
}

if (!function_exists('store_json_data')) {
    function store_json_data($filename, $data) {
        Storage::put($filename, json_encode($data, JSON_PRETTY_PRINT));
    }
}


// Seller registration
Route::post('/register', function (Request $request) {
    $data = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|max:255',
        'password' => 'required|string|min:6',
        'business_name' => 'required|string|max:255',
    ]);
    
    $sellers = get_json_data('sellers.json');
    
    // Check if email already exists
    if (collect($sellers)->contains('email', $data['email'])) {
        return response()->json(['message' => 'Email already registered'], 400);
    }
    
    $seller = [
        'id' => uniqid(),
        'name' => $data['name'],
        'email' => $data['email'],
        'password' => Hash::make($data['password']), // Use Hash::make for proper password hashing
        'business_name' => $data['business_name'],
        'created_at' => now()->toDateTimeString(),
    ];
    
    $sellers[] = $seller;
    store_json_data('sellers.json', $sellers);
    
    // Generate a dummy token upon successful registration
    $token = 'dummy_token_' . uniqid(); 
    
    return response()->json([
        'message' => 'Seller registered successfully',
        'seller' => $seller,
        'token' => $token, // <-- IMPORTANT: Token is now returned here
    ], 201); // 201 Created status
});

// Seller login
Route::post('/login', function (Request $request) {
    $data = $request->validate([
        'email' => 'required|email',
        'password' => 'required|string',
    ]);
    
    if (!Storage::exists('sellers.json')) {
        return response()->json(['message' => 'Invalid credentials'], 401);
    }
    
    $sellers = json_decode(Storage::get('sellers.json'), true);
    $seller = collect($sellers)->firstWhere('email', $data['email']);
    
    // Check if seller exists AND password matches the stored hash
    if (!$seller || !Hash::check($data['password'], $seller['password'])) {
        return response()->json(['message' => 'Invalid credentials'], 401);
    }
    
    // Generate a new dummy token for login
    $token = 'dummy_token_' . uniqid();

    return response()->json([
        'message' => 'Login successful',
        'seller' => $seller,
        'token' => $token, // Token returned on login
    ]);
});

// Product endpoints (these remain largely the same, but ensure they are correctly grouped if applicable)
Route::middleware(['api'])->group(function () {
    // Get all products
    Route::get('/products', function () {
        $products = get_json_data('products.json'); // Use helper function
        return response()->json($products);
    });
    
    // Add new product
    Route::post('/products', function (Request $request) {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'category' => 'required|string|max:255',
                'price' => 'required|numeric|min:0',
                'image' => 'nullable|string|max:255', // Assuming image is a URL or filename string
            ]);
            
            $products = get_json_data('products.json'); // Use helper function
            
            $newProduct = [
                'id' => uniqid(),
                'name' => $validated['name'],
                'category' => $validated['category'],
                'price' => (float)$validated['price'],
                'image_url' => $validated['image'] ?? 'default.jpg', // Use 'image_url' for consistency with Product model
                'created_at' => now()->toDateTimeString(),
            ];
            
            $products[] = $newProduct;
            store_json_data('products.json', $products); // Use helper function
            
            return response()->json([
                'success' => true,
                'product' => $newProduct,
            ], 201);
    
        } catch (\Exception $e) {
            // Include validation errors if available
            $errors = $e instanceof \Illuminate\Validation\ValidationException ? $e->errors() : null;
            return response()->json([
                'success' => false,
                'message' => 'Error adding product: ' . $e->getMessage(),
                'errors' => $errors,
            ], 500);
        }
    });
    
    // AI product recognition (simulated)
    Route::post('/ai-recognize', function (Request $request) {
        try {
            $validated = $request->validate([
                'name' => 'nullable|string|max:255',
                'image' => 'nullable|string|max:255',
            ]);
            
            $name = $validated['name'] ?? ''; // Initialize as empty string
            $category = 'Other';
            $price = 19.99;
    
            $recognitionPatterns = [
                '/phone|iphone|samsung/i' => ['category' => 'Electronics', 'price' => 599.99],
                '/shirt|t-shirt|blouse/i' => ['category' => 'Clothing', 'price' => 24.99],
                '/book|novel|magazine/i' => ['category' => 'Books', 'price' => 12.99],
                '/headphone|earbud|earphone/i' => ['category' => 'Electronics', 'price' => 99.99],
                '/watch|timepiece|chronograph/i' => ['category' => 'Accessories', 'price' => 199.99],
                '/laptop|notebook|macbook/i' => ['category' => 'Electronics', 'price' => 899.99],
                '/shoe|sneaker|footwear/i' => ['category' => 'Footwear', 'price' => 59.99],
            ];
            
            foreach ($recognitionPatterns as $pattern => $details) {
                if (preg_match($pattern, $name)) {
                    $category = $details['category'];
                    $price = $details['price'];
                    break;
                }
            }
            
            return response()->json([
                'success' => true,
                'name' => $name,
                'category' => $category,
                'price' => $price,
                'recognized' => $category !== 'Other',
            ]);
    
        } catch (\Exception $e) {
            $errors = $e instanceof \Illuminate\Validation\ValidationException ? $e->errors() : null;
            return response()->json([
                'success' => false,
                'message' => 'AI recognition failed: ' . $e->getMessage(),
                'errors' => $errors,
            ], 500);
        }
    });
});

// Test routes (for debugging storage and CORS)
Route::get('/test-storage', function() {
    $testData = ['test' => 'value', 'timestamp' => now()];
    store_json_data('test.json', $testData);
    
    $readData = get_json_data('test.json');
    
    return response()->json([
        'written_data' => $testData,
        'read_data' => $readData,
        'storage_path' => storage_path(),
        'files_in_app_storage' => scandir(storage_path('app')), // List files in storage/app
    ]);
});

Route::get('/cors-test', function() {
    return response()->json([
        'message' => 'CORS is working!',
        'headers' => request()->headers->all()
    ]);
});