<?php
// Creates Databasement's first (super admin) user from ADMIN_EMAIL and
// ADMIN_PASSWORD while the user table is empty. Does nothing afterwards, so
// changing the variables later does not change the account: use the profile page
// or `php artisan user:reset-password` for that.
require '/app/vendor/autoload.php';
$app = require '/app/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

if (App\Models\User::count() > 0) {
    echo "[railway] admin already exists, nothing to do\n";
    exit(0);
}

$email = getenv('ADMIN_EMAIL') ?: 'admin@databasement.local';
$password = getenv('ADMIN_PASSWORD') ?: '';
if (strlen($password) < 12) {
    fwrite(STDERR, "[railway] ADMIN_PASSWORD must be set (12+ characters) for the first boot; refusing to open public registration\n");
    exit(1);
}

app(App\Actions\Fortify\CreateNewUser::class)->create([
    'name' => 'Admin',
    'email' => $email,
    'password' => $password,
    'password_confirmation' => $password,
    // Upstream's "add Databasement's own database as a demo backup" option:
    // a "Local Backups" volume at /data/backups and a daily backup of the app DB.
    'create_demo_backup' => '1',
]);
echo "[railway] admin created: {$email}\n";
