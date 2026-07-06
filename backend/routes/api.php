<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DiscoveryController;
use App\Http\Controllers\Api\MatchRequestController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/profile', [ProfileController::class, 'show']);
    Route::patch('/profile', [ProfileController::class, 'update']);

    Route::post('/profile/photos', [ProfileController::class, 'uploadPhoto']);
    Route::delete('/profile/photos/{photo}', [ProfileController::class, 'deletePhoto']);
    Route::patch('/profile/photos/{photo}/main', [ProfileController::class, 'setMainPhoto']);

    Route::post('/profile/verify/email/request', [ProfileController::class, 'requestEmailCode']);
    Route::post('/profile/verify/email', [ProfileController::class, 'verifyEmail']);
    Route::post('/profile/verify/selfie', [ProfileController::class, 'uploadSelfie']);

    Route::post('/profile/location', [DiscoveryController::class, 'updateLocation']);

    Route::get('/discovery', [DiscoveryController::class, 'feed']);
    Route::post('/swipes', [DiscoveryController::class, 'swipe']);
    Route::get('/likes/sent', [DiscoveryController::class, 'sentLikes']);
    Route::get('/likes/received', [DiscoveryController::class, 'receivedLikes']);
    Route::get('/matches', [DiscoveryController::class, 'matches']);
    Route::get('/matches/{match}/messages', [MessageController::class, 'index']);
    Route::post('/matches/{match}/messages', [MessageController::class, 'store']);
    Route::post('/matches/{match}/read', [MessageController::class, 'markRead']);

    Route::post('/match-requests', [MatchRequestController::class, 'store']);
});
