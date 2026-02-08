# Feature Parity - Mobile vs Web

This document compares features between the Moustra mobile (Flutter) and web applications, identifying what's shared, what's platform-specific, and notable behavioral differences.

---

## Quick Summary

| Category | Mobile | Web | Parity |
|----------|--------|-----|--------|
| Core CRUD (Animals, Cages, etc.) | ✅ | ✅ | Full |
| Authentication | ✅ | ✅ | Full |
| Barcode Scanning | ✅ | ❌ | Mobile-only |
| Data Migration/CSV Import | ❌ | ✅ | Web-only |
| AI Features | Partial | ✅ | Limited mobile |
| Table Customization | ❌ | ✅ | Web-only |
| Invitation System | ❌ | ✅ | Web-only |
| Biometric Auth | ✅ | ❌ | Mobile-only |
| File Attachments | ✅ | ✅ | Full |

---

## Detailed Comparison

### 1. Animal Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List animals (paginated) | ✅ | ✅ | |
| Get animal details | ✅ | ✅ | |
| Create animal (single) | ✅ | ✅ | |
| Create animals (bulk) | ✅ | ✅ | |
| Update animal | ✅ | ✅ | |
| End animal | ✅ | ✅ | |
| Move animal between cages | ✅ | ✅ | |
| AI-powered search | ✅ | ✅ | |
| Genotype management | ✅ | ✅ | |
| Multi-parent support | ✅ | ✅ | |
| Get animal attachments | ✅ | ✅ | |
| Upload file attachment | ✅ | ✅ | |
| Delete attachment | ✅ | ✅ | |
| Get attachment download link | ✅ | ✅ | |
| **Animal family tree** | ❌ | ✅ | Parent/child litter visualization |
| **Animal mating history** | ❌ | ✅ | Historical mating data |

### 2. Cage Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List cages (paginated) | ✅ | ✅ | |
| Get cage by UUID | ✅ | ✅ | |
| Get cage by barcode | ✅ | ✅ | |
| Create cage | ✅ | ✅ | |
| Update cage | ✅ | ✅ | |
| End cage | ✅ | ✅ | |
| Move cage in rack | ✅ | ✅ | |
| Create cage in rack | ✅ | ✅ | |
| AI-powered search | ✅ | ✅ | |
| Cages grid view (2D/3D) | ✅ | ✅ | Mobile has interactive gestures |
| Cages list view | ✅ | ✅ | |
| **Barcode scanning** | ✅ | ❌ | Camera-based scanning |

### 3. Rack Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| Get rack | ✅ | ✅ | |
| Create rack | ✅ | ✅ | |
| Update rack | ✅ | ✅ | |
| Multi-rack support | ✅ | ✅ | |
| Save transformation matrix | ✅ | ✅ | View position persistence |

### 4. Strain Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List strains | ✅ | ✅ | |
| Get strain details | ✅ | ✅ | |
| Create strain | ✅ | ✅ | |
| Update strain | ✅ | ✅ | |
| Delete strain | ✅ | ✅ | |
| Merge strains | ✅ | ✅ | |
| AI-powered search | ✅ | ✅ | |
| Color coding | ✅ | ✅ | |

### 5. Mating Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List matings | ✅ | ✅ | |
| Get mating details | ✅ | ✅ | |
| Create mating | ✅ | ✅ | |
| Update mating | ✅ | ✅ | |

### 6. Litter Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List litters | ✅ | ✅ | |
| Get litter details | ✅ | ✅ | |
| Create litter | ✅ | ✅ | |
| Update litter | ✅ | ✅ | |
| **Create animals from litter** | ❌ | ✅ | Wean flow |
| **End litter(s)** | ❌ | ✅ | Batch end with date |

### 7. Notes/Annotations

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| Create note | ✅ | ✅ | All entity types |
| Update note | ✅ | ✅ | |
| Delete note | ✅ | ✅ | |

