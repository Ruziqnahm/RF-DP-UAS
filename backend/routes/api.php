<?php


use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\MaterialController;
use App\Http\Controllers\API\OrderController;
use Illuminate\Support\Facades\Route;

// Public routes (No authentication required - for demo)

// Products API
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{id}', [ProductController::class, 'show']);
Route::get('/products/{id}/materials', [ProductController::class, 'materials']);
Route::get('/products/{id}/finishings', [ProductController::class, 'finishings']);

// Orders API (Public untuk demo - tanpa auth)
Route::get('/orders', [OrderController::class, 'index']);
Route::post('/orders', [OrderController::class, 'store']);
Route::get('/orders/{id}', [OrderController::class, 'show']);
Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus']);
Route::post('/orders/{id}/approve', [OrderController::class, 'approve']);
Route::post('/orders/{id}/reject', [OrderController::class, 'reject']);


// Price Calculator
Route::post('/calculate-price', [OrderController::class, 'calculatePrice']);

// Materials (jika perlu endpoint terpisah)
Route::get('/materials', [MaterialController::class, 'index']);
Route::get('/materials/{id}', [MaterialController::class, 'show']);

