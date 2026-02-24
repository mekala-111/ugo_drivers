# UGO Driver App – Uber-Style First Release Specification

This document defines the target functionality for an Uber-like driver app **first release**, maps it to your existing UI, and lists **required APIs** to complete each feature.

---

## 1. Uber-Style Core Features (First Release)

| # | Feature | Description | Uber Equivalent |
|---|---------|-------------|-----------------|
| 1 | **Auth** | Phone OTP login, logout | Uber driver sign-in |
| 2 | **Registration/KYC** | Driver signup, documents, vehicle, city selection | Uber driver onboarding |
| 3 | **Go Online/Offline** | Toggle availability with one tap | Uber "Go Online" |
| 4 | **Ride Requests** | Real-time incoming ride cards with pickup/drop/fare | Uber ride ping |
| 5 | **Accept/Decline** | Accept or decline incoming ride | Uber accept/decline |
| 6 | **Navigate to Pickup** | Open Google Maps to passenger pickup | Uber navigation to rider |
| 7 | **Arrive & Start Ride** | Mark arrived, verify OTP, start trip | Uber "Start Trip" |
| 8 | **Navigate to Drop** | Open Maps to destination | Uber navigation to destination |
| 9 | **Complete Ride** | End trip, show fare, collect cash or confirm online | Uber "Complete Trip" |
| 10 | **Cancel Ride** | Cancel with reason (driver or passenger) | Uber cancel with reason |
| 11 | **Earnings Dashboard** | Today's earnings, ride count, wallet balance | Uber earnings summary |
| 12 | **Wallet & Withdraw** | View balance, add bank, withdraw to bank | Uber Instant Pay / Weekly |
| 13 | **Ride History** | Completed, cancelled, missed rides | Uber trip history |
| 14 | **Profile & Settings** | Edit profile, documents, preferred city | Uber account |
| 15 | **Support** | Contact, report issues, emergency SOS | Uber help & safety |
| 16 | **Rate Rider** | Rate passenger after ride | Uber rate rider |
| 17 | **Notifications** | Push + in-app notifications | Uber alerts |

---

## 2. Required APIs per Feature

### 2.1 Auth

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Driver Login | POST | `/api/drivers/login` | Body: `{mobile, otp}` or `{mobile_number, fcm_token}` | ✅ Exists |
| Logout | - | - | Client-side token clear (or backend revoke if available) | ⚠️ Optional |

**Your UI:** Login → OTP (Firebase) → LoginCall. **Backend must:** Accept `mobile`/`otp` for OTP flow.

---

### 2.2 Registration / KYC

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get Cities | GET | `/api/drivers/cities` | List cities for selection | ✅ Exists |
| Signup with Vehicle | POST | `/api/drivers/signup-with-vehicle` | Multipart: profile, license, aadhaar, pan, vehicle, RC, insurance, pollution | ✅ Exists |
| Submit KYC | POST | `/api/drivers/kyc/:id` | Update/submit KYC documents | ✅ Exists |
| Get Vehicle Types | GET | `/api/vehicle-types/getall-vehicle` | List vehicle types | ✅ Exists |
| Vehicle Makes | GET | `/api/vehicle-makes` | Brands (Toyota, Maruti, etc.) | ✅ Exists |
| Vehicle Models | GET | `/api/vehicle-models?make_id=X` | Models by make | ✅ Exists |

**Your UI:** Onboarding flow (firstdetails → choose vehicle → documents → preferred city). **Backend must:** Return clear `kyc_status` (pending, approved, rejected).

---

### 2.3 Go Online / Offline

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Set Preferred City | PATCH | `/api/drivers/preferred-city` | Body: `{cityId}` | ✅ Exists |
| Set Online Status | POST | `/api/drivers/online` | Body: `{isOnline: true/false}` | ✅ Exists |
| Update Driver (location) | PUT | `/api/drivers/:id` | Send `current_location_latitude`, `current_location_longitude`, `is_online`, `fcm_token` | ✅ Exists |

