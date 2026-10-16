<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'reported_user_id' => ['required', 'integer', 'exists:users,id'],
            'reason'           => ['required', 'string', 'in:' . implode(',', Report::REASONS)],
            'details'          => ['nullable', 'string', 'max:2000'],
        ]);

        if ((int)$data['reported_user_id'] === $request->user()->id) {
            return response()->json(['message' => 'You cannot report yourself.'], 422);
        }

        $report = Report::create([
            'reporter_id'      => $request->user()->id,
            'reported_user_id' => $data['reported_user_id'],
            'reason'           => $data['reason'],
            'details'          => $data['details'] ?? null,
            'status'           => 'open',
        ]);

        return response()->json([
            'message' => 'Thanks for letting us know. Our team will review this report.',
            'id'      => $report->id,
        ], 201);
    }
}
