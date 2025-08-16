# Text Assistant Backend API

Ruby on Rails API backend for the Text Assistant Chrome extension.

## Project Structure

This repository contains the Rails API backend:

```
extension-backend/
├── app/
│   ├── controllers/api/
│   │   ├── auth_controller.rb    # Login/signup endpoints
│   │   └── users_controller.rb   # User profile/usage endpoints
│   └── models/
│       └── user.rb              # User model with devise_token_auth
├── config/
│   ├── routes.rb                # API routes
│   └── application.rb           # Rails configuration
└── db/                          # Database migrations
```

## Setup

### Prerequisites

- Ruby 3.3.5 or higher
- PostgreSQL
- Rails 7.2

### Installation

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Create and setup the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

3. Start the server:
   ```bash
   rails server
   ```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "plan": "Pro Plan",
    "joinDate": "August 2024",
    "usage": {
      "textsProcessed": 247,
      "monthlyLimit": 1000
    }
  },
  "token": "your_auth_token"
}
```

#### Signup
```
POST /api/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123"
}
```

### User Data

#### Get User Profile
```
GET /api/users/profile
Authorization: Bearer your_auth_token
```

#### Get Usage Statistics
```
GET /api/users/usage
Authorization: Bearer your_auth_token
```

## Development

### Starting the Server
```bash
rails server
```

### Running Tests
```bash
rails test
```

### Database Console
```bash
rails console
```

## Related Repositories

- **Frontend**: [extension](https://github.com/yourusername/extension) - Chrome extension frontend
