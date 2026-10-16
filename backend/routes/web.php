<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Admin\BroadcastController as AdminBroadcastController;
use App\Http\Controllers\Admin\ContactMessageController as AdminContactMessageController;
use App\Http\Controllers\Admin\CounsellingController as AdminCounsellingController;
use App\Http\Controllers\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\Admin\MatchController as AdminMatchController;
use App\Http\Controllers\Admin\MatchRequestController as AdminMatchRequestController;
use App\Http\Controllers\Admin\ProfileController as AdminProfileController;
use App\Http\Controllers\Admin\ReportController as AdminReportController;
use App\Http\Controllers\Admin\UserController as AdminUserController;

Route::get('/', function () {
    return view('welcome');
});

Route::view('/about',   'about')->name('about');
Route::view('/therapy', 'therapy')->name('therapy');
Route::view('/privacy', 'privacy')->name('privacy');
Route::view('/safety',  'safety')->name('safety');
Route::get('/contact',  [ContactController::class, 'show'])->name('contact');
Route::post('/contact', [ContactController::class, 'send'])->name('contact.send');

// ── Admin dashboard ─────────────────────────────────────────────────────────
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login',  [AdminAuthController::class, 'showLogin'])->name('login');
    Route::post('login', [AdminAuthController::class, 'login'])->name('login.attempt');

    Route::middleware(['auth', 'admin'])->group(function () {
        Route::post('logout', [AdminAuthController::class, 'logout'])->name('logout');

        Route::get('/', [AdminDashboardController::class, 'index'])->name('dashboard');

        Route::get('users',                       [AdminUserController::class, 'index'])->name('users.index');
        Route::get('users/export',                [AdminUserController::class, 'export'])->name('users.export');
        Route::get('users/{user}',                [AdminUserController::class, 'show'])->name('users.show');
        Route::post('users/{user}/verify',        [AdminUserController::class, 'verify'])->name('users.verify');
        Route::post('users/{user}/verify-profile-email', [AdminUserController::class, 'verifyProfileEmail'])->name('users.verifyProfileEmail');
        Route::post('users/{user}/verify-profile-phone', [AdminUserController::class, 'verifyProfilePhone'])->name('users.verifyProfilePhone');
        Route::post('users/{user}/verify-selfie', [AdminUserController::class, 'verifySelfie'])->name('users.verifySelfie');
        Route::post('users/{user}/reject-selfie', [AdminUserController::class, 'rejectSelfie'])->name('users.rejectSelfie');
        Route::delete('users/{user}/photos/{photo}', [AdminUserController::class, 'deletePhoto'])->name('users.deletePhoto');
        Route::post('users/{user}/impersonate',   [AdminUserController::class, 'impersonate'])->name('users.impersonate');
        Route::post('users/{user}/suspend',       [AdminUserController::class, 'suspend'])->name('users.suspend');
        Route::post('users/{user}/toggle-admin',  [AdminUserController::class, 'toggleAdmin'])->name('users.toggleAdmin');
        Route::delete('users/{user}',             [AdminUserController::class, 'destroy'])->name('users.destroy');

        Route::get('match-requests',                 [AdminMatchRequestController::class, 'index'])->name('matchRequests.index');
        Route::get('match-requests/{matchRequest}',  [AdminMatchRequestController::class, 'show'])->name('matchRequests.show');
        Route::post('match-requests/{matchRequest}', [AdminMatchRequestController::class, 'update'])->name('matchRequests.update');

        Route::get('matches',          [AdminMatchController::class, 'index'])->name('matches.index');
        Route::get('matches/{match}',  [AdminMatchController::class, 'show'])->name('matches.show');
        Route::delete('matches/{match}', [AdminMatchController::class, 'destroy'])->name('matches.destroy');
        Route::delete('messages/{message}', [AdminMatchController::class, 'deleteMessage'])->name('messages.destroy');

        Route::get('reports',          [AdminReportController::class, 'index'])->name('reports.index');
        Route::get('reports/{report}', [AdminReportController::class, 'show'])->name('reports.show');
        Route::post('reports/{report}', [AdminReportController::class, 'update'])->name('reports.update');

        Route::get('counselling',               [AdminCounsellingController::class, 'index'])->name('counselling.index');
        Route::get('counselling/{counselling}', [AdminCounsellingController::class, 'show'])->name('counselling.show');
        Route::post('counselling/{counselling}/status', [AdminCounsellingController::class, 'updateStatus'])->name('counselling.status');

        Route::get('contact',             [AdminContactMessageController::class, 'index'])->name('contact.index');
        Route::get('contact/{contact}',   [AdminContactMessageController::class, 'show'])->name('contact.show');
        Route::delete('contact/{contact}',[AdminContactMessageController::class, 'destroy'])->name('contact.destroy');

        Route::get('broadcast',  [AdminBroadcastController::class, 'create'])->name('broadcast.create');
        Route::post('broadcast', [AdminBroadcastController::class, 'send'])->name('broadcast.send');

        Route::get('profile',           [AdminProfileController::class, 'edit'])->name('profile.edit');
        Route::patch('profile',         [AdminProfileController::class, 'update'])->name('profile.update');
        Route::patch('profile/password',[AdminProfileController::class, 'updatePassword'])->name('profile.password');
    });
});
