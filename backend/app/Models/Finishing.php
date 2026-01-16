<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Finishing extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'name',
        'additional_price',
        'description',
        'is_active',
    ];

    protected $casts = [
        'additional_price' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    /**
     * Get the product that owns this finishing
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get orders using this finishing
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Scope to get only active finishings
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
