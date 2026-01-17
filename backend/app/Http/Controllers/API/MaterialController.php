<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Material;
use Illuminate\Http\Request;

class MaterialController extends Controller
{
    // Get all materials
    public function index()
    {
        $materials = Material::all();

        return response()->json([
            'success' => true,
            'data' => $materials,
        ], 200);
    }

    // Get single material
    public function show($id)
    {
        $material = Material::find($id);

        if (!$material) {
            return response()->json([
                'success' => false,
                'message' => 'Material not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $material,
        ], 200);
    }
}
