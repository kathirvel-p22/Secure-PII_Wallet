# Secure PII Wallet - Dual Security System

## Overview
This application implements an advanced two-layer security system with military-grade encryption and complete data control.

## Security Layers

### Layer 1: Master Password (Strong Password)
- **Purpose**: Protects critical operations
- **Requirements**:
  - Minimum 10 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character (!@#$%^&*)
- **Used For**:
  - Factory Reset (delete all files)
  - Lock & Reset (complete system reset)
  - Other critical operations

### Layer 2: PIN (4 or 6 digits)
- **Purpose**: Quick app unlock
- **Options**:
  - 4-digit PIN (quick & easy)
  - 6-digit PIN (more secure)
- **Used For**:
  - Unlocking the app after it's locked
  - Daily access to the application

## First-Time Setup Flow

When you open the app for the first time:

1. **Onboarding Slides** - Learn about app features
   - Military-Grade Security
   - Shamir's Secret Sharing
   - PII Detection
   - Secure Storage
   - Access Control

2. **Master Password Setup** - Create your strong password
   - Password strength indicator
   - Real-time validation
   - Requirements checklist

3. **PIN Setup** - Create your unlock PIN
   - Choose 4 or 6 digits
   - Confirm PIN
   - Secure storage

4. **Dashboard** - Start using the app

## Reset Options

### Option 1: Factory Reset
**What it does:**
- ✅ Deletes ALL files and encrypted data
- ✅ Clears all settings and preferences
- ❌ Keeps your PIN
- ❌ Keeps your master password

**When to use:**
- You want to clear all stored files
- You want to start fresh with file storage
- You want to keep your security credentials

**Access:**
Settings → Danger Zone → Factory Reset

**Security:**
Requires master password verification

---

### Option 2: Lock & Reset (Complete System Reset)
**What it does:**
- ✅ Deletes ALL files and encrypted data
- ✅ Deletes master password
- ✅ Deletes PIN code
- ✅ Clears all settings and preferences
- ✅ Restarts app from the beginning

**When to use:**
- You want to completely reset the app
- You want to start over like a fresh installation
- You're giving the device to someone else
- Maximum security cleanup

**Access:**
Settings → Danger Zone → Lock & Reset

**Security:**
Requires master password verification

**After Reset:**
The app will restart and show:
1. Onboarding slides
2. Master password setup
3. PIN setup
4. Dashboard (empty)

## File Security

### Standard Security Mode
- AES-256 encryption
- Password-based encryption
- Single password unlock

### High Security Mode
- AES-256 encryption
- Shamir's Secret Sharing (SSS)
- Configurable shares (3-10 total)
- Configurable threshold (2 to total)
- Shares can be entered in any order
- Mathematical security over GF(256)

## Session Management

- Auto-lock timer (configurable: 1-30 minutes)
- Failed attempt tracking
- Temporary lock after 5 failed attempts
- Session state management

## Data Storage

- All data stored locally (browser localStorage for web)
- Zero-knowledge architecture
- No data sent to external servers
- Complete user control

## Backup & Export

- Export encrypted vault with password
- Import vault from backup
- Backup includes all files and metadata
- Encrypted with user-provided password

## Security Best Practices

1. **Master Password**:
   - Use a unique, strong password
   - Store it safely (password manager recommended)
   - Cannot be recovered if forgotten

2. **PIN**:
   - Don't use obvious patterns (1234, 0000)
   - Don't share with others
   - Change regularly

3. **Backups**:
   - Export vault regularly
   - Store backups securely
   - Use strong backup passwords

4. **High Security Files**:
   - Use SSS for sensitive documents
   - Store shares in different locations
   - Keep threshold reasonable (not too low)

## Technical Details

- **Encryption**: AES-256-CBC
- **Key Derivation**: PBKDF2
- **Secret Sharing**: Shamir's Secret Sharing over GF(256)
- **Hash Function**: SHA-256
- **Storage**: FlutterSecureStorage (mobile), localStorage (web)

## Support

For issues or questions, please refer to the documentation or contact support.

---

**Version**: 1.0.0  
**Last Updated**: 2026-04-25
