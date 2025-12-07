# Linux Web Server Deployment with Security Hardening

A Puppet-based configuration management solution for deploying and hardening Apache web servers on Linux systems. This project implements security best practices including principle of least privilege, SSH key authentication, and comprehensive deployment validation.

## 📋 Overview

This project provides automated deployment and configuration of a secure Apache web server using:
- **Puppet** for infrastructure as code and configuration management
- **Bash scripting** for deployment validation and logging
- **Security hardening** following Linux security best practices

## 🔧 Components

### 1. Puppet Manifest (`site.pp`)

The main Puppet configuration that handles:

#### User & Group Management
- Creates `deployers` group for deployment operations
- Configures `deploy` user with limited sudo privileges
- Creates `admin` user with 4096-bit RSA SSH key authentication

#### Security Hardening
- **Principle of Least Privilege**: Deploy user restricted to only essential commands:
  - `/usr/bin/test -s /var/www/html/index.html`
  - `/usr/bin/systemctl restart apache2`
  - `/usr/bin/nc -z localhost 80`
- **Secure Permissions**: Sudoers file set to `0440` (read-only for owner/group)
- **SSH Key Generation**: Automated 4096-bit RSA key creation for admin user
- **Proper Directory Permissions**: SSH directory secured with `0700` permissions

#### Web Server Configuration
- Installs and configures Apache2
- Ensures Apache service is running and enabled at boot
- Creates custom `index.html` with dynamic date generation
- Sets proper ownership (`www-data:www-data`) and permissions (`0644`)

### 2. Deployment Script (`deploy_site.sh`)

A comprehensive deployment validation script featuring:

#### Logging System
- Centralized logging to `/var/log/deploy.log`
- Timestamp formatting: `YYYY-MM-DD HH:MM:SS`
- Complete audit trail of all deployment operations

#### Pre-flight Checks
1. **Port Verification**: Validates Apache is listening on port 80 using `netcat`
2. **File Validation**: Ensures `index.html` exists and is not empty
3. **Service Restart**: Gracefully restarts Apache2 with error handling

#### Error Handling
- Exit code 1 on any failure
- Detailed error messages logged for troubleshooting
- Step-by-step operation logging

## 🚀 Quick Start

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y puppet apache2 netcat

# RHEL/CentOS
sudo yum install -y puppet httpd nc
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/linux-webserver-hardening.git
   cd linux-webserver-hardening
   ```

2. **Apply Puppet configuration**
   ```bash
   sudo puppet apply site.pp
   ```

3. **Run deployment script**
   ```bash
   sudo chmod +x deploy_site.sh
   sudo ./deploy_site.sh
   ```

4. **Verify deployment**
   ```bash
   # Check Apache status
   systemctl status apache2
   
   # View deployment logs
   tail -f /var/log/deploy.log
   
   # Test web server
   curl http://localhost
   ```

## 📁 Project Structure

```
.
├── site.pp           # Puppet manifest for system configuration
├── deploy_site.sh    # Deployment validation and logging script
└── README.md         # Project documentation
```

## 🔒 Security Features

### Access Control
- **Limited Sudo**: Deploy user restricted to specific commands only
- **No Password Sudo**: Automated deployments without password prompts
- **Group-based Permissions**: Organized access control via `deployers` group

### SSH Security
- **4096-bit RSA Keys**: Strong encryption for admin access
- **Automated Key Generation**: Consistent key creation process
- **Secure Directory Permissions**: `~/.ssh` protected with `0700`

### Audit & Compliance
- **Comprehensive Logging**: All deployment actions logged with timestamps
- **Operation Tracking**: START/END markers for each deployment
- **Error Documentation**: Failed operations recorded for analysis

## 📊 Deployment Log Example

```
2024-12-07 10:15:23 START deploy
2024-12-07 10:15:23 Server listening on port 80
2024-12-07 10:15:23 /var/www/html/index.html ok
2024-12-07 10:15:24 apache2 restarted
2024-12-07 10:15:24 END deploy
```

## 🛠️ Customization

### Modify Web Content

Edit the inline template in `site.pp` (lines 56-62):

```puppet
content => inline_template('<html>
  <head><title>Your Title</title></head>
  <body>
    <h1>Your Custom Message</h1>
    <p>Today\'s date is <%= Time.now.strftime("%Y-%m-%d") %></p>
  </body>
</html>')
```

### Add Additional Users

Extend the Puppet manifest:

```puppet
user { 'newuser':
  ensure     => present,
  managehome => true,
  groups     => ['deployers'],
}
```

### Modify Log Location

Change the `LOG` variable in `deploy_site.sh`:

```bash
LOG="/your/custom/path/deploy.log"
```

## 🔍 Troubleshooting

### Apache Not Starting

```bash
# Check Apache configuration
sudo apache2ctl configtest

# View Apache logs
sudo tail -f /var/log/apache2/error.log
```

### Deployment Script Fails

```bash
# Check deployment log
sudo cat /var/log/deploy.log

# Verify file permissions
ls -la /var/www/html/index.html

# Test port manually
nc -z localhost 80 && echo "Port 80 is open"
```

### Puppet Apply Errors

```bash
# Run Puppet in verbose mode
sudo puppet apply site.pp --verbose

# Check Puppet syntax
puppet parser validate site.pp
```

## 📝 Best Practices

1. **Version Control**: Always commit changes before applying configurations
2. **Testing**: Test Puppet manifests in development environment first
3. **Backups**: Backup `/etc/sudoers.d/` before modifications
4. **Log Rotation**: Configure logrotate for `/var/log/deploy.log`
5. **SSH Keys**: Backup admin SSH keys securely

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Daniel Ohana**

## 🔗 Related Resources

- [Puppet Documentation](https://puppet.com/docs/puppet/latest/puppet_index.html)
- [Apache Security Tips](https://httpd.apache.org/docs/2.4/misc/security_tips.html)
- [Linux Security Best Practices](https://www.cisecurity.org/cis-benchmarks/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/bash.html)

## ⚠️ Important Notes

- **Production Use**: Review and test all configurations before production deployment
- **Sudo Configuration**: Validate sudoers syntax before applying (`visudo -c`)
- **Personal Information**: Remember to update the name in `site.pp` line 59 if forking
- **Port Access**: Ensure firewall rules allow HTTP traffic on port 80

---

**Last Updated**: December 2024
