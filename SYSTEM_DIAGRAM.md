# 🛡️ Secure PII Wallet - System Diagrams

## 📊 Complete System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      USER INTERFACE                          │
│  Splash │ Unlock │ Dashboard │ Upload │ Viewer              │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    NAVIGATION LAYER                          │
│              go_router + Session Guards                      │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                 STATE MANAGEMENT (Riverpod)                  │
│  Session │ Files │ Security │ Crypto │ Storage │ Keys       │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   CONTROLLER LAYER                           │
│         FileController (Orchestration)                       │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  SECURITY ENGINE                             │
│  Policy │ Validation │ Access Control │ Integrity           │
└─────┬──────────────┬──────────────┬──────────────┬─────────┘
      │              │              │              │
┌─────▼─────┐  ┌────▼────┐  ┌──────▼──────┐  ┌───▼────┐
│  CRYPTO   │  │ STORAGE │  │ KEY MGMT    │  │ MODELS │
│ AES-256   │  │ Files + │  │ SSS-style   │  │ Data   │
│ SHA-256   │  │ Metadata│  │ 3-key       │  │ Types  │
└───────────┘  └─────────┘  └─────────────┘  └────────┘
```

## 🔄 Upload Workflow Diagram

```
┌──────────┐
│  USER    │
│ Selects  │
│  File    │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│  Upload Screen  │
│  - Choose Mode  │
│  - Password     │
│  - Keys (HIGH)  │
└────┬────────────┘
     │
     ▼
┌──────────────────┐
│ FileController   │
│   .upload()      │
└────┬─────────────┘
     │
     ▼
┌──────────────────────┐
│  Security Engine     │
│  - Validate Password │
│  - Validate Keys     │
└────┬─────────────────┘
     │
     ▼
┌──────────────────┐
│  Crypto Service  │
│  - Derive Key    │
│  - Generate IV   │
│  - Encrypt AES   │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Storage Service  │
│ - Save Cipher    │
│ - Save IV        │
│ - Save Metadata  │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Key Service     │
│ - Hash Keys      │
│ - Store Hashes   │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  State Update    │
│ - Add to List    │
│ - Show Success   │
└──────────────────┘
```

## 🔓 Access Workflow Diagram

```
┌──────────┐
│  USER    │
│  Taps    │
│  File    │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│  Unlock Dialog  │
│  - Password     │
│  - Keys (HIGH)  │
└────┬────────────┘
     │
     ▼
┌──────────────────┐
│ FileController   │
│   .access()      │
└────┬─────────────┘
     │
     ▼
┌──────────────────────┐
│  Security Engine     │
│  - Verify Password   │
│  - Verify Keys       │
└────┬─────────────────┘
     │
     ▼
┌──────────────────┐
│ Storage Service  │
│ - Read Cipher    │
│ - Read IV        │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Crypto Service  │
│  - Derive Key    │
│  - Decrypt AES   │
└────┬─────────────┘
     │
     ▼
┌──────────────────────┐
│  Security Engine     │
│  - Verify Integrity  │
│  - Check Hash        │
└────┬─────────────────┘
     │
     ▼
┌──────────────────┐
│  File Viewer     │
│  - PDF/Image     │
│  - Memory Only   │
└──────────────────┘
```

## 🗑️ Delete Workflow Diagram

```
┌──────────┐
│  USER    │
│  Taps    │
│  Delete  │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│  Confirmation   │
│    Dialog       │
└────┬────────────┘
     │
     ▼
┌──────────────────┐
│ FileController   │
│   .delete()      │
└────┬─────────────┘
     │
     ▼
┌──────────────────────┐
│  Security Engine     │
│  .secureDelete()     │
└────┬─────────────────┘
     │
     ├─────────────────┐
     │                 │
     ▼                 ▼
┌──────────────┐  ┌──────────────┐
│   Storage    │  │ Key Service  │
│ - Delete     │  │ - Delete     │
│   Cipher     │  │   Keys       │
│ - Delete IV  │  │              │
│ - Delete     │  │              │
│   Metadata   │  │              │
└──────┬───────┘  └──────┬───────┘
       │                 │
       └────────┬────────┘
                │
                ▼
         ┌──────────────┐
         │ State Update │
         │ - Remove     │
         │   from List  │
         │ - Show       │
         │   Success    │
         └──────────────┘
```

## 🔐 Security Decision Tree

```
                    START
                      │
                      ▼
              ┌───────────────┐
              │   Password    │
              │  Validation   │
              └───┬───────┬───┘
                  │       │
              FAIL│       │PASS
                  │       │
                  ▼       ▼
              ┌─────┐  ┌──────────┐
              │DENY │  │Mode Check│
              └─────┘  └─┬────┬───┘
                         │    │
                    NORMAL│  │HIGH
                         │    │
                         │    ▼
                         │  ┌──────────┐
                         │  │   Key    │
                         │  │Validation│
                         │  └─┬────┬───┘
                         │    │    │
                         │FAIL│    │PASS
                         │    │    │
                         │    ▼    │
                         │  ┌─────┐│
                         │  │DENY ││
                         │  └─────┘│
                         │         │
                         └────┬────┘
                              │
                              ▼
                        ┌──────────┐
                        │ Decrypt  │
                        └────┬─────┘
                             │
                             ▼
                      ┌─────────────┐
                      │  Integrity  │
                      │    Check    │
                      └──┬──────┬───┘
                         │      │
                     FAIL│      │PASS
                         │      │
                         ▼      ▼
                    ┌────────┐ ┌────────┐
                    │TAMPER! │ │ ALLOW  │
                    └────────┘ └────────┘
