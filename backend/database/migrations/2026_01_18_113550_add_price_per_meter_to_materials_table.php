<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('materials', function (Blueprint $table) {
            $table->decimal('price_per_meter', 10, 2)->nullable()->after('name');
        });
    }

    public function down()
    {
        Schema::table('materials', function (Blueprint $table) {
            $table->dropColumn('price_per_meter');
        });
    }
};
