# Missing Features in Mobile App

Features present in the Web app but missing from the Flutter mobile app.

---

## 1. Animal Management

- [ ] CSV import animals
- [x] Get animal attachments
- [x] Get attachment download link
- [ ] Get animals for ending (with end types/reasons)
- [ ] Get animal family tree (parent/child litters)
- [ ] Get animal mating history
- [ ] Bulk update multiple animals
- [ ] Delete single animal (hard delete)
- [ ] Delete multiple animals (hard delete)
- [x] Upload file attachment
- [x] Delete attachment

---

## 2. Cage Management

- [ ] Get simplified cage list (tag, ID, UUID only)
- [ ] Reset cage ordering to default
- [ ] Delete empty cage (hard delete)

---

## 3. Litter Management

- [ ] Create animals from litter
- [ ] End litter(s) with end date

---

## 4. End Type/Reason Management

- [ ] Create custom end type
- [ ] Create custom end reason

---

## 5. User/Account Management

- [ ] Deactivate user
- [ ] Reactivate user
- [ ] Send invitation/re-invite
- [ ] Update user preferences (daily reports, tours, notifications)

---

## 6. Authentication

- [ ] User registration
- [ ] Initiate password reset
- [ ] Complete password reset with token
- [ ] Resend verification email
- [ ] Validate invite token
- [ ] Accept lab user invite
- [ ] Resend invite email

---

## 7. Subscription & Billing

- [ ] Create Stripe checkout session
- [ ] Get checkout session details

---

## 8. Data Migration & Import (Entire Section)

- [ ] Upload CSV file with data type
- [ ] Analyze CSV structure and content
- [ ] Upload CSV for AI-powered processing
- [ ] Submit CSV with column mapping
- [ ] List migration history
- [ ] Get most recent migration
- [ ] Animals CSV import
- [ ] Cages CSV import
- [ ] Matings CSV import
- [ ] Litters CSV import

---

## 9. Dashboard & Analytics

- [ ] Cage utilization metrics
- [ ] AI-generated suggestions
- [ ] Utilization percentage per cage
- [ ] At-risk cages (above threshold)
- [ ] Cages in violation (over capacity)

---

## 10. AI Features

- [ ] Gel image analysis for genotype results
- [ ] Retrieve gel analysis results
- [ ] Auto-detect animal/gene/allele from gel
- [ ] Update suggestion status (created/completed/rejected/ignored)
- [ ] AI-generated breeding suggestions
- [ ] Onboarding suggestions
- [ ] AI Chat conversation history
- [ ] Get AI availability and sync status

---

## 11. Table Settings & User Preferences

- [ ] Get saved table configuration
- [ ] Save table filters/sorts/column visibility
- [ ] Reset to default configuration
- [ ] Animal list settings
- [ ] Cage list settings
- [ ] Strain list settings
- [ ] Mating list settings
- [ ] Litter list settings
- [ ] User list settings

---

## 12. Event Tracking

- [ ] Send analytics event

---

## 13. Error Reporting & Feedback

- [ ] Submit bug report
- [ ] Submit user feedback

---

## 14. Transnetyx Integration (Entire Section)

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

## 15. File Attachments

- [ ] Upload file to animal
- [ ] List files for animal
- [x] Get download URL
- [x] Remove attachment

---

## Summary

| Category          | Missing Features |
| ----------------- | ---------------- |
| Animal Management | 11               |
| Cage Management   | 3                |
| Litter Management | 2                |
| End Type/Reason   | 2                |
| User/Account      | 4                |
| Authentication    | 7                |
| Subscription      | 2                |
| Data Migration    | 10               |
| Dashboard         | 5                |
| AI Features       | 8                |
| Table Settings    | 9                |
| Event Tracking    | 1                |
| Error Reporting   | 2                |
| Transnetyx        | 10               |
| File Attachments  | 4                |
| **Total**         | **80**           |

---

## Priority Suggestions

### High Priority (Core Functionality)

- File attachments for animals
- Animal family tree / mating history
- Create animals from litter
- End types/reasons
- User invite flow

### Medium Priority (User Experience)

- Table settings persistence
- Password reset flow
- CSV import
- Dashboard utilization metrics

### Low Priority (Advanced Features)

- Transnetyx integration
- AI gel analysis
- AI chat
- Event tracking
