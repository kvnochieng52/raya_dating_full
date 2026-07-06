<?php

namespace Database\Seeders;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class ProfileSeeder extends Seeder
{
    /**
     * Seeds a varied roster of discoverable profiles for manual testing.
     *
     * All seeded users share the password "password" and have
     * @kingdomdating.test emails so they are easy to spot.
     */
    public function run(): void
    {
        // [nickname, full_name, photo_indexes (randomuser.me ids)]
        $men = [
            ['Daniel', 'Daniel Otieno',    [11, 12, 13]],
            ['Joshua', 'Joshua Mwangi',    [22, 23, 24]],
            ['Caleb',  'Caleb Kariuki',    [33, 34, 35]],
            ['Samuel', 'Samuel Njoroge',   [44, 45, 46]],
            ['Elijah', 'Elijah Wanjiku',   [55, 56, 57]],
            ['David',  'David Achieng',    [66, 67, 68]],
            ['Isaac',  'Isaac Mutua',      [77, 78, 79]],
            ['Aaron',  'Aaron Kiprop',     [88, 89, 90]],
            ['Noah',   'Noah Onyango',     [1,  2,  3]],
            ['Levi',   'Levi Wachira',     [4,  5,  6]],
        ];
        $women = [
            ['Sarah',    'Sarah Wanjiru',   [11, 12, 13]],
            ['Esther',   'Esther Akinyi',   [22, 23, 24]],
            ['Ruth',     'Ruth Njeri',      [33, 34, 35]],
            ['Hannah',   'Hannah Adhiambo', [44, 45, 46]],
            ['Mary',     'Mary Wambui',     [55, 56, 57]],
            ['Rebecca',  'Rebecca Atieno',  [66, 67, 68]],
            ['Naomi',    'Naomi Chebet',    [77, 78, 79]],
            ['Abigail',  'Abigail Kemunto', [88, 89, 90]],
            ['Leah',     'Leah Mumbi',      [1,  2,  3]],
            ['Priscilla','Priscilla Atieno',[4,  5,  6]],
        ];

        $denominations = [
            'Baptist', 'Catholic', 'Pentecostal', 'Methodist',
            'Anglican / Episcopal', 'Presbyterian', 'Non-denominational',
            'Seventh-day Adventist', 'Charismatic',
        ];
        $bodyTypes = ['Slim', 'Athletic', 'Average', 'Curvy', 'Fit', 'Muscular', 'Thick'];
        $maritalStatuses = ['Single', 'Divorced', 'Widowed'];
        $educations = [
            'High School', 'Some College', 'Undergraduate Degree',
            'Graduate Degree', 'PhD/Doctoral',
        ];
        $occupations = [
            'Technology', 'Healthcare', 'Education', 'Finance',
            'Business', 'Engineering', 'Marketing', 'Legal',
        ];
        $financial = [
            'Just starting out', 'Financially stable', 'Doing well',
        ];
        $interestPool = [
            'Gym', 'Running', 'Yoga', 'Hiking', 'Cycling',
            'Cooking', 'Coffee', 'Wine', 'Baking',
            'Pop', 'Rock', 'Hip-Hop', 'Jazz', 'Classical',
            'Action', 'Comedy', 'Drama', 'Sci-Fi', 'Romance',
            'Fiction', 'Non-Fiction', 'Biography', 'Poetry',
            'Beach', 'Mountains', 'Adventure', 'Backpacking',
            'Photography', 'Art & Culture',
        ];

        $bios = [
            'Coffee lover, beach walker, and Sunday-morning singer.',
            'Trying to live a Christ-centered life one prayer at a time.',
            'Adventurer, foodie, and reader of way too many books.',
            'Just out here doing what God put me here to do.',
            'Looking for someone to share weekend hikes with.',
            'Faith first, family always, friends forever.',
            'Loves Jesus, sunsets, and a good cup of chai.',
            'Engineer by day, worship leader by night.',
            'Quiet evenings in beat loud nights out.',
            'Looking for a partner who challenges me to grow.',
        ];

        // Centre on Nairobi; spread within ~5 km.
        $baseLat = -1.2864;
        $baseLng = 36.8172;

        foreach ($men as $i => [$nickname, $fullName, $photoIds]) {
            $this->createSeededUser(
                index: $i + 1,
                gender: 'Man',
                nickname: $nickname,
                fullName: $fullName,
                photoIds: $photoIds,
                photoFolder: 'men',
                denominations: $denominations,
                bodyTypes: $bodyTypes,
                maritalStatuses: $maritalStatuses,
                educations: $educations,
                occupations: $occupations,
                financial: $financial,
                interestPool: $interestPool,
                bios: $bios,
                baseLat: $baseLat,
                baseLng: $baseLng,
            );
        }

        foreach ($women as $i => [$nickname, $fullName, $photoIds]) {
            $this->createSeededUser(
                index: $i + 1,
                gender: 'Woman',
                nickname: $nickname,
                fullName: $fullName,
                photoIds: $photoIds,
                photoFolder: 'women',
                denominations: $denominations,
                bodyTypes: $bodyTypes,
                maritalStatuses: $maritalStatuses,
                educations: $educations,
                occupations: $occupations,
                financial: $financial,
                interestPool: $interestPool,
                bios: $bios,
                baseLat: $baseLat,
                baseLng: $baseLng,
            );
        }
    }

