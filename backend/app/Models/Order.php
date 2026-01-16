<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'product_id',
        'customer_name',
        'customer_phone',
        'customer_email',
        'width',
        'height',
        'quantity',
        'material_id',
        'finishing_id',
        'subtotal',
        'material_cost',
        'finishing_cost',
        'total_price',
        'design_files',
        'status',
        'is_urgent',
        'deadline_date',
        'customer_notes',
        'admin_notes',
    ];

    protected $casts = [
        'width' => 'decimal:2',
        'height' => 'decimal:2',
        'quantity' => 'integer',
        'subtotal' => 'decimal:2',
        'material_cost' => 'decimal:2',
        'finishing_cost' => 'decimal:2',
        'total_price' => 'decimal:2',
        'design_files' => 'array',
        'is_urgent' => 'boolean',
        'deadline_date' => 'date',
    ];

    /**
     * Get the product for this order
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get the material for this order
     */
    public function material()
    {
        return $this->belongsTo(Material::class);
    }

    /**
     * Get the finishing for this order
     */
    public function finishing()
    {
        return $this->belongsTo(Finishing::class);
    }

    /**
     * Get uploaded files for this order
     */
    public function files()
    {
        return $this->hasMany(OrderFile::class);
    }

    /**
     * Generate unique order number
     */
    public static function generateOrderNumber()
    {
        $date = now()->format('Ymd');
        $count = self::whereDate('created_at', today())->count() + 1;
        return 'ORD-' . $date . '-' . str_pad($count, 3, '0', STR_PAD_LEFT);
    }

    /**
     * Scope to get orders by status
     */
    public function scopeStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope to get urgent orders
     */
    public function scopeUrgent($query)
    {
        return $query->where('is_urgent', true);
    }
}
