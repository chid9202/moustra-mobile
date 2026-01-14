# Moustra Features Inventory

This document lists all features implemented in the Moustra backend for comparison with the mobile application.

---

## 1. Animal Management

### Create
- [ ] Create single animal
- [ ] Create multiple animals (bulk)
- [ ] Create animal with default wean date
- [ ] CSV import animals

### Read
- [ ] List all animals (with filters/pagination)
- [ ] Get animal by UUID
- [ ] AI-powered animal search
- [ ] Get animal attachments
- [ ] Get attachment download link
- [ ] Get animals for ending (with end types/reasons)
- [ ] Get animal family tree (parent/child litters)
- [ ] Get animal mating history

### Update
- [ ] Update animal properties
- [ ] End animal(s) with date/type/reason/comment
- [ ] Bulk update multiple animals

### Delete
- [ ] Delete single animal
- [ ] Delete multiple animals

### Special Operations
- [ ] Move animal to different cage
- [ ] Upload file attachment
- [ ] Delete attachment

---

## 2. Cage Management

### Create
- [ ] Create new cage
- [ ] Create cage with default configuration

### Read
- [ ] List all cages (with filters/pagination)
- [ ] Get cage by UUID
- [ ] Get simplified cage list (tag, ID, UUID only)
- [ ] AI-powered cage search
- [ ] Cage barcode lookup

### Update
- [ ] Update cage properties
- [ ] Reorder cage position within rack
- [ ] Reset cage ordering to default

### Delete
- [ ] Delete empty cage

### Special Operations
- [ ] End/archive cage (with cascade option)

---

## 3. Rack Management

### Create
- [ ] Create new rack (with name, width, height)

### Read
- [ ] Get rack by UUID (with all cages)
- [ ] Get default rack for lab

### Update
- [ ] Update rack properties (name, dimensions)

### Delete
- [ ] (Not implemented)

---

## 4. Strain Management

### Create
- [ ] Create new strain
- [ ] Create strain with default name

### Read
- [ ] List all strains (with pagination/filters)
- [ ] Get strain by UUID
- [ ] AI-powered strain search

### Update
- [ ] Update strain properties

### Delete
- [ ] Delete strain

### Special Operations
- [ ] Merge multiple strains into one

---

## 5. Mating Management

### Create
- [ ] Create new mating
- [ ] Create mating with cage assignment

### Read
- [ ] Get mating by UUID
- [ ] List all matings (with pagination/filters)

### Update
- [ ] Update mating properties

### Delete
- [ ] (Not implemented)

---

## 6. Litter Management

### Create
- [ ] Create new litter
- [ ] Create animals from litter

### Read
- [ ] Get litter by UUID
- [ ] List litters (with pagination/filters)

### Update
- [ ] Update litter properties
- [ ] End litter(s) with end date

### Delete
- [ ] (Not implemented)

---

## 7. Genetics Management

### Gene
- [ ] Get all genes for lab
- [ ] Create new gene
- [ ] Delete gene

### Allele
- [ ] Create new allele
- [ ] Delete allele

---

## 8. Background/Genetic Background

### Create
- [ ] Create new genetic background

### Read
- [ ] List all genetic backgrounds

---

## 9. End Type/Reason Management

### End Types
- [ ] Create custom end type

### End Reasons
- [ ] Create custom end reason

---

## 10. Notes/Comments System

### Animal Notes
- [ ] Add note to animal
- [ ] Update animal note
- [ ] Delete animal note

### Cage Notes
- [ ] Add note to cage
- [ ] Update cage note
- [ ] Delete cage note

### Mating Notes
- [ ] Add note to mating
- [ ] Update mating note
- [ ] Delete mating note

### Litter Notes
- [ ] Add note to litter
- [ ] Update litter note
- [ ] Delete litter note

---

## 11. User/Account Management

### Account Operations
- [ ] List all lab users
- [ ] Get specific user details
- [ ] Create/invite new lab user
- [ ] Update user details (role, position)
- [ ] Deactivate user
- [ ] Reactivate user
- [ ] Send invitation/re-invite

### Account Settings
- [ ] Update user preferences (daily reports, tours, notifications)

---

## 12. Lab Settings

### Lab Configuration
- [ ] Get lab information
- [ ] Get lab settings
- [ ] Update lab settings
- [ ] Update lab name and plan

### Settings Include
- [ ] Default rack width/height
- [ ] Default wean date (days)
- [ ] EID (Electronic ID) usage
- [ ] Item update notifications
- [ ] Owner assignment

---

## 13. Authentication & Authorization

### User Authentication
- [ ] Email/password login
- [ ] User registration
- [ ] Auth0 callback handling
- [ ] Session logout

