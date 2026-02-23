# Responsive Refactoring Plan – UGO Driver App

This document outlines the global responsive setup, device categorization, and phased refactoring plan for making the app fully responsive across mobile, 7", and 10" Android devices.

---

## 1. Global Responsive Setup

### Responsive Helper Class (`lib/constants/responsive.dart`)

| Method | Description |
|--------|-------------|
| `responsiveWidth(context, value)` | Scales width by `screenWidth / 375` |
| `responsiveHeight(context, value)` | Scales height by `screenHeight / 812` |
| `responsiveFontSize(context, value)` | Scales font with min/max caps (mobile max 24, tablet10 max 28) |
| `spacing(context, {scale})` | Standard spacing: scale 1≈8, 2≈16, 3≈24, 4≈32 |

### Extension (`lib/constants/responsive_ext.dart`)

```dart
import '/constants/responsive_ext.dart';

// Usage
context.rW(20)    // responsive width
context.rH(100)   // responsive height
context.rF(16)    // responsive font size
context.rS(2)     // spacing (16)
context.rHPad()   // horizontal padding
context.deviceType  // DeviceType.mobile | tablet7 | tablet10
```

### Replacing Hardcoded Values

| Avoid | Use |
|-------|-----|
| `SizedBox(width: 10)` | `SizedBox(width: context.rW(10))` or `SizedBox(width: context.rS(2))` |
| `height: 56` | `height: context.rH(56)` or `Responsive.buttonHeight(context)` |
| `fontSize: 16` | `fontSize: context.rF(16)` or `Responsive.fontSize(context, 16)` |
| `padding: EdgeInsets.all(24)` | `padding: EdgeInsets.all(context.rS(3))` |
| `borderRadius: 12` | `borderRadius: BorderRadius.circular(context.rW(12))` |

---

## 2. Device Type Categorization

### Breakpoints (`lib/constants/device_type.dart`)

| DeviceType | Width Range |
|------------|-------------|
| `mobile` | width < 600 dp |
| `tablet7` | 600 ≤ width < 900 dp |
| `tablet10` | width ≥ 900 dp |

### Helper

```dart
DeviceType type = Responsive.getDeviceType(context);
// or
DeviceType type = context.deviceType;

switch (type) {
  case DeviceType.mobile:
    return SingleColumnLayout();
  case DeviceType.tablet7:
    return TwoColumnLayout();
  case DeviceType.tablet10:
    return MultiPaneLayout();
}
```

### Layout Adaptation

| Device | Layout |
|--------|--------|
| **mobile** | Single-column, vertical scroll |
| **tablet7** | Two-column for forms/lists, side-by-side where useful |
| **tablet10** | Multi-pane, optional side menu, expanded content |

---

## 3. Layout Widget Usage

Use these patterns in all critical screens:

- **LayoutBuilder** – Adapt layout based on `constraints.maxWidth` / `constraints.maxHeight`
- **MediaQuery.sizeOf(context)** – Avoid `MediaQuery.of(context).size` (use sizeOf for performance)
- **Expanded / Flexible / Spacer** – For flexible layouts
- **FittedBox** – For text/icons that must fit
- **ConstrainedBox** – For max width on tablets (e.g. 600)
- **SingleChildScrollView** – For content that can overflow
- **FractionallySizedBox** – For percentage-based sizing

---

## 4. Typography and Images

- All `Text` uses `Responsive.fontSize(context, base)` or `context.rF(base)`.
- Caps: mobile ≤ 24, tablet7 ≤ 26, tablet10 ≤ 28.
- Icons use `Responsive.iconSize(context, base: 24)`.
- Provide `xhdpi`, `xxhdpi`, `xxxhdpi` assets where needed; prefer vector/SVG.

---

## 5. Orientation and Safe Area

- Do **not** lock orientation unless required.
- Wrap top-level screens with `SafeArea` or use `MediaQuery.paddingOf(context)`.
- Test both portrait and landscape on each device category.

---

## 6. Screens and Widgets to Update

### Priority 1: Login / OTP / Registration

| Screen | Path | Changes |
|--------|------|---------|
| Login | `login/login_widget.dart` | Already uses Responsive; align with rW/rH/rF/rS |
| OTP Verification | `otpverification/otpverification_widget.dart` | Replace hardcoded sizes with responsive helpers |
| OTP Sheet | `components/otp_screen.dart` | rW, rH, rF for padding and font sizes |
| Onboarding | `on_boarding/on_boarding_widget.dart` | LayoutBuilder, responsive spacing |
| First Details | `firstdetails/firstdetails_widget.dart` | Forms with rW/rH/rF |
| Address Details | `address_details/address_details_widget.dart` | Same pattern |

### Priority 2: Home and Dashboards

