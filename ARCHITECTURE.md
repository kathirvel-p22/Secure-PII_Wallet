# 🏗️ Secure PII Wallet - Complete Architecture

## System Overview

This is a **military-grade encrypted personal information wallet** with end-to-end security, implementing a complete 10-layer architecture with defense-in-depth principles.

## 🎯 Core Principles

1. **Zero Trust**: Every access is verified
2. **Defense in Depth**: Multiple security layers
3. **Least Privilege**: Minimal permissions
4. **Secure by Default**: No plaintext storage
5. **Fail Secure**: Errors deny access

## 📊 10-Layer Architecture

### Layer 1: UI Layer (Cyber Theme)
**Location**: `lib/features/*/views/`, `lib/features/*/widgets/`

**Responsibilities**:
- Render UI components
- Capture user input
- Display feedback
- NO business logic

**Key Files**:
- `splash_screen.dart` - App initialization
- `unlock_screen.dart` - Session unlock
- `dashboard_screen.dart` - File list
- `upload_screen.dart` - File upload interface
- `file_viewer_screen.dart` - Secure file viewing

**Design System**:
- Colors: `lib/core/theme/colors.dart`
- Typography: `lib/core/theme/typography.dart`
- Theme: `lib/core/theme/app_theme.dart`

### Layer 2: Navigation Layer
**Location**: `lib/routing/app_router.dart`

**Responsibilities**:
- Route management
- Navigation guards
- Session-based redirects

**Routes**:
- `/` - Splash screen
- `/unlock` - Unlock screen (guarded)
- `/dashboard` - Main dashboard (requires unlock)
- `/upload` - Upload screen (requires unlock)
- `/viewer/:fileId` - File viewer (requires unlock)

**Guard Logic**:
```dart
if (session.locked && !goingToUnlock) {
  redirect('/unlock');
}
```

### Layer 3: State Management (Riverpod)
**Location**: `lib/providers/providers.dart`

**Providers**:
- `sessionProvider` - Session lock/unlock state
- `filesProvider` - File list state
- `securityProvider` - Security engine instance
- `cryptoProvider` - Crypto service instance
- `storageProvider` - Storage service instance
- `keyProvider` - Key service instance

**State Flow**:
```
User Action → Controller → Provider Update → UI Rebuild
```

### Layer 4: Controller Layer
**Location**: `lib/features/files/controllers/file_controller.dart`

**Responsibilities**:
- Orchestrate operations
- Call services in correct order
- Update state
- Handle errors

**Methods**:
- `upload()` - Complete upload pipeline
- `access()` - Complete access pipeline
- `delete()` - Complete delete pipeline

### Layer 5: Security Engine (Core Brain)
**Location**: `lib/core/security/security_engine.dart`

**Responsibilities**:
- Policy enforcement
- Access decisions
- Password validation
- Integrity verification
- Rate limiting

**Key Methods**:
- `isStrongPassword()` - Validate password strength
- `prepareAndStore()` - Complete upload with validation
- `access()` - Complete access with verification
- `secureDelete()` - Complete secure deletion

**Decision Tree**:
```
START
  ↓
Validate Password
  ↓ PASS
Mode Check
  ↓ HIGH
Validate Keys
  ↓ PASS
Decrypt
  ↓
Verify Integrity
  ↓ PASS
Allow Access
```

### Layer 6: Cryptography Layer
**Location**: `lib/core/crypto/crypto_service.dart`

**Algorithms**:
- **Encryption**: AES-256-CBC
- **Hashing**: SHA-256
- **IV**: Random 16 bytes per file

**Methods**:
- `encrypt()` - AES-256-CBC encryption
- `decrypt()` - AES-256-CBC decryption
- `hashPassword()` - SHA-256 password hashing
- `hashFile()` - SHA-256 file hashing
- `verifyPassword()` - Password verification
- `verifyIntegrity()` - File integrity check

**Encryption Flow**:
```
Password → SHA-256 → Key (32 bytes)
File + Key + IV → AES-256-CBC → Encrypted File
```

### Layer 7: Storage Layer
**Location**: `lib/core/storage/storage_service.dart`

