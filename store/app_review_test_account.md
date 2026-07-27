# App Store 審核測試帳號 (App Review Test Account)

App Store 審核員需要一組帳號才能通過登入頁。請先建立以下帳號，再填入 App Store Connect
的「App 審核資訊 → 登入資訊」。

## 建議帳號 (Suggested credentials)

| 欄位 | 值 |
|---|---|
| **Email** | `review@fitnesshealth.app` |
| **Password** | `FitReview#2026` |

> Firebase 密碼登入不會寄驗證信，Email 不需真實可收信；此帳號僅供審核使用。
> 密碼至少 6 碼即可，可自行更換，但務必與填入 App Store Connect 的一致。

## 如何建立此帳號（擇一）

**方法 A — 在 App 內建立（最簡單）**
1. 打開 App → 登入頁點「建立帳號」
2. 輸入上面的 Email 與密碼、確認密碼
3. 點「建立帳號」即完成

**方法 B — 在 Firebase 主控台建立**
1. 前往 [Firebase Console → Authentication → Users](https://console.firebase.google.com/project/fitness-ddfc0/authentication/users)
2. 點「新增使用者 / Add user」
3. 填入上面的 Email 與密碼 → 儲存

---

## App Store Connect「登入資訊」欄位

- **需要登入 (Sign-in required)**：勾選 ✅
- **使用者名稱 (User name)**：`review@fitnesshealth.app`
- **密碼 (Password)**：`FitReview#2026`

## 審核備註 (Review Notes) — 可直接貼上

```
This app requires an account to sync training plans across devices. Test
credentials are provided in the sign-in information above.

Notes for the reviewer:
- Sign in with the provided email/password to access all features
  (Weight Training, Stretching, Slow Jogging, Plan, Nutrition, Fasting,
  Body Map).
- Exercise demo videos open via the embedded YouTube IFrame player.
- Ambient running sounds are generated on-device; no network needed.
- No special hardware, location, camera, or microphone is used.
- Account data (email + training plans) is stored in Firebase and can be
  deleted on request per our privacy policy.
```
