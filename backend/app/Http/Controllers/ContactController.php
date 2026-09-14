<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class ContactController extends Controller
{
    public function show()
    {
        return view('contact');
    }

    public function send(Request $request)
    {
        $data = $request->validate([
            'name'    => ['required', 'string', 'max:100'],
            'email'   => ['required', 'email', 'max:200'],
            'subject' => ['required', 'string', 'max:100'],
            'message' => ['required', 'string', 'max:3000'],
        ]);

        Mail::raw(
            implode("\n\n", [
                "From: {$data['name']} <{$data['email']}>",
                "Subject: {$data['subject']}",
                "---",
                $data['message'],
            ]),
            function ($mail) use ($data) {
                $mail->to('kingdomdating31@gmail.com')
                     ->replyTo($data['email'], $data['name'])
                     ->subject("[Kingdom Dating] {$data['subject']}");
            }
        );

        return redirect()->route('contact')
            ->with('success', 'Your message has been sent. We will get back to you within two business days.');
    }
}
