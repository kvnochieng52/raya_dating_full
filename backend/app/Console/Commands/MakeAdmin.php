<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class MakeAdmin extends Command
{
    protected $signature = 'admin:make
                            {email : The email of the account to promote (created if missing)}
                            {--name= : Display name (only used when creating)}
                            {--password= : Password (only used when creating; prompts if omitted)}';

    protected $description = 'Promote an existing user to admin, or create a new admin account.';

    public function handle(): int
    {
        $email = $this->argument('email');
        $user = User::firstWhere('email', $email);

        if (! $user) {
            $name = $this->option('name') ?: $this->ask('Display name');
            $password = $this->option('password') ?: $this->secret('Password (min 8 chars)');
            if (strlen($password) < 8) {
                $this->error('Password must be at least 8 characters.');
                return self::FAILURE;
            }
            $user = User::create([
                'name'              => $name,
                'email'             => $email,
                'password'          => Hash::make($password),
                'email_verified_at' => now(),
                'is_admin'          => true,
            ]);
            $this->info("Created admin {$email}.");
            return self::SUCCESS;
        }

        if ($user->is_admin) {
            $this->warn("{$email} is already an admin.");
            return self::SUCCESS;
        }

        $user->is_admin = true;
        $user->save();
        $this->info("Promoted {$email} to admin.");
        return self::SUCCESS;
    }
}