**Your UI:** HomeController `goOnline` / `goOffline`, online toggle. **Backend must:** Validate KYC and preferred city before allowing online.

---

### 2.4 Ride Requests (Real-Time)

| API / Event | Type | Purpose | Status in UGO |
|-------------|------|---------|---------------|
| **WebSocket** | Socket.IO | Events: `driver_rides`, `ride_updated`, `ride_taken`, `ride_assigned` | ✅ Used in HomeController |
| Get Ride by ID | GET | `/api/rides/:id` | Fallback when socket misses or app resumes | ✅ Exists |
| Get Ride Requests | GET | `/api/drivers/ride-requests/:id` | Poll fallback (driver id) | ✅ Exists |

**Your UI:** `RideRequestOverlay` receives socket data, shows `NewRequestCard`. **Backend must:**
- Emit `driver_rides` or equivalent with ride payload
- Include `pickup_city_id` for zone filtering
- Include `vehicle_type_id` for vehicle matching

---

### 2.5 Accept / Decline Ride

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Accept Ride | POST | `/api/drivers/accept-ride` | Body: `{ride_id, driver_id}` | ✅ Exists, ✅ Integrated |
| Reject Ride | POST | `/api/drivers/reject-ride` | Body: `{ride_id, driver_id, reason?}` | ✅ Exists, ✅ Integrated |

**Your UI:** Accept/Decline buttons on `NewRequestCard`. **Backend must:** Return success/failure, update ride status.

---

### 2.6 Navigate to Pickup / Drop

| API | Type | Purpose | Status in UGO |
|-----|------|---------|---------------|
| Google Maps / URL | External | `google.navigation:q=lat,lng` or `https://www.google.com/maps/...` | ✅ Used in `complete_ride_overlay.dart`, `openGoogleMapsNavigation` |

**Your UI:** "NAVIGATE" / "PICKUP" / "DROP" buttons open Maps. No backend API needed.

---

### 2.7 Update Ride Status (Arrived, Started, On Trip)

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Update Ride Status | POST | `/api/drivers/update-ride-status` | Body: `{ride_id, ride_status, driver_id}` | ✅ Exists, ✅ Integrated |
| Verify OTP | POST | `/api/rides/verify-otp` | Body: `{ride_id, otp}` | ✅ Exists, ✅ Integrated |

**Status flow:** `ACCEPTED` → `ARRIVED` → (verify OTP) → `STARTED` → `ONTRIP` → `COMPLETED`

**Your UI:** `StartRideCard`, `ActiveRideCard`, `OtpScreen`. **Backend must:** Validate OTP before allowing `STARTED`.

---

### 2.8 Complete Ride

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Complete Ride | POST | `/api/drivers/complete-ride` | Body: `{ride_id, driver_id, user_id}` | ✅ Exists, ✅ Integrated |

**Your UI:** `CompleteRideOverlay`, swipe to complete. **Backend must:** Return `final_fare`, `payment_mode`.

---

### 2.9 Cancel Ride

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Cancel Ride | PATCH | `/api/rides/rides/cancel` | Body: `{ride_id, cancellation_reason, cancelled_by}` | ✅ Exists, ✅ Integrated |

**Your UI:** `CancelRideSheet` with reason picker.

---

### 2.10 Earnings & Wallet

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get Earnings | GET | `/api/drivers/earnings/driver/:id?period=daily` | Today/total earnings | ✅ Exists |
| Get Wallet | GET | `/api/drivers/wallet/:id` | Balance | ✅ Exists, ✅ Integrated |
| Withdraw | POST | `/api/drivers/withdraws` | Body: `{driver_id, amount, fund_account_id?}` | ✅ Exists, ✅ Integrated |
| Add Bank Account | POST | `/api/drivers/bank-account` | Body: `{driver_id, bank_account_number, bank_ifsc_code, bank_holder_name}` | ✅ Exists, ✅ Integrated |
| Get Bank Account | GET | `/api/drivers/bank-account/:id` | Fetch linked account | ✅ Exists |