### 8. Dashboard & Analytics

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| Mice count by age | ✅ | ✅ | |
| Animals to wean | ✅ | ✅ | |
| Data by account | ✅ | ✅ | |
| Sex ratio display | ✅ | ✅ | |
| **Cage utilization metrics** | ❌ | ✅ | Utilization %, at-risk cages |
| **AI-generated suggestions** | ❌ | ✅ | Breeding suggestions |

### 9. Settings

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| Lab settings (name, rack dims) | ✅ | ✅ | |
| Default wean date | ✅ | ✅ | |
| EID toggle | ✅ | ✅ | |
| Default owner selection | ✅ | ✅ | |

### 10. Authentication

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| Email/password login | ✅ | ✅ | |
| Social login (Google) | ✅ | ✅ | |
| Social login (Microsoft) | ✅ | ✅ | |
| User registration (signup) | ✅ | ✅ | |
| Logout | ✅ | ✅ | |
| Token refresh | ✅ | ✅ | |
| **Biometric authentication** | ✅ | ❌ | Face ID, Touch ID, fingerprint |
| **Password reset** | ❌ | ✅ | Initiate + complete reset |
| **Resend verification email** | ❌ | ✅ | |

### 11. User/Account Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List users | ✅ | ✅ | |
| Get user details | ✅ | ✅ | |
| Create user | ✅ | ✅ | |
| Update user | ✅ | ✅ | |
| User roles/positions | ✅ | ✅ | |
| **Deactivate user** | ❌ | ✅ | |
| **Reactivate user** | ❌ | ✅ | |
| **Send invitation** | ❌ | ✅ | Email invites |
| **Accept invitation (deep link)** | ❌ | ✅ | Lab user invite flow |
| **Update preferences** | ❌ | ✅ | Daily reports, tours, notifications |

### 12. Subscription & Billing

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| View subscription | ✅ | ✅ | |
| Create payment intent | ✅ | ✅ | |
| Create subscription | ✅ | ✅ | |
| Cancel subscription | ✅ | ✅ | |
| Stripe checkout session | ✅ | ✅ | Uses flutter_stripe |

### 13. Gene/Allele Management

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| List genes | ✅ | ✅ | |
| Create gene | ✅ | ✅ | |
| Delete gene | ✅ | ✅ | |
| List alleles | ✅ | ✅ | |
| Create allele | ✅ | ✅ | |
| Delete allele | ✅ | ✅ | |

### 14. Error Reporting & Feedback

| Feature | Mobile | Web | Notes |
|---------|--------|-----|-------|
| Submit bug report | ✅ | ✅ | |
| Submit user feedback | ✅ | ✅ | |
| Error context collection | ✅ | ✅ | Route, breadcrumbs, state |

---

## Web-Only Features

These features are implemented only in the web application:

### Data Migration & CSV Import
- Upload CSV files
- AI-powered CSV analysis
- Column mapping interface
- Migration history
- Supported types: Animals, Cages, Matings, Litters

### AI Features (Advanced)
- AI Chat conversation
- Gel image analysis for genotyping
- Auto-detect animal/gene/allele from gel
- AI breeding suggestions
- Onboarding suggestions
- Update suggestion status

### Table Settings & User Preferences
- Save column visibility per table
- Save filter configurations
- Save sort preferences
- Reset to default
- Per-table settings: Animals, Cages, Strains, Matings, Litters, Users

### User Management (Advanced)
- Send/resend invitations
- Accept lab user invites
- Deactivate/reactivate users
- Update user notification preferences

### Analytics (Advanced)
- Cage utilization metrics (%)
- At-risk cages (above threshold)
- Cages in violation (over capacity)

### Event Tracking
- Analytics event submission

### Transnetyx Integration
- Genotyping order management
- Test pricing
- Results sync

---

## Mobile-Only Features

These features are implemented only in the mobile application:

### Barcode Scanning
- Camera-based QR/barcode scanning
- Supported formats: QR, Code128, Code39, EAN13, EAN8, UPC-A, UPC-E
- Manual entry fallback
- Torch (flash) toggle

