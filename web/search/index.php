<?php
$conn = pg_connect("host=127.0.0.1 port=5432 dbname=company user=webapp password=webapp123");
$id = $_GET['id'] ?? '';
$output = '';
if ($id !== '') {
    $result = pg_query($conn, "SELECT name, department FROM employees WHERE id = $id");
    if ($result) {
        while ($row = pg_fetch_assoc($result)) {
            $output .= '<tr><td>' . $row['name'] . '</td><td>' . $row['department'] . '</td></tr>';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>MeowMeowCat92 - Staff Portal</title>
  <style>
    body { font-family: 'Segoe UI', sans-serif; background: #f4f6f9; color: #333; margin: 0; }
    header { background: #1a2c4e; color: white; padding: 16px 32px; }
    header h1 { font-size: 1.3rem; }
    .container { max-width: 700px; margin: 48px auto; background: white; border-radius: 8px; padding: 36px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    h2 { color: #1a2c4e; margin-bottom: 20px; }
    form { display: flex; gap: 10px; margin-bottom: 28px; }
    input[type=text] { flex: 1; padding: 9px 14px; border: 1px solid #ccd; border-radius: 4px; font-size: 0.95rem; }
    button { background: #2e5fa3; color: white; border: none; padding: 9px 22px; border-radius: 4px; cursor: pointer; font-size: 0.95rem; }
    button:hover { background: #1a2c4e; }
    table { width: 100%; border-collapse: collapse; }
    th { background: #1a2c4e; color: white; padding: 10px 14px; text-align: left; }
    td { padding: 10px 14px; border-bottom: 1px solid #eee; }
    tr:hover td { background: #f0f4fa; }
    .hint { color: #999; font-size: 0.85rem; margin-top: 12px; }
  </style>
</head>
<body>
<header>
  <h1>MeowMeowCat92 Solutions &mdash; Staff Portal</h1>
</header>
<div class="container">
  <h2>Employee Lookup</h2>
  <form method="GET" action="">
    <input type="text" name="id" placeholder="Enter employee ID" value="<?= htmlspecialchars($id) ?>">
    <button type="submit">Search</button>
  </form>
  <?php if ($output): ?>
  <table>
    <thead><tr><th>Name</th><th>Department</th></tr></thead>
    <tbody><?= $output ?></tbody>
  </table>
  <?php elseif ($id !== ''): ?>
  <p style="color:#c0392b;">No employee found.</p>
  <?php endif; ?>
  <p class="hint">Internal use only. Authorised personnel only.</p>
  <p style="margin-top:16px;font-family:monospace;color:#2e5fa3;">SMC{P4TH_FINDER}</p>
</div>
</body>
</html>
