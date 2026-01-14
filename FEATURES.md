# Moustra Mobile App - Feature List

## Authentication & Account
- Social Login (Google, Microsoft via Auth0)
- Email/Password Login
- Biometric Authentication (Face ID/Fingerprint)
- Token Management & Auto-refresh
- Session Management
- Logout

## User Management
- List Users
- Get User Details
- Create User
- Update User
- User Roles (Admin, User)
- User Positions (Principal Investigator, Professor, Lab Manager, Scientist, Technician, Student, Other)

## Rack Management
- Get Rack
- Create Rack
- Update Rack
- Move Cage (reorder in rack)
- Move Animals between cages
- Save/Load Transformation Matrix (3D positioning)

## Cage Management
- List Cages (paginated)
- Get Cage by UUID
- Get Cage by Barcode
- Create Cage
- Update Cage
- End Cage (soft delete)
- Move Cage
- Create Cage in Rack
- AI Search for Cages
- Cages Grid View (interactive 2D/3D)
- Cages List View (tabular)
- Barcode Scanning

## Animal Management
- List Animals (paginated)
- Get Animal Details
- Create Animal (single or bulk)
- Update Animal
- End Animal (soft delete)
- Move Animal between cages
- AI Search for Animals
- Genotype Information Management
- Multi-parent Support (sire + multiple dams)

## Strain Management
- List Strains (paginated)
- Get Strain Details
- Create Strain
- Update Strain
- Delete Strain
- Merge Strains
- AI Search for Strains
- Color Coding
- Background Genetics

## Gene Management
- List Genes
- Create Gene
- Delete Gene

## Allele Management
- List Alleles
- Create Allele
- Delete Allele

## Mating Management
- List Matings (paginated)
- Get Mating Details
- Create Mating
- Update Mating

## Litter Management
- List Litters (paginated)
- Get Litter Details
- Create Litter
- Update Litter

## Notes/Annotations
- Create Note (on any entity)
- Update Note
- Delete Note
- Supported on: Animal, Cage, Mating, Litter, Strain, User

## Dashboard & Analytics
- Mice Count by Age
- Animals to Wean
- Data by Account
- Sex Ratio Display

## Settings
- Lab Settings (name, rack dimensions, wean date, EID toggle)
- Account Settings
- Default Owner Selection

## Subscription Management
- Create Payment Intent
- Create Subscription
- Confirm Subscription
- Get Subscription Details
- Cancel Subscription

## Profile & Account
- View User Profile
- List Accessible Accounts
- Select Default Account

## Search & Filtering
- AI-Powered Search (Cage, Animal, Strain)
- Advanced Filtering (contains, equals, range)
- Sorting
- Pagination

## Barcode Scanning
- QR Code Support
- Code128, Code39, EAN13, EAN8, UPC-A, UPC-E
- Camera-based Scanning
- Manual Entry Fallback

---

## CRUD Summary

| Entity | Create | Read | Update | Delete |
|--------|--------|------|--------|--------|
| Animal | Yes | Yes | Yes | End |
| Cage | Yes | Yes | Yes | End |
| Strain | Yes | Yes | Yes | Yes |
| Mating | Yes | Yes | Yes | No |
| Litter | Yes | Yes | Yes | No |
| User | Yes | Yes | Yes | No |
| Gene | Yes | Yes | No | Yes |
| Allele | Yes | Yes | No | Yes |
| Note | Yes | No | Yes | Yes |
| Rack | Yes | Yes | Yes | No |
| Settings | No | Yes | Yes | No |
| Subscription | Yes | Yes | No | Yes |
