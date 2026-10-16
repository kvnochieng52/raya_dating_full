<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CounsellingRequest;
use Illuminate\Http\Request;

class CounsellingController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->get('status', 'all');

        $requests = CounsellingRequest::with('user:id,name,email')
            ->when($status !== 'all', fn($q) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.counselling.index', compact('requests', 'status'));
    }

    public function show(CounsellingRequest $counselling)
    {
        $counselling->load('user');
        return view('admin.counselling.show', compact('counselling'));
    }

    public function updateStatus(Request $request, CounsellingRequest $counselling)
    {
        $data = $request->validate([
            'status' => ['required', 'in:pending,contacted,resolved'],
        ]);
        $counselling->update(['status' => $data['status']]);
        return back()->with('status', 'Request status updated.');
    }
}