    private function createSeededUser(
        int $index,
        string $gender,
        string $nickname,
        string $fullName,
        array $photoIds,
        string $photoFolder,
        array $denominations,
        array $bodyTypes,
        array $maritalStatuses,
        array $educations,
        array $occupations,
        array $financial,
        array $interestPool,
        array $bios,
        float $baseLat,
        float $baseLng,
    ): void {
        $genderSlug = strtolower($gender);
        $email = "seed.{$genderSlug}.{$index}@kingdomdating.test";

        $user = User::firstOrCreate(
            ['email' => $email],
            [
                'name' => $fullName,
                'password' => Hash::make('password'),
            ],
        );

        $age = 22 + (($index * 3) % 18); // 22..39
        $birthDate = Carbon::today()->subYears($age)->subDays($index * 7);

        $interests = collect($interestPool)
            ->shuffle()
            ->take(4 + ($index % 3)) // 4..6 interests
            ->values()
            ->all();

        $showMe = $gender === 'Man' ? 'Women' : 'Men';
        $isBeliever = $index % 5 !== 0; // ~80% believers
        $hasKids = $index % 4 === 0;    // ~25% have kids

        // Spread 0..0.05 degrees from base (≈ up to ~5.5 km).
        $latJitter = (($index * 137) % 1000 - 500) / 10000;
        $lngJitter = (($index * 211) % 1000 - 500) / 10000;

        $profile = $user->profile()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'nickname' => $nickname,
                'birth_date' => $birthDate,
                'gender' => $gender,
                'marital_status' => $maritalStatuses[$index % count($maritalStatuses)],
                'body_type' => $bodyTypes[$index % count($bodyTypes)],
                'bio' => $bios[$index % count($bios)],

                'kingdom_purpose' => 'Dating',
                'relationship_goal' => $index % 2 === 0 ? 'Marriage' : 'Long-term relationship',
                'is_believer' => $isBeliever,
                'denomination' => $isBeliever ? $denominations[$index % count($denominations)] : null,
                'has_kids' => $hasKids,
                'kids_count' => $hasKids ? 1 + ($index % 3) : null,
                'education_level' => $educations[$index % count($educations)],
                'occupation' => $occupations[$index % count($occupations)],
                'financial_status' => $financial[$index % count($financial)],
                'country' => 'Kenya',
                'county_state' => 'Nairobi',
                'willing_to_relocate' => $index % 2 === 0,

                'interests' => $interests,
                'show_me' => $showMe,
                'age_min' => 22,
                'age_max' => 45,
                'max_distance' => 80,
                'admin_contact_consent' => false,

                // Mix of verification states.
                'email_verified' => $index % 3 !== 0,
                'phone_verified' => $index % 4 === 0,

                'latitude' => $baseLat + $latJitter,
                'longitude' => $baseLng + $lngJitter,
                'location_updated_at' => now(),

                'completed_step' => 5,
            ],
        );

        // Replace any existing seeded photos so re-running is idempotent.
        $profile->photos()->delete();
        foreach ($photoIds as $position => $photoId) {
            $profile->photos()->create([
                'position' => $position,
                'path' => "https://randomuser.me/api/portraits/{$photoFolder}/{$photoId}.jpg",
                'is_main' => $position === 0,
            ]);
        }
    }
}
