<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * Display a listing of products with materials and finishings
     */
    public function index()
    {
        $products = Product::where('is_active', true)
            ->with(['materials' => function($query) {
                $query->where('is_active', true);
            }, 'finishings' => function($query) {
                $query->where('is_active', true);
            }])
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Products retrieved successfully',
            'data' => $products
        ], 200);
    }

    /**
     * Display the specified product with materials and finishings
     */
    public function show($id)
    {
        $product = Product::with(['materials', 'finishings'])->find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Product retrieved successfully',
            'data' => $product,
        ], 200);
    }

    /**
     * Get materials for a specific product
     */
    public function materials($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found'
            ], 404);
        }

        $materials = $product->materials()->where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'message' => 'Materials retrieved successfully',
            'data' => $materials
        ], 200);
    }

    /**
     * Get finishings for a specific product
     */
    public function finishings($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found'
            ], 404);
        }

        $finishings = $product->finishings()->where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'message' => 'Finishings retrieved successfully',
            'data' => $finishings
        ], 200);
    }
}
