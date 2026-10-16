<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MatchRequest;
use Illuminate\Http\Request;

class MatchRequestController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->get('status', 'all');

        $items = MatchRequest::with('user:id,name,email')
            ->when($status !== 'all', fn($q) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.match-requests.index', compact('items', 'status'));
    }

    public function show(MatchRequest $matchRequest)
    {
        $matchRequest->load('user');
        return view('admin.match-requests.show', ['item' => $matchRequest]);
    }

    public function update(Request $request, MatchRequest $matchRequest)
    {
        $data = $request->validate([
            'status' => ['required', 'in:pending,reviewed,contacted,closed'],
        ]);
        $matchRequest->update($data);
        return back()->with('status', 'Request updated.');
    }
}
