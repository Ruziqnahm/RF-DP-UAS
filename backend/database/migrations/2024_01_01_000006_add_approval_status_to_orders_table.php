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
        Schema::table('orders', function (Blueprint $table) {
            // Tambah approval_status untuk workflow admin
            $table->enum('approval_status', ['pending_review', 'approved', 'rejected'])->default('pending_review')->after('status');
            $table->text('rejection_reason')->nullable()->after('approval_status');
            $table->timestamp('reviewed_at')->nullable()->after('rejection_reason');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['approval_status', 'rejection_reason', 'reviewed_at']);
        });
    }
};
