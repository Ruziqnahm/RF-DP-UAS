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

        // 1. Get Base Data
        $basePrice = $product->base_price;
        $multiplier = $material ? $material->price_multiplier : 1.0;
        
        // 2. Get Finishing Cost
        $finishingCostPerUnit = $finishing ? $finishing->additional_price : 0;

        $productName = strtolower($product->name);
        $materialPricePerUnit = 0;

        // 3. Calculate per Unit Logic
        if (str_contains($productName, 'banner')) {
            // Logic Area (m2)
            $area = 1.0;
            if ($request->width && $request->height) {
                // Convert cm to m2
                $area = ($request->width * $request->height) / 10000;
                // Min 1 m2 policy
                if ($area < 1.0) $area = 1.0;
            }
            
            // Base Price is per m2 for Banner
            $materialPricePerUnit = ($basePrice * $multiplier) * $area;
            
        } elseif (str_contains($productName, 'stiker') || str_contains($productName, 'sticker')) {
             if ($request->width && $request->height) {
                 // Custom Size Logic
                 $area = ($request->width * $request->height) / 10000;
                 // Base Price is usually per A3 Sheet (~0.15 m2)
                 // Convert to Per m2
                 $basePerM2 = $basePrice / 0.15; 
                 $materialPricePerUnit = $basePerM2 * $area * $multiplier;
             } else {
                 // Standard Sheet (A3)
                 $materialPricePerUnit = $basePrice * $multiplier;
             }
        } else {
             // Standard Unit (Kartu Nama, UV, etc)
             $materialPricePerUnit = $basePrice * $multiplier;
        }

        // 4. Calculate Unit Price Total (Material + Finishing)
        $unitPrice = $materialPricePerUnit + $finishingCostPerUnit;

        // 5. Calculate Subtotal
        $subtotal = round($unitPrice * $request->quantity);

        // 6. Components for Breakdown
        $totalMaterialCost = round($materialPricePerUnit * $request->quantity);
        $totalFinishingCost = round($finishingCostPerUnit * $request->quantity);

        // 7. Urgent Fee
        $urgentFee = 0;
        if ($request->is_urgent) {
            $urgentFee = round($subtotal * 0.3);
        }

        // 8. Total
        $total = $subtotal + $urgentFee;

        return response()->json([
            'success' => true,
            'message' => 'Price calculated successfully',
            'data' => [
                'subtotal' => $subtotal,
                'material_cost' => $totalMaterialCost,
                'finishing_cost' => $totalFinishingCost,
                'urgent_fee' => $urgentFee,
                'total_price' => $total,
                'is_urgent' => $request->is_urgent ?? false,
            ]
        ], 200);
    }
}
