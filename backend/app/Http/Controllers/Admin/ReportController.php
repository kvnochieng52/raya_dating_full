<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->get('status', 'open');

        $reports = Report::with(['reporter:id,name,email', 'reportedUser:id,name,email'])
            ->when($status !== 'all', fn($q) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.reports.index', compact('reports', 'status'));
    }

    public function show(Report $report)
    {
        $report->load(['reporter.profile', 'reportedUser.profile.photos', 'resolver']);

        $alsoReported = Report::where('reported_user_id', $report->reported_user_id)
            ->where('id', '!=', $report->id)
            ->latest()
            ->take(10)
            ->get();

        return view('admin.reports.show', compact('report', 'alsoReported'));
    }

    public function update(Request $request, Report $report)
    {
        $data = $request->validate([
            'status'       => ['required', 'in:' . implode(',', Report::STATUSES)],
            'admin_notes'  => ['nullable', 'string', 'max:5000'],
        ]);

        $report->status      = $data['status'];
        $report->admin_notes = $data['admin_notes'] ?? $report->admin_notes;

        if (in_array($data['status'], ['resolved', 'dismissed'], true)) {
            $report->resolved_by = $request->user()->id;
            $report->resolved_at = Carbon::now();
        } else {
            $report->resolved_by = null;
            $report->resolved_at = null;
        }
        $report->save();

        return back()->with('status', 'Report updated.');
    }
}