**Your UI:** `team_earnings_widget`, `wallet_widget`, `withdraw_widget`, `add_bank_account_widget`.

---

### 2.11 Ride History

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get Ride History | GET | `/api/drivers/ride-history/:id` | Completed, cancelled, missed | ✅ Exists |

**Your UI:** `history_widget`, `all_orders_widget`, `last_order_widget`.

---

### 2.12 Profile & Settings

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get Driver | GET | `/api/drivers/:id` | Profile, KYC status, referral code | ✅ Exists |
| Update Driver | PUT | `/api/drivers/:id` | Profile, documents, vehicle (multipart) | ✅ Exists |
| Update Profile Image | - | - | Via Update Driver multipart | ✅ |

**Your UI:** `account_support_widget`, `edit_profile`, `documents`, `preferred_city_widget`.

---

### 2.13 Support & Safety

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Report Issue | POST | `/api/drivers/report-issue` | Body: `{issue_type, description?, ride_id?}` | ✅ Exists, ✅ Integrated |
| Emergency SOS | POST | `/api/drivers/emergency-sos` | Body: `{ride_id?, lat?, lng?}` | ✅ Exists, ✅ Integrated (SOS button during active ride) |
| Submit Support Ticket | POST | `/api/support/SubmitTicket` | Support ticket | ✅ Exists |
| Emergency Contacts | GET/POST | `/api/drivers/:id/emergency-contacts` or `/api/safety/...` | Driver-specific contacts | ⚠️ Custom path in app |

**Your UI:** `report_issues_widget`, `support_widget`, `emergencycontactscreen`, `trustedcontacts`.

---

### 2.14 Rate Rider

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Rate Ride | POST | `/api/drivers/rate-ride` | Body: `{ride_id, rating, comment?}` | ✅ Exists |

**Your UI:** `review_screen` – ✅ **Integrated.** Calls `RateRideCall` with rating and tags before completing.

---

### 2.15 Notifications

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get Notifications | GET | `/api/notifications/getall` | In-app notification list | ✅ Exists |
| FCM | Push | Backend sends FCM to driver for rides, alerts | ✅ Via `RideNotificationService` |

**Your UI:** `inbox_page_widget`.

---

### 2.16 Location (Driver Live Location)

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Update Location | PATCH | `/api/location/update-location` | Body: `{latitude, longitude}` | ✅ In Postman |
| OR via Update Driver | PUT | `/api/drivers/:id` | Send lat/lng in params | ✅ Used in app |

**Your UI:** HomeController sends location when online. **Backend must:** Store driver location for matching.

---

### 2.17 Referrals (Optional for First Release)

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get My Referrals | GET | `/api/drivers/my-referrals` | Referral stats | ✅ Exists |
| Get Referrals | GET | `/api/drivers/referrals` | List | ✅ Exists |
| Link Referral | POST | `/api/drivers/referrals/link` | Link referred driver | ⚠️ Custom; verify backend |

---

### 2.18 Incentives (Optional for First Release)

| API | Method | Path | Purpose | Status in UGO |
|-----|--------|------|---------|---------------|
| Get Incentives | GET | `/api/driver-incentives/get-incentives/:id` | Incentive tiers | ✅ Exists |
| Daily Incentives | GET | `/api/driver-incentives/daily-incentives/:id?date=&type=` | Daily targets | ✅ Exists |

---

## 3. APIs to Verify / Implement on Backend

These are critical for a smooth Uber-like flow. Ensure your backend supports them with the expected request/response format.

