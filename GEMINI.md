# 🌌 Erika

Erika is a minimalist, secure, and ephemeral pastebin service utilizing SSH
for ingestion, Nginx for delivery, and Cron for cleanup.

---

## 🏗️ Architecture Overview

- Client Ingestion:
  The client pipes data from `stdin` directly to the server script via an encrypted SSH session.
- Payload Processing:
  The server-side script reads the incoming stream and generates a static text file
  in a designated web-root directory.
- ID Generation:
  Each paste is assigned a unique, 4-character alphanumeric ID (e.g., `aB9x`)
  which serves as the filename.
- Web Egress:
  Nginx handles reverse proxying and directly serves the static files
  from the storage directory over HTTPS.
- Lifecycle Management (TTL):
  A automated cron job runs periodically to purge files older than 24 hours,
  ensuring the service remains ephemeral.
- Containerization:
  The entire stack (Nginx, cron, and the processing script) is encapsulated
  within a Docker container to guarantee portability and trivial deployment.

---

## 🛠️ Components

### 1. SSH Ingestion

- **User:** Unprivileged `paste` user with passwordless login
	and public-key auth only.
- **Forced Command:** Locked down in `authorized_keys` to prevent shell access:
```text
command="/usr/local/bin/server_paste.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding <client_pubkey>
```

### 2. Ingestion Script `server_paste.sh`

- Reads raw text from `stdin`.
- Generates an 8-character random hex ID.
- Saves the content to `/var/www/pastes/<id>` (permissions `644`).
- Returns the URL via `stdout` to the client.

### 3. Web Server (Nginx)

- Serves `/var/www/pastes/` statically.
- Forces `default_type text/plain;`
	so pastes render as raw text in the browser.

### 4. Cleanup (Cron)

- Hourly cron job deletes pastes older than 24 hours:
```bash
find /var/www/pastes -type f -mmin +1440 -delete
```

---

## 🔒 Security

- **No Shell Access:** Forced commands limit SSH keys to paste ingestion.
- **No DB/Backend:** Zero SQL/NoSQL injection surface.
- **Read-Only / No Traversal:** Clients can only stream new content;
	existing pastes cannot be modified or traversed via SSH.
