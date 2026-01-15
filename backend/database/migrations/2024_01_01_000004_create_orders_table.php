<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('product_id')->constrained();
            $table->string('customer_name');
            $table->string('customer_phone', 20);
            $table->string('customer_email')->nullable();
            
            // Spesifikasi Produk
            $table->decimal('width', 10, 2)->nullable();
            $table->decimal('height', 10, 2)->nullable();
            $table->integer('quantity')->default(1);
            $table->foreignId('material_id')->nullable()->constrained();
            $table->foreignId('finishing_id')->nullable()->constrained();
            
            // Harga
            $table->decimal('subtotal', 12, 2);
            $table->decimal('material_cost', 12, 2)->default(0);
            $table->decimal('finishing_cost', 12, 2)->default(0);
            $table->decimal('total_price', 12, 2);
            
            // File Upload
            $table->json('design_files')->nullable();
            
            // Status
            $table->enum('status', ['pending', 'confirmed', 'processing', 'ready', 'completed', 'cancelled'])->default('pending');
            $table->boolean('is_urgent')->default(false);
            $table->date('deadline_date')->nullable();
            
            // Notes
            $table->text('customer_notes')->nullable();
            $table->text('admin_notes')->nullable();
            
            $table->timestamps();
            
            // Indexes
            $table->index('order_number');
            $table->index('customer_phone');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
