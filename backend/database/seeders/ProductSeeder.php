<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Product;
use App\Models\Material;
use App\Models\Finishing;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Clear existing data
        Finishing::query()->delete();
        Material::query()->delete();
        Product::query()->delete();

        // Product 1: 
        $banner = Product::create([
            'name' => 'Banner ',
            'category' => 'Banner',
            'description' => 'Banner berkualitas tinggi untuk indoor dengan hasil cetak tajam',
            'base_price' => 20000,
            'unit' => 'Meter',
            'image_url' => 'cetak_banner.jpg',
            'is_active' => true,
        ]);

        // Materials untuk Banner
        Material::create([
            'product_id' => $banner->id,
            'name' => 'Flexi Korea',
            'price_multiplier' => 1.0,
            'description' => 'Bahan standar flexi korea berkualitas baik',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $banner->id,
            'name' => 'Flexi China',
            'price_multiplier' => 0.8,
            'description' => 'Bahan ekonomis flexi china',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $banner->id,
            'name' => 'Albatross',
            'price_multiplier' => 1.5,
            'description' => 'Bahan premium albatross untuk hasil terbaik',
            'is_active' => true,
        ]);

        // Finishings untuk Banner
        Finishing::create([
            'product_id' => $banner->id,
            'name' => 'Tanpa Laminasi',
            'additional_price' => 0,
            'description' => 'Tanpa laminasi tambahan',
            'is_active' => true,
        ]);

        Finishing::create([
            'product_id' => $banner->id,
            'name' => 'Laminasi Glossy',
            'additional_price' => 5000,
            'description' => 'Laminasi glossy untuk tampilan mengkilap',
            'is_active' => true,
        ]);

        Finishing::create([
            'product_id' => $banner->id,
            'name' => 'Laminasi Doff',
            'additional_price' => 5000,
            'description' => 'Laminasi doff untuk tampilan matte',
            'is_active' => true,
        ]);

        // Product 2: Stiker Vinyl
        $stiker = Product::create([
            'name' => 'Stiker Vinyl',
            'category' => 'Stiker',
            'description' => 'Stiker vinyl tahan lama untuk berbagai kebutuhan',
            'base_price' => 25000,
            'unit' => 'Lembar',
            'image_url' => 'cetak_stiker_vinyl.jpg',
            'is_active' => true,
        ]);

        // Materials untuk Stiker
        Material::create([
            'product_id' => $stiker->id,
            'name' => 'Vinyl Glossy',
            'price_multiplier' => 1.0,
            'description' => 'Vinyl dengan finishing glossy',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $stiker->id,
            'name' => 'Vinyl Matte',
            'price_multiplier' => 1.2,
            'description' => 'Vinyl dengan finishing matte',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $stiker->id,
            'name' => 'Vinyl Transparant',
            'price_multiplier' => 1.3,
            'description' => 'Vinyl transparan untuk efek unik',
            'is_active' => true,
        ]);

        // Finishings untuk Stiker
        Finishing::create([
            'product_id' => $stiker->id,
            'name' => 'Cutting Biasa',
            'additional_price' => 0,
            'description' => 'Cutting standar persegi',
            'is_active' => true,
        ]);

        Finishing::create([
            'product_id' => $stiker->id,
            'name' => 'Cutting Kontour',
            'additional_price' => 3000,
            'description' => 'Cutting mengikuti bentuk desain',
            'is_active' => true,
        ]);

        // Product 3: Kartu Nama
        $kartuNama = Product::create([
            'name' => 'Kartu Nama',
            'category' => 'Kartu',
            'description' => 'Kartu nama premium untuk kebutuhan profesional',
            'base_price' => 30000,
            'unit' => 'Pack',
            'image_url' => 'kartu_nama.jpg',
            'is_active' => true,
        ]);

        // Materials untuk Kartu Nama
        Material::create([
            'product_id' => $kartuNama->id,
            'name' => 'Fancy Paper 260gsm',
            'price_multiplier' => 1.0,
            'description' => 'Kertas fancy standar 260gsm',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $kartuNama->id,
            'name' => 'Fancy Paper 310gsm',
            'price_multiplier' => 1.3,
            'description' => 'Kertas fancy tebal 310gsm',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $kartuNama->id,
            'name' => 'Ivory Paper 230gsm',
            'price_multiplier' => 0.9,
            'description' => 'Kertas ivory ekonomis 230gsm',
            'is_active' => true,
        ]);

        // Finishings untuk Kartu Nama
        Finishing::create([
            'product_id' => $kartuNama->id,
            'name' => 'Tanpa Laminasi',
            'additional_price' => 0,
            'description' => 'Tanpa laminasi tambahan',
            'is_active' => true,
        ]);

        Finishing::create([
            'product_id' => $kartuNama->id,
            'name' => 'Laminasi Doff',
            'additional_price' => 2000,
            'description' => 'Laminasi doff untuk tampilan elegan',
            'is_active' => true,
        ]);

        Finishing::create([
            'product_id' => $kartuNama->id,
            'name' => 'Laminasi Glossy',
            'additional_price' => 2000,
            'description' => 'Laminasi glossy untuk tampilan mengkilap',
            'is_active' => true,
        ]);

        // Product 4: UV Printing
        $uvPrinting = Product::create([
            'name' => 'UV Printing',
            'category' => 'UV',
            'description' => 'Cetak UV untuk berbagai media dengan hasil tahan lama',
            'base_price' => 15000,
            'unit' => 'Pack',
            'image_url' => 'uv_cetak.jpg',
            'is_active' => true,
        ]);

        // Materials untuk UV Printing
        Material::create([
            'product_id' => $uvPrinting->id,
            'name' => 'Acrylic 3mm',
            'price_multiplier' => 1.0,
            'description' => 'Acrylic ketebalan 3mm',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $uvPrinting->id,
            'name' => 'Acrylic 5mm',
            'price_multiplier' => 1.5,
            'description' => 'Acrylic ketebalan 5mm untuk hasil premium',
            'is_active' => true,
        ]);

        Material::create([
            'product_id' => $uvPrinting->id,
            'name' => 'Kayu MDF',
            'price_multiplier' => 1.2,
            'description' => 'Media kayu MDF untuk UV printing',
            'is_active' => true,
        ]);

        // Finishings untuk UV Printing
        Finishing::create([
            'product_id' => $uvPrinting->id,
            'name' => 'Tanpa Finishing',
            'additional_price' => 0,
            'description' => 'Tanpa finishing tambahan',
            'is_active' => true,
        ]);

        Finishing::create([
            'product_id' => $uvPrinting->id,
            'name' => 'Spot UV',
            'additional_price' => 5000,
            'description' => 'Tambahan spot UV untuk efek timbul',
            'is_active' => true,
        ]);
    }
}