| Screen | Path | Changes |
|--------|------|---------|
| Home | `home/home_widget.dart` | Already responsive; verify SafeArea, ConstrainedBox |
| App Header | `home/widgets/app_header.dart` | Use rW/rH for icon and header sizing |
| Incentive Panel | `home/widgets/incentive_panel.dart` | Use rS for spacing |
| Earnings Summary | `home/widgets/earnings_summary.dart` | Use rS, rF |
| Ride Status Panel | `home/widgets/ride_status_panel.dart` | rW/rH for badge |
| Offline Dashboard | `home/widgets/offline_dashboard.dart` | rH for icon, rF for text |

### Priority 3: Forms and Detail Screens

| Screen | Path | Changes |
|--------|------|---------|
| Edit Profile | `account_support/edit_profile.dart` | Two-column on tablet7+ |
| Edit Address | `account_support/edit_address.dart` | Responsive form fields |
| Add Bank Account | `add_bankAccount/add_bank_account_widget.dart` | Replace hardcoded padding/margins |
| Wallet | `wallet/wallet_widget.dart` | rW/rH for cards |
| Add Money | `add_money/add_money_widget.dart` | Responsive amounts and buttons |
| Withdraw | `withdraw/withdraw_widget.dart` | Same pattern |
| Profile Setting | `profile_setting/profile_setting_widget.dart` | ListTile heights, icon sizes |
| Account Support | `account_support/account_support_widget.dart` | Responsive list |

### Priority 4: Ride Flow

| Screen | Path | Changes |
|--------|------|---------|
| New Request Card | `components/new_request_card.dart` | rW/rH/rF (partially done) |
| Active Ride Card | `components/active_ride_card.dart` | Responsive padding |
| Start Ride Card | `components/start_ride_card.dart` | Same |
| Complete Ride Overlay | `components/complete_ride_overlay.dart` | Same |
| Cash Payment Screen | `components/cash_payment_screen.dart` | rW/rH/rF |
| Review Screen | `components/review_screen.dart` | rF for stars and text |
| Cancel Ride Sheet | `components/cancel_ride_sheet.dart` | rS for spacing |

### Priority 5: Documents and KYC

| Screen | Path | Changes |
|--------|------|---------|
| PAN Upload | `panupload_screen/` | Replace hardcoded sizes |
| Aadhar Upload | `adhar_upload/` | Same |
| Driving License | `driving_dl/` | Same |
| Vehicle Image | `vehicle_image/` | Same |
| Insurance Image | `insurance_image/` | Same |
| Pollution Image | `pollution_image/` | Same |

### Priority 6: Other Screens

| Screen | Path |
|--------|------|
| Scan to Book | `scan_to_book/` |
| Ride Overview | `ride_overview/` |
| Team Earnings | `team_earnings/` |
| Inbox | `inbox_page/` |
| Menu | `components/menu_widget.dart` |
| Background Location Notice | `background_location_notice/` |

---

## 7. Example: Responsive Login Screen

```dart
import '/constants/responsive_ext.dart';
import '/constants/responsive.dart';

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dt = context.deviceType;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTwoCol = dt.isTablet && constraints.maxWidth > 600;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.all(context.rS(3)),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: context.rH(40)),
                          Icon(Icons.directions_car, size: context.rW(80)),
                          SizedBox(height: context.rS(3)),
                          Text(
                            'UGO Driver',
                            style: TextStyle(
                              fontSize: context.rF(28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: context.rS(4)),
                          TextField(
                            style: TextStyle(fontSize: context.rF(16)),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: context.rW(16),
                                vertical: context.rH(14),
                              ),
                            ),
                          ),
                          SizedBox(height: context.rS(3)),
                          SizedBox(
                            width: double.infinity,
                            height: Responsive.buttonHeight(context),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Continue', style: TextStyle(fontSize: context.rF(16))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 8. Testing Checklist

### Devices to Simulate

| Category | Resolution |
|----------|------------|
| Mobile (small) | 360×640 |
| Mobile (medium) | 375×667 |
| Mobile (large) | 414×736 |
| 7" tablet | 600×960, 720×1280 |
| 10" tablet | 800×1280, 1080×1920, 1280×800 |

### Verification Checklist

- [ ] No horizontal overflow or scrollbar on any screen
- [ ] No clipped text
- [ ] No squeezed buttons (min 48dp touch target)
- [ ] No overlapping or crowded elements
- [ ] Portrait and landscape both usable
- [ ] SafeArea respected (notch, status bar)
- [ ] Forms readable and usable on 7" and 10" tablets
- [ ] Home dashboard scales correctly
- [ ] Ride request cards readable on all sizes

---

## 9. Migration Notes

1. Add `import '/constants/responsive_ext.dart';` to screens that will use `context.rW`, etc.
2. Replace `SizedBox(width: 10)` → `SizedBox(width: context.rW(10))` or `SizedBox(width: context.rS(2))`.
3. Replace `fontSize: 16` → `fontSize: context.rF(16)`.
4. Replace `padding: EdgeInsets.all(24)` → `padding: EdgeInsets.all(context.rS(3))`.
5. Remove scattered `if (MediaQuery.size.width > 400)` checks; use `context.deviceType` instead.
6. No legacy `dimensions.dart` or `screen.dart` found; nothing to remove.
