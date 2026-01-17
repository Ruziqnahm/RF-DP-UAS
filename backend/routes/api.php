<?php

use App\Http\Controllers\API\AuthController;
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

// Price Calculator
Route::post('/calculate-price', [OrderController::class, 'calculatePrice']);

// Materials (jika perlu endpoint terpisah)
Route::get('/materials', [MaterialController::class, 'index']);
Route::get('/materials/{id}', [MaterialController::class, 'show']);

// Auth routes (untuk P1 - jika ada waktu implementasi login)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (untuk fitur yang memerlukan auth)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    
    // Admin only routes
    Route::post('/orders/{id}/approve', [OrderController::class, 'approveOrder']);
    Route::post('/orders/{id}/reject', [OrderController::class, 'rejectOrder']);
});
