<?php

namespace Database\Seeders;

use App\Models\Like;
use App\Models\MatchRecord;
use App\Models\Message;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

/**
 * Populates a demo "you" account with mutual matches, chat threads, and
 * received likes so screenshots for the Play Store look real.
 *
 * Requires ProfileSeeder to have run first (it depends on the seeded profiles
 * created there). Idempotent — safe to re-run.
 *
 * Log in for screenshots with:
 *   Email:    demo@kingdomdating.test
 *   Password: password
 */
class DemoContentSeeder extends Seeder
{
    public function run(): void
    {
        $demo = $this->createDemoUser();

        // Matches (mutual likes) that should have chat threads.
        // Each entry: [seeded_email, thread — array of ['from' => 'me'|'them', 'body' => string, 'minutes_ago' => int]]
        $matchScripts = [
            [
                'seed.woman.1@kingdomdating.test',
                [
                    ['them', 'Hey! Loved reading your profile — the worship-leader thing caught my eye 🎶', 60 * 26],
                    ['me',   'Thanks Sarah! What church do you attend?', 60 * 25],
                    ['them', 'A small non-denom plant in Kilimani. You?', 60 * 25 - 5],
                    ['me',   'Nice — I go to CITAM Valley Road. Would love to grab coffee sometime and hear more.', 60 * 3],
                    ['them', 'I would like that 🙂 Sunday afternoon?', 60 * 1],
                ],
            ],
            [
                'seed.woman.3@kingdomdating.test',
                [
                    ['me',   'Ruth — your hiking photos are incredible. Where was the last one taken?', 60 * 48],
                    ['them', 'That was Mt. Longonot last month! Long day but so worth it.', 60 * 47],
                    ['me',   'On my bucket list. Any tips for a first-timer?', 60 * 46],
                    ['them', 'Start early, bring more water than you think you need, and enjoy the view at the crater rim ✨', 60 * 20],
                ],
            ],
            [
                'seed.woman.5@kingdomdating.test',
                [
                    ['them', 'Hi! Quick question — favourite verse?', 60 * 12],
                    ['me',   'Probably Proverbs 3:5-6. You?', 60 * 11],
                    ['them', 'Ohh a classic. Mine is Jeremiah 29:11 — carried me through a hard season.', 60 * 10],
                ],
            ],
            [
                'seed.woman.7@kingdomdating.test',
                [
                    ['me',   'Naomi 👋 Coffee or tea person?', 30],
                    ['them', 'Chai, always. Nairobi rain requires it.', 10],
                ],
            ],
        ];

        foreach ($matchScripts as [$email, $thread]) {
            $this->createMatchWithThread($demo, $email, $thread);
        }

        // People who liked YOU but you have not swiped yet — populates
        // the "Likes received" screen.
        $incomingLikeEmails = [
            'seed.woman.2@kingdomdating.test',
            'seed.woman.4@kingdomdating.test',
            'seed.woman.6@kingdomdating.test',
            'seed.woman.8@kingdomdating.test',
            'seed.woman.9@kingdomdating.test',
        ];

        foreach ($incomingLikeEmails as $email) {
            $sender = User::where('email', $email)->first();
            if (! $sender) continue;
            Like::updateOrCreate(
                ['user_id' => $sender->id, 'target_user_id' => $demo->id],
                ['action' => Like::ACTION_LIKE],
            );
        }
    }

    private function createDemoUser(): User
    {
        $user = User::firstOrCreate(
            ['email' => 'demo@kingdomdating.test'],
            [
                'name' => 'Demo Kingdom',
                'password' => Hash::make('password'),
            ],
        );

        $profile = $user->profile()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'nickname' => 'Alex',
                'birth_date' => Carbon::today()->subYears(29)->subMonths(4),
                'gender' => 'Man',
                'marital_status' => 'Single',
                'body_type' => 'Athletic',
                'bio' => 'Engineer by day, worship team on Sundays. Love long hikes, quiet mornings, and honest conversation.',

                'kingdom_purpose' => 'Dating',
                'relationship_goal' => 'Marriage',
                'is_believer' => true,
                'denomination' => 'Non-denominational',
                'has_kids' => false,
                'kids_count' => null,
                'education_level' => 'Undergraduate Degree',
                'occupation' => 'Technology',
                'financial_status' => 'Financially stable',
                'country' => 'Kenya',
                'county_state' => 'Nairobi',
                'willing_to_relocate' => false,

                'interests' => ['Hiking', 'Coffee', 'Photography', 'Rock', 'Cooking'],
                'show_me' => 'Women',
                'age_min' => 24,
                'age_max' => 34,
                'admin_contact_consent' => false,

                'email_verified' => true,
                'phone_verified' => false,

                'completed_step' => 5,
            ],
        );

        $profile->photos()->delete();
        foreach ([21, 22, 23] as $position => $photoId) {
            $profile->photos()->create([
                'position' => $position,
                'path' => "https://randomuser.me/api/portraits/men/{$photoId}.jpg",
                'is_main' => $position === 0,
            ]);
        }

        return $user;
    }

    private function createMatchWithThread(User $me, string $partnerEmail, array $thread): void
    {
        $partner = User::where('email', $partnerEmail)->first();
        if (! $partner) return;

        // Both sides "like" each other so the pair is a real mutual match.
        Like::updateOrCreate(
            ['user_id' => $me->id, 'target_user_id' => $partner->id],
            ['action' => Like::ACTION_LIKE],
        );
        Like::updateOrCreate(
            ['user_id' => $partner->id, 'target_user_id' => $me->id],
            ['action' => Like::ACTION_LIKE],
        );

        [$low, $high] = MatchRecord::pairIds($me->id, $partner->id);
        $match = MatchRecord::updateOrCreate(
            ['user_low_id' => $low, 'user_high_id' => $high],
            ['matched_at' => Carbon::now()->subHours(72)],
        );

        // Reset any previous messages for this match so the seeder is idempotent.
        $match->messages()->delete();

        foreach ($thread as [$who, $body, $minutesAgo]) {
            $senderId = $who === 'me' ? $me->id : $partner->id;
            $sentAt = Carbon::now()->subMinutes($minutesAgo);
            $readAt = $who === 'them' && $minutesAgo > 15 ? $sentAt->copy()->addMinutes(2) : null;

            Message::create([
                'match_id' => $match->id,
                'sender_id' => $senderId,
                'body' => $body,
                'read_at' => $readAt,
                'created_at' => $sentAt,
                'updated_at' => $sentAt,
            ]);
        }
    }
}
