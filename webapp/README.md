# ANTConnect Custom Config Server

A minimal Java web application that generates dynamically signed `custom.txt` configuration files for ANTConnect (customized RustDesk) installations.

## Features

- **Dynamic Password Generation**: Creates secure random 20-character passwords for each request
- **Ed25519 Signing**: Signs configurations with your RustDesk server's private key
- **Simple API**: Single endpoint for configuration generation

## Requirements

- Java 11 or higher
- Maven 3.6+
- RustDesk Server with Ed25519 private key

## Installation

### Manual Installation

1. Build the project:
```bash
mvn clean package
```

2. Run the server:
```bash
java -jar target/custom-config-server-1.0.0.jar
```

### Systemd Service Installation (Recommended for Production)

1. Build the project:
```bash
mvn clean package
```

2. Install as a systemd service:
```bash
sudo ./install-service.sh
```

This will:
- Copy the JAR file to `/opt/webapp/`
- Create a systemd service that runs as root
- Enable and start the service automatically
- Configure the service to restart on failure

To uninstall the service:
```bash
sudo ./uninstall-service.sh
```

## Configuration

The server can be configured using environment variables:

- `RUSTDESK_PRIVATE_KEY`: Path to Ed25519 private key (default: `/var/lib/rustdesk-server/id_ed25519`)
- `PORT`: Server port (default: `8080`)
- `API_SERVER`: RustDesk API server URL (default: `https://connect.antme.com`)
- `RENDEZVOUS_SERVER`: RustDesk rendezvous server (default: `connect.antme.com`)
- `PUBLIC_KEY`: Server's Ed25519 public key (default: `SC5N44NeqIn1Jd65zaBAR58+PMpxv+NxkvyX7ZXHGJc=`)

Example:
```bash
export RUSTDESK_PRIVATE_KEY=/path/to/id_ed25519
export PORT=8080
java -jar target/custom-config-server-1.0.0.jar
```

## API Endpoint

### Generate Configuration

**GET /custom.txt**
- Generates a configuration with a random password
- Returns: Base64-encoded signed configuration file
- Content-Type: `text/plain`
- The file is served with `Content-Disposition: attachment; filename="custom.txt"`

## Usage Example

Download custom.txt with a randomly generated password:
```bash
curl -O http://localhost:8080/custom.txt
```

## Generated Configuration

Each custom.txt contains:
- A random 20-character password (letters and numbers)
- Settings to disable address book, account, and settings UI
- Connection type set to "incoming" only
- Pre-configured server endpoints
- Digital signature for verification

## Building ANTConnect Installer

1. Place the generated `custom.txt` in the same directory as the MSI installer
2. When users run the installer, it will automatically use the configuration
3. Each installation gets a unique password for incoming connections

## Security Notes

- Keep your Ed25519 private key secure
- Use HTTPS in production with proper certificates
- Consider implementing rate limiting or authentication
- Each request generates a new random password

## Docker Deployment (Optional)

Create a Dockerfile:
```dockerfile
FROM openjdk:11-jre-slim
COPY target/custom-config-server-1.0.0.jar /app.jar
EXPOSE 8080
CMD ["java", "-jar", "/app.jar"]
```

Build and run:
```bash
docker build -t antconnect-config-server .
docker run -p 8080:8080 -v /var/lib/rustdesk-server:/keys:ro antconnect-config-server
```