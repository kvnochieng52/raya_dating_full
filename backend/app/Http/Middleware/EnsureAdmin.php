<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->is_admin) {
            if ($user) {
                auth()->logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();
            }
            return redirect()->route('admin.login')
                ->withErrors(['email' => 'That account does not have admin access.']);
        }

        return $next($request);
    }
}
