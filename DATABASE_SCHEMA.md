# WattX Database Schema

This document outlines the structure of the Firebase Realtime Database used in the WattX Smart Meter System.

## Node: `Users`
Stores profile information for all users (Consumers, KSEB Officers, and Admins).

| Field | Type | Description |
| :--- | :--- | :--- |
| `uid` | String (Key) | Firebase Authentication UID |
| `name` | String | Full name of the user |
| `email` | String | Email address |
| `role` | String | Role: `user`, `officer`, or `admin` |
| `phoneNumber` | String? | Optional contact number |
| `address` | String? | Physical address |
| `profileImageUrl`| String? | URL to profile picture |
| `budgetLimit` | Double | Monthly energy budget limit |
| `isActive` | Boolean | Account status |
| `createdAt` | Timestamp | Account creation time |

---

## Node: `Devices`
Stores smart meter hardware details and ownership mapping.

| Field | Type | Description |
| :--- | :--- | :--- |
| `meterId` | String (Key) | Unique identifier for the smart meter (e.g., `METER001`) |
| `ownerUid` | String | UID of the user who owns this device |
| `address` | String | Installation address |
| `firmwareVersion`| String | Current firmware version of the IoT device |
| `status` | String | Connection status (e.g., `Online`, `Offline`) |
| `lastSync` | Timestamp | Last time the device communicated with the server |

---

## Node: `EnergyReadings`
Real-time and historical consumption data.

### Sub-node: `live/{meterId}`
Most recent reading for real-time monitoring.

| Field | Type | Description |
| :--- | :--- | :--- |
| `power` | Double | Current power consumption (kW) |
| `voltage` | Double | Line voltage (V) |
| `current` | Double | Line current (A) |
| `timestamp` | Timestamp | Reading time |

### Sub-node: `historical/{meterId}/{period}`
Logs for specific timeframes (e.g., `daily`, `weekly`, `monthly`).

| Field | Type | Description |
| :--- | :--- | :--- |
| `(auto-key)` | Object | Reading object containing `power`, `voltage`, `current`, `timestamp` |

---

## Node: `Alerts`
User-specific notifications and system alerts.

**Path**: `Alerts/{uid}/{alertId}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | String | Alert heading |
| `message` | String | Detailed description |
| `type` | String | `critical`, `warning`, or `info` |
| `timestamp` | Timestamp | Time alert was generated |
| `isRead` | Boolean | Whether the user has seen the alert |

---

## Node: `OfficerAssignments`
Mapping for administrative oversight.

**Path**: `OfficerAssignments/{officerUid}/{consumerUid}`

| Key | Value | Description |
| :--- | :--- | :--- |
---

## Node: `Bills`
Monthly energy bills generated for consumers.

**Path**: `Bills/{uid}/{billId}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `amount` | Double | Total amount due |
| `unitsConsumed`| Double | Total energy units used (kWh) |
| `billingMonth` | String | e.g., "January 2026" |
| `dueDate` | Timestamp | Payment deadline |
| `status` | String | `paid`, `unpaid`, or `overdue` |
| `billDownloadUrl`| String? | URL to the PDF version of the bill |

---

## Node: `Payments`
Log of financial transactions.

**Path**: `Payments/{uid}/{transactionId}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `amount` | Double | Amount paid |
| `paymentMethod` | String | e.g., `Credit Card`, `UPI`, `Net Banking` |
| `billId` | String | Reference to the associated bill |
| `timestamp` | Timestamp | Time of transaction |
| `status` | String | `success`, `failed`, or `pending` |
| `receiptNumber` | String | Official receipt identifier |

---

## Node: `Tariffs`
Structure for dynamic electricity pricing rates.

**Path**: `Tariffs/{slabId}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `slabName` | String | e.g., "Non-Domestic", "Residential 0-100" |
| `ratePerUnit` | Double | Cost per energy unit |
| `fixedCharge` | Double | Baseline monthly charge |
| `description` | String | Brief rule explanation |

---

## Node: `ServiceRequests`
Customer support and maintenance tickets.

**Path**: `ServiceRequests/{uid}/{requestId}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `subject` | String | Short title of the issue |
| `description` | String | Detailed explanation |
| `type` | String | `Fault`, `Billing`, `Installation`, or `Other` |
| `status` | String | `Open`, `InProgress`, or `Resolved` |
| `createdAt` | Timestamp | Submission time |

---

## Node: `SystemNotices`
Broadcast messages from administrative officers.

**Path**: `SystemNotices/{noticeId}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | String | Notice heading |
| `content` | String | Detailed message body |
| `priority` | String | `high`, `medium`, or `low` |
| `expiryDate` | Timestamp | When the notice should be removed |
| `authorName` | String | Name of the officer who posted it |
| `createdAt` | Timestamp | Posting time |