| Priority | API | Notes |
|----------|-----|-------|
| **P0** | Socket `driver_rides` / `ride_updated` | Must emit ride objects with `pickup_city_id`, `vehicle_type_id`, addresses, coordinates |
| **P0** | `POST /api/drivers/accept-ride` | Must return updated ride; backend should assign driver and stop broadcasting to others |
| **P0** | `POST /api/drivers/update-ride-status` | Must support: `ARRIVED`, `STARTED`, `ONTRIP`, `COMPLETED` |
| **P0** | `POST /api/rides/verify-otp` | Must validate OTP and allow status → `STARTED` |
| **P0** | `POST /api/drivers/complete-ride` | Must return `final_fare`, `payment_mode` |
| **P1** | `GET /api/drivers/ride-requests/:id` | Optional poll fallback; ensure it returns rides for driver's city/vehicle |
| **P1** | `POST /api/drivers/reject-ride` | Should include optional `reason` |
| **P1** | Location update | Either `PATCH /api/location/update-location` or lat/lng in `PUT /api/drivers/:id` |
| **P2** | `POST /api/drivers/rate-ride` | For post-ride rating UI |
| **P2** | `POST /api/drivers/emergency-sos` | For safety flows |

---

## 4. UI Gaps vs Uber (First Release)

| Area | Current State | Uber-Like Improvement |
|------|---------------|------------------------|
| **Home** | Map + online toggle + earnings panel | ✅ Good. Add trip progress bar when ride active |
| **Ride cards** | New request, active ride, complete | ✅ Good. Ensure swipe/buttons match Uber feel |
| **Navigation** | Opens Google Maps | ✅ Good |
| **Earnings** | Today total, ride count | ✅ Good. Add quick “last ride” amount |
| **Profile** | Edit, documents | ✅ Good |
| **Empty states** | Some screens | Add friendly empty states (e.g. “No rides yet”) |
| **Loading** | Spinners | Ensure consistent loading UX |
| **Errors** | Snackbars | Add retry buttons where useful |

---

## 5. First Release Checklist

### Backend

- [ ] Socket emits rides with `pickup_city_id`, `vehicle_type_id`
- [ ] Accept/Reject ride APIs work and update ride state
- [ ] Update-ride-status supports full flow
- [ ] OTP verification for ride start
- [ ] Complete ride returns fare and payment mode
- [ ] Driver location updates when online
- [ ] Cancel ride with reason
- [ ] Wallet, bank, withdraw flow end-to-end

### App

- [x] All ride flows use correct driver APIs (accept, update status, complete)
- [x] Zone + vehicle filtering for ride requests
- [x] Rate rider after completion (if UI exists)
- [x] Emergency SOS wired
- [ ] Notifications (inbox + FCM) working
- [ ] Responsive layout (per RESPONSIVE_REFACTOR_PLAN)

### Testing

- [ ] Full ride flow: request → accept → arrive → OTP → start → complete
- [ ] Cash vs online payment handling
- [ ] Cancel flow with reason
- [ ] Go offline during ride blocked
- [ ] Background/foreground ride notifications

---

## 6. API Summary (Driver App – First Release)

```
Auth:           POST /api/drivers/login
Registration:   POST /api/drivers/signup-with-vehicle
                GET  /api/drivers/cities
                GET  /api/vehicle-types/getall-vehicle
Online:         PATCH /api/drivers/preferred-city
                POST  /api/drivers/online
                PUT   /api/drivers/:id (location + fcm_token)
Rides:          Socket: driver_rides, ride_updated, ride_taken, ride_assigned
                GET   /api/rides/:id
                GET   /api/drivers/ride-requests/:id
                POST  /api/drivers/accept-ride
                POST  /api/drivers/reject-ride
                POST  /api/drivers/update-ride-status
                POST  /api/rides/verify-otp
                POST  /api/drivers/complete-ride
                PATCH /api/rides/rides/cancel
Earnings:       GET   /api/drivers/earnings/driver/:id
                GET   /api/drivers/wallet/:id
                POST  /api/drivers/withdraws
Bank:           GET   /api/drivers/bank-account/:id
                POST  /api/drivers/bank-account
History:        GET   /api/drivers/ride-history/:id
Profile:        GET   /api/drivers/:id
                PUT   /api/drivers/:id
Support:        POST  /api/drivers/report-issue
                POST  /api/drivers/emergency-sos
Rate:           POST  /api/drivers/rate-ride
Notifications:  GET   /api/notifications/getall
```

---

*Generated for UGO Driver App first release – Uber-style functionality.*
