<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ContactController;

Route::get('/', function () {
    return view('welcome');
});

Route::view('/about',   'about')->name('about');
Route::view('/therapy', 'therapy')->name('therapy');
Route::view('/privacy', 'privacy')->name('privacy');
Route::view('/safety',  'safety')->name('safety');
Route::get('/contact',  [ContactController::class, 'show'])->name('contact');
Route::post('/contact', [ContactController::class, 'send'])->name('contact.send');