### Biometric Authentication
- Face ID (iOS)
- Touch ID (iOS)
- Fingerprint (Android)
- Secure token storage with biometric unlock

### Platform-Native UX
- Pull-to-refresh patterns
- Native keyboard handling
- SafeArea for notches/dynamic islands
- Native file picker for attachments

---

## Behavioral Differences

### 1. Authentication Flow

| Aspect | Mobile | Web |
|--------|--------|-----|
| Social login method | WebAuthentication (opens browser) | Redirect flow |
| Token storage | SecureStorage (encrypted) | Browser storage |
| Session persistence | Biometric unlock after close | Session cookies |
| Password grant | ROPG (direct) | Standard OAuth |

### 2. Data Loading

| Aspect | Mobile | Web |
|--------|--------|-----|
| Initial data | Pre-loads all stores on login | Lazy loads on navigation |
| Caching | In-memory ValueNotifier stores | Browser cache / state management |
| Offline capability | Cached data viewable | Standard web caching |

### 3. UI/UX

| Aspect | Mobile | Web |
|--------|--------|-----|
| Navigation | Drawer menu + back gestures | Sidebar navigation |
| Forms | Max width 400px | Full responsive width |
| Tables | Syncfusion DataGrid | Custom table component |
| Dialogs | Bottom sheets + AlertDialogs | Modal dialogs |

### 4. File Handling

| Aspect | Mobile | Web |
|--------|--------|-----|
| File picker | Native file picker | Browser file input |
| Image preview | Full-screen + pinch zoom | Lightbox |
| Camera access | Direct via mobile_scanner | MediaDevices API |

### 5. Cage Grid

| Aspect | Mobile | Web |
|--------|--------|-----|
| Gestures | Pinch-to-zoom, pan | Mouse scroll + drag |
| Touch handling | Multi-touch native | Mouse/trackpad |
| Matrix save | Per-rack, persistent | Per-rack, persistent |

---

## Implementation Priority

Features to prioritize for mobile parity:

### High Priority
1. **Create animals from litter** - Core wean workflow
2. **End litter(s)** - Common management task
3. **User invitation acceptance** - Onboarding blocker

### Medium Priority
4. **Cage utilization metrics** - Dashboard enhancement
5. **Password reset flow** - Self-service recovery
6. **Animal family tree** - Breeding research utility

### Lower Priority (Complex)
7. **CSV import/migration** - Complex UI, less mobile use case
8. **AI Chat** - Complex integration
9. **Table customization** - Lower value on mobile form factor

---

## API Coverage

### Mobile API Clients (`lib/services/clients/`)

| Client | Endpoints | Coverage |
|--------|-----------|----------|
| `animal_api.dart` | CRUD + search | Full |
| `attachment_api.dart` | Upload/download/delete | Full |
| `cage_api.dart` | CRUD + barcode + rack | Full |
| `dashboard_api.dart` | Dashboard data | Partial |
| `gene_api.dart` | CRUD | Full |
| `allele_api.dart` | CRUD | Full |
| `litter_api.dart` | CRUD | Partial (missing wean) |
| `mating_api.dart` | CRUD | Full |
| `note_api.dart` | CRUD | Full |
| `profile_api.dart` | Get profile | Full |
| `rack_api.dart` | CRUD + matrix | Full |
| `setting_api.dart` | Lab settings | Full |
| `store_api.dart` | Cached data fetch | Full |
| `strain_api.dart` | CRUD + merge | Full |
| `subscription_api.dart` | Stripe integration | Full |
| `users_api.dart` | User management | Partial |
| `lab_setting_api.dart` | Lab config | Full |

### Missing API Clients (Web-only)
- `migration_api` - CSV import
- `invite_api` - User invitations
- `ai_api` - Chat, gel analysis
- `table_settings_api` - Column preferences
- `analytics_api` - Event tracking
- `transnetyx_api` - Genotyping integration