### Password Management
- [ ] Initiate password reset
- [ ] Complete password reset with token
- [ ] Resend verification email

### Account Invites
- [ ] Validate invite token
- [ ] Accept lab user invite
- [ ] Resend invite email

---

## 14. Subscription & Billing

### Subscription Management
- [ ] Get current subscription status
- [ ] Cancel subscription

### Payment Processing
- [ ] Create Stripe checkout session
- [ ] Get checkout session details

---

## 15. Data Migration & Import

### File Upload & Analysis
- [ ] Upload CSV file with data type
- [ ] Analyze CSV structure and content
- [ ] Upload CSV for AI-powered processing

### CSV Processing
- [ ] Submit CSV with column mapping
- [ ] List migration history
- [ ] Get most recent migration

### Supported Data Types
- [ ] Animals CSV import
- [ ] Cages CSV import
- [ ] Matings CSV import
- [ ] Litters CSV import

---

## 16. Dashboard & Analytics

### Dashboard Data
- [ ] Get comprehensive dashboard metrics
- [ ] Animals by age (per strain)
- [ ] Sex ratio statistics
- [ ] Cage utilization metrics
- [ ] Animals scheduled for weaning
- [ ] AI-generated suggestions
- [ ] Per-user counts (animals/cages/matings/litters)

### Cage Utilization
- [ ] Utilization percentage per cage
- [ ] At-risk cages (above threshold)
- [ ] Cages in violation (over capacity)

---

## 17. AI Features

### Search Capabilities
- [ ] Natural language animal search
- [ ] Natural language cage search
- [ ] Natural language strain search

### Gel Image Analysis
- [ ] Analyze gel image for genotype results
- [ ] Retrieve analysis results
- [ ] Auto-detect animal/gene/allele

### AI Suggestions
- [ ] Update suggestion status (created/completed/rejected/ignored)
- [ ] AI-generated breeding suggestions
- [ ] Onboarding suggestions

### AI Chat
- [ ] Retrieve chat conversation history

### AI Settings
- [ ] Get AI availability and sync status

---

## 18. Table Settings & User Preferences

### Column Configuration
- [ ] Get saved table configuration
- [ ] Save table filters/sorts/column visibility
- [ ] Reset to default configuration

### Supported Tables
- [ ] Animal list settings
- [ ] Cage list settings
- [ ] Strain list settings
- [ ] Mating list settings
- [ ] Litter list settings
- [ ] User list settings

---

## 19. Event Tracking

- [ ] Send analytics event

---

## 20. Error Reporting & Feedback

- [ ] Submit bug report
- [ ] Submit user feedback

---

## 21. Store Data (Pre-loaded Cache)

- [ ] Get cached strains
- [ ] Get cached genes
- [ ] Get cached alleles
- [ ] Get cached end types
- [ ] Get cached end reasons
- [ ] Get cached accounts
- [ ] Get cached racks
- [ ] Get cached cages
- [ ] Get cached animals

---

## 22. Transnetyx Integration

### Orders
- [ ] Get comprehensive Transnetyx data
- [ ] List all Transnetyx orders
- [ ] Create new genotyping order
- [ ] Get specific order details
- [ ] Update order
- [ ] Cancel order
- [ ] Sync results back to Moustra

### Tests & Pricing
- [ ] Get available genotyping tests
- [ ] Get test pricing

### Results
- [ ] Retrieve genotyping results

---

## 23. File Attachments

### Animal Attachments
- [ ] Upload file to animal
- [ ] List files for animal
- [ ] Get download URL
- [ ] Remove attachment

---

## Summary Table

| Entity | Create | Read | Update | Delete | Special |
|--------|--------|------|--------|--------|---------|
| Animal | 3 | 7 | 3 | 2 | Move, End, Attachments |
| Cage | 2 | 5 | 3 | 1 | End, Order |
| Rack | 1 | 2 | 1 | 0 | - |
| Strain | 2 | 3 | 1 | 1 | Merge |
| Mating | 1 | 2 | 1 | 0 | - |
| Litter | 1 | 2 | 2 | 0 | - |
| Gene | 1 | 1 | 0 | 1 | - |
| Allele | 1 | 0 | 0 | 1 | - |
| Notes | 4 types | - | 4 types | 4 types | Entity-scoped |
| User/Account | 3 | 2 | 1 | 1 | Invite, Activate |
| Lab | 0 | 2 | 2 | 0 | - |
| Subscription | 1 | 1 | 0 | 1 | Checkout |
| Data Migration | 1 | 4 | 1 | 0 | AI Upload |
| Dashboard | 0 | 1 | 0 | 0 | - |

---

## Usage Instructions

1. Check off features that exist in the mobile app
2. Unchecked items represent missing features to implement
3. Use this as a comparison checklist between backend and mobile app

