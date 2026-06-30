# Erika

Erika is a minimalist, secure, and ephemeral pastebin service utilizing SSH for ingestion, Nginx for delivery, and Cron for cleanup.

## Features

- **SSH Ingestion**: Pipe data directly over SSH.
- **Secure by Design**: Forced command limits SSH key access to paste ingestion only; no shell access.
- **Ephemeral Storage**: Automated hourly cron job deletes pastes older than 24 hours.
- **Nginx Egress**: Fast, lightweight static file delivery with raw plain text rendering.
- **Containerized**: Encapsulated stack containing SSH, Nginx, and Cron.

## Configuration

Erika can be configured using environment variables:

- `AUTHORIZED_HOSTS`: Direct contents of SSH public keys (one key per line) allowed to access the service.
- `AUTHORIZED_HOSTS_FILE`: Path inside the container to a file containing SSH public keys (suitable for Docker Secrets).

## Deployment

Deploy Erika using Docker Compose. Prepare an `authorized_hosts` file in the same directory containing the SSH public keys for authorized clients.

### Docker Compose Configuration

Create a `compose.yml` file:

```yaml
services:
  erika:
    build: .
    ports:
      - "2222:22"
      - "8080:80"
    environment:
      - AUTHORIZED_HOSTS_FILE=/run/secrets/authorized_hosts
    secrets:
      - authorized_hosts
    volumes:
      - pastes_data:/var/www/pastes

volumes:
  pastes_data:

secrets:
  authorized_hosts:
    file: ./authorized_hosts
```

Start the service:

```bash
docker compose up -d
```

## Usage

Pipelines can send text directly to the pastebin:

```bash
echo "Hello Erika" | ssh -p 2222 paste@localhost
```

Alternatively, use the client wrapper script:

```bash
echo "Hello Erika" | ./erika
```
