<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderFile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    /**
     * Display a listing of orders
     */
    public function index(Request $request)
    {
        $query = Order::with(['product', 'material', 'finishing']);

        // Filter by customer phone (untuk guest users)
        if ($request->has('customer_phone')) {
            $query->where('customer_phone', $request->customer_phone);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $orders = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully',
            'data' => $orders
        ], 200);
    }

    /**
     * Store a newly created order
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'customer_name' => 'required|string|max:255',
            'customer_phone' => 'required|string|max:20',
            'customer_email' => 'nullable|email',
            'width' => 'nullable|numeric|min:0',
            'height' => 'nullable|numeric|min:0',
            'quantity' => 'required|integer|min:1',
            'material_id' => 'nullable|exists:materials,id',
            'finishing_id' => 'nullable|exists:finishings,id',
            'subtotal' => 'required|numeric|min:0',
            'material_cost' => 'nullable|numeric|min:0',
            'finishing_cost' => 'nullable|numeric|min:0',
            'total_price' => 'required|numeric|min:0',
            'is_urgent' => 'boolean',
            'deadline_date' => 'nullable|date',
            'customer_notes' => 'nullable|string',
            'design_files.*' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120', // 5MB max
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Generate order number
        $orderNumber = Order::generateOrderNumber();

        // Create order
        $order = Order::create([
            'order_number' => $orderNumber,
            'product_id' => $request->product_id,
            'customer_name' => $request->customer_name,
            'customer_phone' => $request->customer_phone,
            'customer_email' => $request->customer_email,
            'width' => $request->width,
            'height' => $request->height,
            'quantity' => $request->quantity,
            'material_id' => $request->material_id,
            'finishing_id' => $request->finishing_id,
            'subtotal' => $request->subtotal,
            'material_cost' => $request->material_cost ?? 0,
            'finishing_cost' => $request->finishing_cost ?? 0,
            'total_price' => $request->total_price,
            'is_urgent' => $request->is_urgent ?? false,
            'deadline_date' => $request->deadline_date,
            'customer_notes' => $request->customer_notes,
            'status' => 'pending',
        ]);

        // Handle file uploads
        if ($request->hasFile('design_files')) {
            $filePaths = [];
            foreach ($request->file('design_files') as $file) {
                $fileName = time() . '_' . $file->getClientOriginalName();
                $filePath = $file->storeAs('orders/' . $order->id, $fileName, 'public');
                
                // Save to order_files table
                OrderFile::create([
                    'order_id' => $order->id,
                    'file_name' => $fileName,
                    'file_path' => $filePath,
                    'file_type' => $file->getMimeType(),
                    'file_size' => $file->getSize(),
                ]);

                $filePaths[] = $filePath;
            }

            $order->update(['design_files' => $filePaths]);
        }

        // Load relationships
        $order->load(['product', 'material', 'finishing', 'files']);

        return response()->json([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => $order
        ], 201);
    }

    /**
     * Display the specified order
     */
    public function show($id)
    {
        $order = Order::with(['product', 'material', 'finishing', 'files'])->find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Order retrieved successfully',
            'data' => $order
        ], 200);
    }

    /**
     * Update order status
     */
    public function updateStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,confirmed,processing,ready,completed,cancelled',
            'admin_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $order = Order::find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }

        $order->update([
            'status' => $request->status,
            'admin_notes' => $request->admin_notes,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Order status updated successfully',
            'data' => $order
        ], 200);
    }

    /**
     * Calculate price
     */
    public function calculatePrice(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'width' => 'nullable|numeric|min:0',
            'height' => 'nullable|numeric|min:0',
            'quantity' => 'required|integer|min:1',
            'material_id' => 'nullable|exists:materials,id',
            'finishing_id' => 'nullable|exists:finishings,id',
            'is_urgent' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $product = \App\Models\Product::find($request->product_id);
        $material = $request->material_id ? \App\Models\Material::find($request->material_id) : null;
        $finishing = $request->finishing_id ? \App\Models\Finishing::find($request->finishing_id) : null;

        // Calculate base price
        $subtotal = $product->base_price * $request->quantity;
        
        // For banner, calculate by area
        if (strtolower($product->name) === 'banner indoor' && $request->width && $request->height) {
            $area = ($request->width / 100) * ($request->height / 100); // Convert cm to m
            $subtotal = $product->base_price * $area * $request->quantity;
        }

        // Apply material multiplier
        $materialCost = 0;
        if ($material) {
            $materialCost = $subtotal * ($material->price_multiplier - 1);
        }

        // Add finishing cost
        $finishingCost = 0;
        if ($finishing) {
            $finishingCost = $finishing->additional_price * $request->quantity;
        }

        // Calculate total
        $total = $subtotal + $materialCost + $finishingCost;

        // Add urgent fee (30%)
        if ($request->is_urgent) {
            $total *= 1.3;
        }

        return response()->json([
            'success' => true,
            'message' => 'Price calculated successfully',
            'data' => [
                'subtotal' => round($subtotal, 2),
                'material_cost' => round($materialCost, 2),
                'finishing_cost' => round($finishingCost, 2),
                'total_price' => round($total, 2),
                'is_urgent' => $request->is_urgent ?? false,
            ]
        ], 200);
    }
}
