# ECG News Database Structure

## Realtime Database Path: `/ecg_news`

### News Item Structure

```json
{
  "ecg_news": {
    "news_id_1": {
      "title": "Scheduled Maintenance in Accra",
      "content": "ECG will be performing maintenance work in the Accra Central area from 10 AM to 2 PM. Please expect intermittent power outages.",
      "imageUrl": "https://example.com/image.jpg",
      "publishedAt": 1704067200000,
      "source": "ECG",
      "areaAffected": "accra_central",
      "isActive": true
    }
  }
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | String | Yes | News headline |
| `content` | String | Yes | Full news content |
| `imageUrl` | String | No | Optional image URL |
| `publishedAt` | Number | Yes | Unix timestamp (milliseconds) |
| `source` | String | No | Source of news (default: "ECG") |
| `areaAffected` | String | No | Area ID or "all" for nationwide |
| `isActive` | Boolean | No | Show/hide news (default: true) |

### Security Rules

```json
{
  "rules": {
    "ecg_news": {
      ".read": true,
      ".write": "auth != null && auth.token.admin == true"
    }
  }
}
```

### Sample Data

```json
{
  "ecg_news": {
    "-NqABC123": {
      "title": "Scheduled Maintenance",
      "content": "Maintenance work scheduled for Accra Central today from 10 AM to 2 PM.",
      "publishedAt": 1704067200000,
      "source": "ECG",
      "areaAffected": "accra_central",
      "isActive": true
    }
  }
}
```