**Storage Structure**:
```
/app_data/
  ├── encrypted/
  │   ├── <fileId>.bin  (encrypted file)
  │   └── <fileId>.iv   (initialization vector)
  └── metadata.json     (file metadata)
```

**Methods**:
- `writeEncrypted()` - Save encrypted file + IV
- `readEncrypted()` - Read encrypted file + IV
- `deleteEncrypted()` - Delete encrypted file + IV
- `loadMeta()` - Load all metadata
- `saveMeta()` - Save all metadata
- `addMeta()` - Add metadata entry
- `removeMeta()` - Remove metadata entry

### Layer 8: Key Management (SSS-Style)
**Location**: `lib/core/keys/key_service.dart`

**Key System**:
- 3 keys required (8 alphanumeric characters each)
- Keys stored as SHA-256 hashes
- All 3 required for access (no partial access)

**Methods**:
- `generateKeys()` - Generate 3 random keys
- `storeKeys()` - Store key hashes in secure storage
- `verifyKeys()` - Verify all 3 keys
- `deleteKeys()` - Delete key hashes
- `validateKeyFormat()` - Validate key format

**Storage**:
```
Secure Storage:
  keys_<fileId> → {
    fileId: string,
    keyHashes: [hash1, hash2, hash3]
  }
```

### Layer 9: Data Models
**Location**: `lib/features/files/models/`

**Models**:
- `FileMeta` - File metadata
- `EncryptedPayload` - Encrypted file + IV
- `KeyRecord` - Key hashes
- `SessionState` - Session lock state

### Layer 10: Monitoring & Defense
**Implementation**: Distributed across layers

**Features**:
- Auto-lock after inactivity
- Rate limiting (max 3 attempts)
- Temporary lock (2 minutes)
- Screenshot blocking (Android)
- Memory cleanup after viewing

## 🔄 Complete Workflows

### Upload Workflow

```
User Action: Select File
  ↓
UI Layer: UploadScreen
  ↓
Controller: FileController.upload()
  ↓
Security Engine: prepareAndStore()
  ├─ Validate password strength
  ├─ Validate keys (if HIGH)
  ├─ Read file bytes
  ├─ Generate file hash (SHA-256)
  ├─ Hash password (SHA-256)
  ↓
Crypto Service: encrypt()
  ├─ Derive key from password
  ├─ Generate random IV
  ├─ Encrypt with AES-256-CBC
  ↓
Storage Service: writeEncrypted()
  ├─ Save cipher to <fileId>.bin
  ├─ Save IV to <fileId>.iv
  ↓
Storage Service: addMeta()
  ├─ Create FileMeta
  ├─ Save to metadata.json
  ↓
Key Service: storeKeys() [if HIGH]
  ├─ Hash each key
  ├─ Save to secure storage
  ↓
State: Update filesProvider
  ↓
UI: Show success message
```

### Access Workflow

```
User Action: Tap File
  ↓
UI Layer: Show unlock dialog
  ├─ Enter password
  ├─ Enter keys (if HIGH)
  ↓
Controller: FileController.access()
  ↓
Security Engine: access()
  ├─ Get metadata
  ├─ Verify password hash
  ├─ Verify key hashes (if HIGH)
  ↓
Storage Service: readEncrypted()
  ├─ Read cipher from <fileId>.bin
  ├─ Read IV from <fileId>.iv
  ↓
Crypto Service: decrypt()
  ├─ Derive key from password
  ├─ Decrypt with AES-256-CBC
  ↓
Security Engine: verifyIntegrity()
  ├─ Hash decrypted file
  ├─ Compare with stored hash
  ├─ Throw if mismatch (TAMPER)
  ↓
Controller: Return file bytes
  ↓
UI: Navigate to viewer
  ├─ Display PDF/Image
  ├─ Keep in memory only
  ↓
On Close: Clear memory buffer
```

### Delete Workflow

```
User Action: Tap Delete
  ↓
UI Layer: Show confirmation dialog
  ↓
Controller: FileController.delete()
  ↓
Security Engine: secureDelete()
  ├─ Delete encrypted file
  ├─ Delete IV file
  ├─ Delete key hashes (if exist)
  ├─ Remove metadata entry
  ↓
State: Update filesProvider
  ↓
UI: Show success message
```

