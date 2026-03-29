# Mobile App — Inline Editing Manual Testing Plan

**App:** Moustra (iOS / Android)
**Feature:** Airtable-style inline cell editing in Strain list

---

## Prerequisites

- Backend running at `https://localhost:8000`
- At least 2-3 strains with different owners in the account
- At least 2 users in the account (for owner picker testing)

---

## 1. Strain List — Inline Editing

**Screen:** Strains tab (bottom nav or side drawer)

### 1.1 Text Editing (Strain Name)

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 1 | Tap editable cell enters edit mode | Tap a strain name cell | Text input appears with current name, keyboard opens, text fully selected | |
| 2 | Edit and commit via Done key | Type a new name → tap Done on keyboard | Name saved, success snackbar "Updated successfully", list reloads | |
| 3 | Edit and commit via tap outside | Type a new name → tap a different row | Name saved, success snackbar | |
| 4 | Cancel by clearing and tapping outside | Clear the name → tap outside | Error snackbar "Strain name is required", value reverts | |
| 5 | Validate empty name | Clear the name → tap Done | Error snackbar "Strain name is required" | |
| 6 | Validate max length (100 chars) | Paste 101+ characters → tap Done | Error snackbar "Strain name must be 100 characters or less" | |
| 7 | Persistence after reload | Edit a name → pull to refresh or navigate away and back | Edited name persists | |
| 8 | Edit border style | Tap a strain name cell | Input has blue 2px border, focused | |

### 1.2 Boolean Editing (Active Status)

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 9 | Tap active cell shows toggle | Tap the Active column cell | Switch widget appears inline | |
| 10 | Toggle active to inactive | Flip the switch from on to off | API called, strain deactivated, success snackbar | |
| 11 | Toggle inactive to active | Flip the switch from off to on | API called, strain activated, success snackbar | |
| 12 | Visual update | Toggle active status | Icon changes between green checkmark and red X after reload | |

### 1.3 Autocomplete Editing (Owner)

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 13 | Tap owner cell opens picker | Tap the Owner column cell | Bottom sheet slides up with search bar and user list | |
| 14 | Search filters users | Type part of a user name in the search bar | List filters to matching users | |
| 15 | Select a user | Tap a user in the list | Bottom sheet closes, owner updated, success snackbar | |
| 16 | Current owner shows checkmark | Open owner picker | Currently assigned owner has a checkmark icon | |
| 17 | Dismiss picker cancels | Swipe bottom sheet down or tap X | No changes, edit cancelled | |
| 18 | Empty search shows all | Clear the search field | All users shown | |

---

## 2. Non-Editable Cells — Navigation

**Screen:** Strains tab

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 19 | Tap non-editable cell navigates | Tap the Animals count cell | Navigates to strain detail page | |
| 20 | Tap color cell navigates | Tap the Color cell | Navigates to strain detail page | |
| 21 | Tap created date navigates | Tap the Created Date cell | Navigates to strain detail page | |

---

## 3. Linked Record Chips

**Screen:** Strains tab

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 22 | Strain name shows as chip | Look at the Name column | Names rendered as rounded chips with grey background | |
| 23 | Chip has blue text | Look at strain name chips | Text is blue (primary color), indicating tappable | |
| 24 | Tap chip navigates | Tap a strain name chip | Navigates to strain detail page (`/strain/{uuid}`) | |
| 25 | Chip visual style | Inspect chips | Grey background, 4px border radius, subtle border, compact padding | |

---

## 4. Edit Mode Visual Indicators

**Screen:** Strains tab

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 26 | Editing row highlighted | Tap any editable cell | The entire row has a subtle blue tint background | |
| 27 | Non-editing rows normal | While one row is in edit mode | Other rows have normal white background | |
| 28 | Edit exits cleanly | Commit or cancel an edit | Row highlight disappears, row returns to normal | |

---

## 5. Error Handling

**Screen:** Strains tab

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 29 | API error shows snackbar | Edit a strain while backend is stopped | Error snackbar shown with error message | |
| 30 | Validation prevents API call | Enter empty name → submit | Error snackbar shown, NO network request fired | |
| 31 | Recovery after error | After an error, edit successfully | Edit works, success snackbar shown | |

---

## 6. Interaction Edge Cases

**Screen:** Strains tab

| # | Test Case | Steps | Expected | Pass? |
|---|-----------|-------|----------|-------|
| 32 | Rapid double-tap on editable cell | Double-tap quickly on strain name | Edit mode entered once (no double-trigger) | |
| 33 | Edit during loading | Start editing while list is loading/refreshing | Edit cancelled or prevented during load | |
| 34 | Checkbox still works | Tap the select checkbox while another cell is in edit mode | Checkbox toggles, edit committed | |
| 35 | Sort during edit | Tap a sort header while editing | Edit committed, sort applied | |
| 36 | Filter during edit | Apply a filter while editing | Edit committed, filter applied | |
| 37 | Pagination during edit | Navigate to next page while editing | Edit committed, page changes | |
| 38 | Scroll while editing | Scroll the grid while a cell is in edit mode | Edit widget stays with its cell or commits on scroll | |

---

## 7. Device-Specific

| # | Test Case | Device | Steps | Expected | Pass? |
|---|-----------|--------|-------|----------|-------|
| 39 | iPhone SE (small screen) | iOS Simulator | Edit strain name on small screen | Keyboard doesn't cover the edit cell, or view scrolls to show it | |
| 40 | iPad (large screen) | iOS Simulator | Edit all 3 column types | All work correctly on larger layout | |
| 41 | Android phone | Android Emulator | Edit strain name + owner + active | All 3 edit types work | |
| 42 | Dark mode | iOS/Android | Toggle dark mode → edit cells | Edit widgets respect dark theme colors | |
| 43 | Landscape orientation | Any device | Rotate to landscape → edit a cell | Edit widget displays correctly | |

---

## Summary

| Section | Test Cases | Critical? |
|---------|-----------|-----------|
| 1.1 Text editing | 1-8 | Yes |
| 1.2 Boolean editing | 9-12 | Yes |
| 1.3 Owner picker | 13-18 | Yes |
| 2. Navigation | 19-21 | Yes |
| 3. Chips | 22-25 | Medium |
| 4. Visual indicators | 26-28 | Low |
| 5. Error handling | 29-31 | Yes |
| 6. Edge cases | 32-38 | Medium |
| 7. Device-specific | 39-43 | Medium |

**Total: 43 test cases**
