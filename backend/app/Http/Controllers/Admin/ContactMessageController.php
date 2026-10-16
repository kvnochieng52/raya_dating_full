<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ContactMessage;
use Illuminate\Http\Request;

class ContactMessageController extends Controller
{
    public function index(Request $request)
    {
        $filter = $request->get('filter', 'all');

        $messages = ContactMessage::when($filter === 'unread', fn($q) => $q->whereNull('read_at'))
            ->when($filter === 'read', fn($q) => $q->whereNotNull('read_at'))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.contact.index', compact('messages', 'filter'));
    }

    public function show(ContactMessage $contact)
    {
        if (! $contact->read_at) {
            $contact->update(['read_at' => now()]);
        }
        return view('admin.contact.show', compact('contact'));
    }

    public function destroy(ContactMessage $contact)
    {
        $contact->delete();
        return redirect()->route('admin.contact.index')->with('status', 'Message deleted.');
    }
}
