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
 * Creates the demo "Alex" account with mutual matches, rich chat threads, and
 * received likes so Play Store screenshots look real and lived-in.
 *
 * Login:  demo@kingdomdating.test / password
 *
 * Requires ProfileSeeder to have run first. Safe to re-run (idempotent).
 */
class DemoContentSeeder extends Seeder
{
    public function run(): void
    {
        $demo = $this->createDemoUser();
        $this->seedMatches($demo);
        $this->seedIncomingLikes($demo);
    }

    // ─── Demo user (the "you" account) ────────────────────────────────────────

    private function createDemoUser(): User
    {
        $user = User::firstOrCreate(
            ['email' => 'demo@kingdomdating.test'],
            ['name' => 'Alex Kamau', 'password' => Hash::make('password')],
        );

        $user->profile()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'nickname'          => 'Alex',
                'birth_date'        => Carbon::today()->subYears(29)->subMonths(4),
                'gender'            => 'Man',
                'marital_status'    => 'Single',
                'body_type'         => 'Athletic',
                'bio'               => 'Engineer by day, worship team on Sundays. Love long hikes, honest conversations, and a strong cup of coffee. Proverbs 3:5-6 keeps me grounded.',
                'kingdom_purpose'   => 'Dating',
                'relationship_goal' => 'Marriage',
                'is_believer'       => true,
                'denomination'      => 'Non-denominational',
                'has_kids'          => false,
                'kids_count'        => null,
                'education_level'   => 'Undergraduate Degree',
                'occupation'        => 'Technology',
                'financial_status'  => 'Financially stable',
                'country'           => 'Kenya',
                'county_state'      => 'Nairobi',
                'willing_to_relocate' => false,
                'interests'         => ['Hiking', 'Coffee', 'Photography', 'Rock', 'Cooking'],
                'show_me'           => 'Women',
                'age_min'           => 23,
                'age_max'           => 35,
                'admin_contact_consent' => false,
                'email_verified'    => true,
                'phone_verified'    => false,
                'completed_step'    => 5,
            ],
        );

        $user->profile->photos()->delete();
        foreach ([21, 22, 23] as $pos => $id) {
            $user->profile->photos()->create([
                'position' => $pos,
                'path'     => "https://randomuser.me/api/portraits/men/{$id}.jpg",
                'is_main'  => $pos === 0,
            ]);
        }

        return $user;
    }

    // ─── Matches with chat threads ─────────────────────────────────────────────

    private function seedMatches(User $demo): void
    {
        // Each entry: [partner_email, matched_hours_ago, thread]
        // Thread rows: ['me'|'them', message_body, minutes_ago]
        $scripts = [

            // 1 ── Sarah: warm, progressing towards meeting ────────────────────
            [
                'seed.woman.1@kingdomdating.test',
                72,
                [
                    ['them', 'Hi Alex! I just read your profile and the worship team part caught my attention immediately 🎶', 60 * 26],
                    ['me',   'Hey Sarah! Ha — it is a big part of my life. Do you sing?', 60 * 25],
                    ['them', 'I lead worship at our church plant in Kilimani! Alto section. You play or sing?', 60 * 25 - 10],
                    ['me',   'Guitar. Acoustic mostly. Which church is the plant?', 60 * 24],
                    ['them', 'Crossroads Community — we just turned two years old. Small but the presence is real.', 60 * 23],
                    ['me',   'That is beautiful. I am at CITAM Valley Road — been there six years now. I love how God is raising up new local churches.', 60 * 10],
                    ['them', 'Yes! Community is everything. So — coffee or lunch sometime? I would love to hear you play 😊', 60 * 3],
                    ['me',   'Absolutely. Sunday afternoon works for me if it works for you?', 55],
                    ['them', 'Sunday it is. Can not wait 🙌', 10],
                ],
            ],

            // 2 ── Ruth: adventure and shared faith ───────────────────────────
            [
                'seed.woman.3@kingdomdating.test',
                96,
                [
                    ['me',   'Ruth! Your Longonot photo is everything. How long did that take?', 60 * 48],
                    ['them', 'About 6 hours total including the crater walk. Your legs feel it for days 😅', 60 * 47],
                    ['me',   'Ha — noted. I have been meaning to do it for two years. Any tips?', 60 * 46],
                    ['them', 'Start before 6 AM, bring twice the water you think you need, and stretch properly the night before.', 60 * 45],
                    ['me',   'Solid advice. Do you hike alone or with a group?', 60 * 30],
                    ['them', 'Usually 3 or 4 of us. Safer and more fun. We also do a short prayer at the summit — it feels right up there.', 60 * 20],
                    ['me',   'I love that. Faith + altitude 🙏 I would love to join one of those trips sometime.', 60 * 10],
                    ['them', 'We are planning Hell\'s Gate in six weeks if you want in! It is an easy one — good for a first-timer.', 40],
                    ['me',   'I am genuinely in. This is the best match conversation I have had 😄', 15],
                    ['them', 'Ha — same! Let me get your number so we can add you to the group chat.', 5],
                ],
            ],

            // 3 ── Mary: faith and tech talk ──────────────────────────────────
            [
                'seed.woman.5@kingdomdating.test',
                48,
                [
                    ['them', 'Hey! Fellow tech person here 🖥️ What stack do you work in?', 60 * 12],
                    ['me',   'Full-stack mostly — Laravel on the backend, Flutter on mobile. You?', 60 * 11],
                    ['them', 'React and Node. I tried Flutter once and loved it but my job does not need it yet.', 60 * 10],
                    ['me',   'It is worth it — once you go cross-platform you do not want to go back. So how do you balance the tech life and church life?', 60 * 8],
                    ['them', 'Honestly sometimes poorly 😂 But Sunday is non-negotiable. And I have Jeremiah 29:11 as my phone wallpaper so.', 60 * 7],
                    ['me',   'That verse has saved many a rough week. Mine is Proverbs 3:5-6. Trust first, figure out later.', 60 * 6],
                    ['them', 'Yes!! That is it exactly. Okay I like you already 😊', 60 * 5],
                    ['me',   'Ha — likewise. What brought you to Kingdom Dating?', 30],
                    ['them', 'Tired of explaining why my faith is not negotiable on secular apps. You?', 20],
                    ['me',   'Same exact reason. It is good to just start from a shared foundation.', 5],
                ],
            ],

            // 4 ── Naomi: light opener, playful ───────────────────────────────
            [
                'seed.woman.7@kingdomdating.test',
                24,
                [
                    ['me',   'Naomi 👋 I saw you are in Eldoret — do you ever come to Nairobi?', 60 * 5],
                    ['them', 'Almost every month for work! I am in logistics so I am always on the road.', 60 * 3],
                    ['me',   'That is convenient. Chai or coffee person?', 60 * 2],
                    ['them', 'Chai — always. Eldoret rain makes anything else feel wrong 😂', 45],
                    ['me',   'Fair point. I am a coffee person but I will never say no to good chai.', 20],
                    ['them', 'Good answer. Next time I am in Nairobi we should find out who wins that debate ☕', 8],
                    ['me',   'Challenge accepted. Just say when.', 2],
                ],
            ],

            // 5 ── Esther: thoughtful and warm ────────────────────────────────
            [
                'seed.woman.2@kingdomdating.test',
                120,
                [
                    ['them', 'Hi Alex! Your bio made me smile — engineer AND worship team is a rare combo.', 60 * 36],
                    ['me',   'Ha, it keeps life interesting! Are you musical at all Esther?', 60 * 35],
                    ['them', 'Not at all. I am a finance person through and through. Numbers are my love language 😄', 60 * 34],
                    ['me',   'Ha — opposite ends. I can barely keep a budget but I can tune a guitar in the dark.', 60 * 20],
                    ['them', 'We would balance each other out then 😂 So tell me — what does a perfect Sunday look like for you?', 60 * 10],
                    ['me',   'Morning service, lunch with family, afternoon hike or trail run, evening with a good book or just being outside. You?', 60 * 8],
                    ['them', 'Church, then a long run along the lake here in Kisumu, then cooking a proper meal. I find cooking very meditative.', 60 * 7],
                    ['me',   'The lake runs sound incredible. I have only been to Kisumu once — I did not appreciate it enough.', 30],
                    ['them', 'You need a proper guide. I know every good spot 😊', 10],
                ],
            ],

            // 6 ── Abigail: intellectual, slower burn ─────────────────────────
            [
                'seed.woman.8@kingdomdating.test',
                168,
                [
                    ['me',   'Abigail — a PhD in literature! What was your dissertation on?', 60 * 72],
                    ['them', 'Oral tradition and the preservation of faith in post-colonial East African writing. Very niche, very me 😅', 60 * 70],
                    ['me',   'That is genuinely fascinating. Do you think storytelling and faith are inseparable?', 60 * 68],
                    ['them', 'Completely. The Bible itself is story. I think the church has sometimes forgotten that.', 60 * 60],
                    ['me',   'That is such a sharp observation. I find that the most powerful sermons are the ones that tell a story rather than just teach a principle.', 60 * 40],
                    ['them', 'Yes! Narrative over proposition. What are you reading right now?', 60 * 20],
                    ['me',   'Just finished Atomic Habits, starting Mere Christianity for the third time. You?', 60 * 10],
                    ['them', 'C.S. Lewis — yes! I am working through Till We Have Faces. If you have not read it please do.', 60 * 5],
                    ['me',   'Added to the list immediately. You have good taste.', 20],
                ],
            ],
        ];

        foreach ($scripts as [$email, $matchedHoursAgo, $thread]) {
            $this->makeMatchWithThread($demo, $email, $matchedHoursAgo, $thread);
        }
    }

    // ─── Incoming likes (Likes received screen) ────────────────────────────────

    private function seedIncomingLikes(User $demo): void
    {
        $emails = [
            'seed.woman.4@kingdomdating.test',
            'seed.woman.6@kingdomdating.test',
            'seed.woman.9@kingdomdating.test',
            'seed.woman.10@kingdomdating.test',
        ];

        foreach ($emails as $email) {
            $sender = User::where('email', $email)->first();
            if (! $sender) continue;
            Like::updateOrCreate(
                ['user_id' => $sender->id, 'target_user_id' => $demo->id],
                ['action' => Like::ACTION_LIKE],
            );
        }
    }

    // ─── Helper ────────────────────────────────────────────────────────────────

    private function makeMatchWithThread(User $me, string $partnerEmail, int $matchedHoursAgo, array $thread): void
    {
        $partner = User::where('email', $partnerEmail)->first();
        if (! $partner) return;

        Like::updateOrCreate(
            ['user_id' => $me->id,      'target_user_id' => $partner->id],
            ['action' => Like::ACTION_LIKE],
        );
        Like::updateOrCreate(
            ['user_id' => $partner->id, 'target_user_id' => $me->id],
            ['action' => Like::ACTION_LIKE],
        );

        [$low, $high] = MatchRecord::pairIds($me->id, $partner->id);
        $match = MatchRecord::updateOrCreate(
            ['user_low_id' => $low, 'user_high_id' => $high],
            ['matched_at'  => Carbon::now()->subHours($matchedHoursAgo)],
        );

        $match->messages()->delete();

        foreach ($thread as [$who, $body, $minutesAgo]) {
            $senderId = $who === 'me' ? $me->id : $partner->id;
            $sentAt   = Carbon::now()->subMinutes($minutesAgo);
            $readAt   = ($who === 'them' && $minutesAgo > 15)
                ? $sentAt->copy()->addMinutes(rand(1, 4))
                : null;

            Message::create([
                'match_id'   => $match->id,
                'sender_id'  => $senderId,
                'body'       => $body,
                'read_at'    => $readAt,
                'created_at' => $sentAt,
                'updated_at' => $sentAt,
            ]);
        }
    }
}
