<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'name',
        'price_per_meter',  // Pastikan ada
        'price_multiplier',
        'description',
        'is_active',
    ];

    protected $casts = [
        'price_multiplier' => 'decimal:2',
        'is_active' => 'boolean',
    ];
    

    /**
     * Get the product that owns this material
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get orders using this material
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Scope to get only active materials
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
