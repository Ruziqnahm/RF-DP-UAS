<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class MaterialSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\Material::create([
            'name' => 'Art Paper',
            'price_per_meter' => 15000,
            'description' => 'Kertas berkualitas tinggi untuk hasil cetak premium'
        ]);

        \App\Models\Material::create([
            'name' => 'Vinyl',
            'price_per_meter' => 20000,
            'description' => 'Material tahan lama untuk outdoor'
        ]);

        \App\Models\Material::create([
            'name' => 'Flexi',
            'price_per_meter' => 18000,
            'description' => 'Material fleksibel untuk berbagai keperluan'
        ]);

        \App\Models\Material::create([
            'name' => 'Albatros',
            'price_per_meter' => 22000,
            'description' => 'Kertas premium dengan ketebalan ekstra'
        ]);
    }
}
