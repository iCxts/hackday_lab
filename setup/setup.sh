#!/bin/bash
set -e

# --- Database ---
service postgresql start
sleep 3

HASH=$(echo -n "sunshine" | md5sum | cut -d' ' -f1)

sudo -u postgres psql -c "CREATE USER webapp WITH PASSWORD 'webapp123';"
sudo -u postgres psql -c "CREATE DATABASE company OWNER webapp;"
sudo -u postgres psql -d company -c "
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    username TEXT,
    password TEXT,
    department TEXT
);
INSERT INTO employees (id, name, username, password, department) VALUES (1, 'John Smith', 'john', '${HASH}', 'Sales');
GRANT ALL ON employees TO webapp;
"

service postgresql stop

# --- Users ---
useradd -m -s /bin/bash john
echo "john:sunshine" | chpasswd
echo "root:R00t@SecureLab2024!" | chpasswd

# --- Flags ---
echo "SMC{UNI0N_BASED_CRACKED}" > /home/john/flag.txt
chown john:john /home/john/flag.txt
chmod 644 /home/john/flag.txt

echo "SMC{HIDDEN_ROOT}" > /root/.flag.txt
chmod 600 /root/.flag.txt

# --- Zip ---
mkdir -p /tmp/zipsrc
echo "SMC{ZIP_CRACKED}" > /tmp/zipsrc/flag.txt
printf "Admin Credentials\n-----------------\nUsername: root\nPassword: R00t@SecureLab2024!\n" > /tmp/zipsrc/admin_credentials.txt

cd /tmp && zip -P master123 /home/john/secret.zip zipsrc/flag.txt zipsrc/admin_credentials.txt
chown john:john /home/john/secret.zip
chmod 644 /home/john/secret.zip
rm -rf /tmp/zipsrc

# --- SSH ---
mkdir -p /var/run/sshd
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# --- Apache ---
a2enmod php8.1 2>/dev/null || true
