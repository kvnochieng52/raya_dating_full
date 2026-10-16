<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MatchRecord;
use App\Models\Message;
use Illuminate\Http\Request;

class MatchController extends Controller
{
    public function index(Request $request)
    {
        $q = trim((string)$request->get('q', ''));

        $matches = MatchRecord::with(['userLow:id,name,email', 'userHigh:id,name,email'])
            ->withCount('messages')
            ->when($q !== '', function ($query) use ($q) {
                $query->whereHas('userLow', fn($s) => $s->where('name', 'like', "%{$q}%")->orWhere('email', 'like', "%{$q}%"))
                      ->orWhereHas('userHigh', fn($s) => $s->where('name', 'like', "%{$q}%")->orWhere('email', 'like', "%{$q}%"));
            })
            ->latest()
            ->paginate(25)
            ->withQueryString();

        return view('admin.matches.index', compact('matches', 'q'));
    }

    public function show(MatchRecord $match)
    {
        $match->load(['userLow.profile', 'userHigh.profile']);

        $messages = Message::with('sender:id,name')
            ->where('match_id', $match->id)
            ->orderBy('id')
            ->get();

        return view('admin.matches.show', compact('match', 'messages'));
    }

    public function destroy(MatchRecord $match)
    {
        $match->delete();
        return redirect()->route('admin.matches.index')->with('status', 'Match deleted (messages cascaded).');
    }

    public function deleteMessage(Message $message)
    {
        $matchId = $message->match_id;
        $message->delete();
        return redirect()->route('admin.matches.show', $matchId)->with('status', 'Message deleted.');
    }
}
