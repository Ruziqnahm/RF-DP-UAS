<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderFile extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'file_name',
        'file_path',
        'file_type',
        'file_size',
        'uploaded_at',
    ];

    protected $casts = [
        'file_size' => 'integer',
        'uploaded_at' => 'datetime',
    ];

    /**
     * Get the order that owns this file
     */
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Get full URL for file
     */
    public function getFileUrlAttribute()
    {
        return asset('storage/' . $this->file_path);
    }
}