```

## 💾 Storage Structure

```
Application Directory
│
├── app_data/
│   │
│   ├── encrypted/
│   │   ├── <uuid1>.bin    ← Encrypted file
│   │   ├── <uuid1>.iv     ← Initialization vector
│   │   ├── <uuid2>.bin
│   │   ├── <uuid2>.iv
│   │   └── ...
│   │
│   └── metadata.json      ← File metadata
│       [
│         {
│           "id": "uuid1",
│           "name": "aadhaar.pdf",
│           "mode": "HIGH",
│           "hash": "sha256...",
│           "pwdHash": "sha256...",
│           "createdAt": "2024-..."
│         },
│         ...
│       ]
│
└── Secure Storage (OS-level)
    ├── keys_uuid1         ← Key hashes (HIGH mode)
    │   {
    │     "fileId": "uuid1",
    │     "keyHashes": ["hash1", "hash2", "hash3"]
    │   }
    └── ...
```

## 🔒 Encryption Flow

```
┌──────────────┐
│   Password   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   SHA-256    │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│  Key (32B)   │ +   │  IV (16B)    │
└──────┬───────┘     └──────┬───────┘
       │                    │
       └──────────┬─────────┘
                  │
                  ▼
           ┌──────────────┐
           │  AES-256-CBC │
           └──────┬───────┘
                  │
                  ▼
           ┌──────────────┐
           │   Encrypted  │
           │     File     │
           └──────────────┘
```

## 🔑 Key System (High Security)

```
┌─────────────────────────────────────┐
│         User Provides/Generates      │
│                                      │
│  Key 1: X7A2M9P4  (8 chars)        │
│  Key 2: L3Q8N5R1  (8 chars)        │
│  Key 3: K9W2T6Y7  (8 chars)        │
└──────────────┬──────────────────────┘
               │
               ▼
        ┌──────────────┐
        │   SHA-256    │
        │   Each Key   │
        └──────┬───────┘
               │
               ▼
┌──────────────────────────────────────┐
│      Stored in Secure Storage        │
│                                       │
│  Hash 1: sha256(Key1)                │
│  Hash 2: sha256(Key2)                │
│  Hash 3: sha256(Key3)                │
└───────────────────────────────────────┘

Access Requires:
  ✓ All 3 keys correct
  ✓ In correct order
  ✓ Exact match (case-sensitive)
```

## 🛡️ Defense Layers

```
┌─────────────────────────────────────────┐
│         Layer 1: UI Security            │
│  - Obscured password input              │
│  - No plaintext display                 │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Layer 2: Session Control           │
│  - Auto-lock                            │
│  - Rate limiting                        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    Layer 3: Password Validation         │
│  - Strength requirements                │
│  - Hash comparison                      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Layer 4: Key Verification          │
│  - Format validation                    │
│  - Hash comparison                      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       Layer 5: Encryption               │
│  - AES-256-CBC                          │
│  - Random IV per file                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    Layer 6: Integrity Check             │
│  - SHA-256 verification                 │
│  - Tamper detection                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Layer 7: Secure Storage            │
│  - OS-level encryption                  │
│  - Isolated storage                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     Layer 8: Memory Safety              │
│  - In-memory decryption only            │
│  - Buffer cleanup                       │
└─────────────────────────────────────────┘
```

## 📱 User Journey Map

```
App Launch
    │
    ▼
┌─────────┐
│ Splash  │ (2 seconds)
└────┬────┘
     │
     ▼
┌─────────┐
│ Unlock  │ ← Tap "UNLOCK"
└────┬────┘
     │
     ▼
┌──────────────┐
│  Dashboard   │ ← View files
│              │
│  ┌────────┐  │
│  │ File 1 │  │ ← Tap to view
│  └────────┘  │
│  ┌────────┐  │
│  │ File 2 │  │
│  └────────┘  │
│              │
│  [+ UPLOAD]  │ ← Tap to upload
└──────┬───────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌──────────┐      ┌──────────┐
│  Upload  │      │  Viewer  │
│  Screen  │      │  Screen  │
│          │      │          │
│ Select   │      │ PDF/     │
│ Mode     │      │ Image    │
│ Password │      │ Display  │
│ Keys     │      │          │
│          │      │          │
│ [UPLOAD] │      │ [BACK]   │
└──────────┘      └──────────┘
```

---

**These diagrams illustrate the complete system architecture, workflows, and security layers of your Secure PII Wallet.**
