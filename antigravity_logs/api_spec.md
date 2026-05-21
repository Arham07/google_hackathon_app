# BaKhabar Alerts — API Specification & Integration Reference

This document outlines the API endpoints, query parameters, request payloads, and response JSON formats used by the mobile client to communicate with the crisis intelligence backend system.

---

## 🛜 Base Configurations

- **Production Base URL**: `https://ciro-backeend-app.netlify.app`
- **Client Class**: `ApiClient` (`lib/core/api/api_client.dart`)
- **Timeout Defaults**:
  - Connect Timeout: `15 Seconds`
  - Receive Timeout: `30 Seconds`

---

## 🌐 Endpoints Reference

### 1. Fetch All Events
Retrieves a list of all active incidents registered in the system.

- **HTTP Verb**: `GET`
- **Path**: `/api/events`
- **Query Parameters**:
  | Name | Type | Required | Default | Description |
  | :--- | :--- | :--- | :--- | :--- |
  | `city` | `String` | No | `Karachi` | Filter events to a specific city scope. |
  | `limit` | `int` | No | `500` | Limits the maximum quantity of returned records. |
  | `event_id` | `String` | No | - | Request a specific event details payload by ID. |
  | `view` | `String` | No | - | Set to `full` to fetch extra news & weather trails. |

- **Response Format**:
  ```json
  {
    "count": 12,
    "events": [
      {
        "event_id": "8432a5fe-...",
        "title": "Severe Flash Flooding on GT Road",
        "description": "Rising water levels blocking major highway lanes.",
        "city": "Karachi",
        "latitude": 24.8607,
        "longitude": 67.0011,
        "priority": "HIGH",
        "status": "active",
        "scan_datetime": "2026-05-20T12:00:00Z"
      }
    ]
  }
  ```

---

### 2. Fetch Nearest Events
Retrieves incidents closest to the client's current coordinates.

- **HTTP Verb**: `GET`
- **Path**: `/api/events/nearest`
- **Query Parameters**:
  | Name | Type | Required | Default | Description |
  | :--- | :--- | :--- | :--- | :--- |
  | `lat` | `double` | **Yes** | - | Current latitude of user device. |
  | `lng` | `double` | **Yes** | - | Current longitude of user device. |
  | `city` | `String` | No | `Karachi` | City scope. |
  | `limit` | `int` | No | `500` | Record limit. |

- **Response Format**:
  ```json
  {
    "count": 1,
    "events": [...],
    "nearest_area": {
      "city": "Karachi",
      "area": "Clifton",
      "area_lat": 24.8162,
      "area_lng": 67.0330,
      "distance_km": 1.45
    }
  }
  ```

---

### 3. Submit Citizen Report
Submits a new disaster or incident report directly from the client.

- **HTTP Verb**: `POST` (Multipart Form Data)
- **Path**: `/api/user-reports/submit`
- **Multipart Form Payload**:
  | Field Name | Type | Description |
  | :--- | :--- | :--- |
  | `text` | `String` | Description of what happened (min 10 chars). |
  | `lat` | `String` (double value) | Picked latitude of the incident. |
  | `lng` | `String` (double value) | Picked longitude of the incident. |
  | `photo` | `File` | Binary image attachment representing the hazard. |

- **Success Response (New Event Created)**:
  ```json
  {
    "status": "success",
    "event": {
      "event_id": "a908df2a-...",
      "is_user_submitted": true
    }
  }
  ```

- **Response (Duplicate Detected)**:
  ```json
  {
    "status": "duplicate",
    "error": "A similar report already exists nearby."
  }
  ```