## 🔐 Security Features

### Password Policy
- Minimum 10 characters
- Must contain:
  - Uppercase letter
  - Lowercase letter
  - Number
  - Special character

### Key System (High Security)
- 3 keys required
- 8 alphanumeric characters each
- Auto-generated or user-defined
- Stored as SHA-256 hashes
- All 3 required for access

### Encryption
- **Algorithm**: AES-256-CBC
- **Key Size**: 256 bits (32 bytes)
- **Block Size**: 128 bits (16 bytes)
- **IV**: Random per file
- **Mode**: CBC (Cipher Block Chaining)

### Integrity
- **Algorithm**: SHA-256
- **Verification**: On every access
- **Tamper Detection**: Hash mismatch throws exception

### Session Management
- Auto-lock after 120 seconds inactivity
- Lock on app background
- Rate limiting: 3 failed attempts
- Temporary lock: 2 minutes

## 📦 Dependencies

### Core
- `flutter_riverpod` - State management
- `go_router` - Navigation

### Security
- `encrypt` - AES encryption
- `crypto` - SHA hashing
- `flutter_secure_storage` - Secure key storage

### File Handling
- `file_picker` - File selection
- `path_provider` - Storage paths
- `syncfusion_flutter_pdfviewer` - PDF viewing

### Utilities
- `uuid` - Unique file IDs
- `intl` - Date formatting

## 🎨 Design System

### Colors
```dart
bg: #0A0F1C          // Background
card: #121A2B        // Card background
neon: #00FF9C        // Primary accent
accent: #00C2FF      // Secondary accent
error: #FF4C4C       // Error state
textPrimary: #E6F1FF // Primary text
textSecondary: #7A8CA5 // Secondary text
```

### Typography (Roboto)
```dart
h1: 26px Bold        // App title
h2: 18px Medium      // Section title
body: 15px Regular   // Body text
button: 16px SemiBold // Button text
label: 12px Bold     // Labels (caps)
```

### Spacing
- Global padding: 16px
- Card radius: 16px
- Vertical rhythm: 12px / 16px / 24px
- Button height: 50px

## 🧪 Testing Strategy

### Unit Tests
- Crypto service (encryption/decryption)
- Security engine (validation logic)
- Key service (key generation/verification)

### Integration Tests
- Upload workflow
- Access workflow
- Delete workflow

### Security Tests
- Password strength validation
- Key format validation
- Integrity verification
- Rate limiting

## 🚀 Performance

### Optimizations
- Lazy loading of files
- Memory-only decryption
- Efficient state management
- Minimal re-renders

### Memory Management
- Clear buffers after viewing
- No caching of decrypted data
- Dispose controllers properly

## ⚠️ Security Considerations

### Threats Mitigated
✅ Unauthorized file access
✅ Password brute force
✅ File tampering
✅ Memory dumps (partial)
✅ Screenshot capture (Android)

### Limitations
⚠️ Device compromise (root/jailbreak)
⚠️ Memory forensics (advanced)
⚠️ Keyloggers
⚠️ Physical device access

### Best Practices
1. Use strong, unique passwords
2. Store keys securely offline
3. Enable device encryption
4. Use biometric lock
5. Regular security updates

## 📈 Future Enhancements

### Planned Features
- [ ] Biometric authentication
- [ ] Cloud backup (encrypted)
- [ ] File sharing (encrypted)
- [ ] Multiple vaults
- [ ] Password manager integration
- [ ] Blockchain anchoring (optional)

### Security Enhancements
- [ ] Hardware security module (HSM)
- [ ] Secure enclave integration
- [ ] Anti-debugging measures
- [ ] Certificate pinning
- [ ] Obfuscation

## 🔧 Maintenance

### Regular Tasks
- Update dependencies
- Security audits
- Performance profiling
- User feedback integration

### Monitoring
- Crash reports
- Performance metrics
- Security incidents
- User analytics (privacy-preserving)

---

**This architecture implements defense-in-depth security with multiple layers of protection, ensuring your personal information remains secure.**
