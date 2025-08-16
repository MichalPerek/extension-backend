# Text Assistant Backend API

Ruby on Rails API backend for the Text Assistant Chrome extension.

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
  "token": "token_1_1234567890"
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
Authorization: Bearer token_1_1234567890
```

Response:
```json
{
  "user": {
    "name": "John Doe",
    "email": "user@example.com",
    "plan": "Pro Plan",
    "joinDate": "August 2024"
  }
}
```

#### Get Usage Statistics
```
GET /api/users/usage
Authorization: Bearer token_1_1234567890
```

Response:
```json
{
  "usage": {
    "textsProcessed": 247,
    "monthlyLimit": 1000
  }
}
```

## Development

### Database

The application uses PostgreSQL. Make sure you have PostgreSQL installed and running.

### Environment Variables

Create a `.env` file in the backend directory for environment-specific configuration:

```env
DATABASE_URL=postgresql://localhost/text_assistant_backend_development
SECRET_KEY_BASE=your_secret_key_here
```

### Testing

Run the test suite:
```bash
rails test
```

## Production Deployment

1. Set up environment variables
2. Configure CORS to allow your Chrome extension ID
3. Set up proper JWT token authentication
4. Configure database for production
5. Deploy to your preferred hosting platform (Heroku, AWS, etc.)

## Security Notes

- The current implementation uses simple tokens for development
- In production, implement proper JWT token authentication
- Configure CORS to only allow your Chrome extension ID
- Use HTTPS in production
- Implement rate limiting for API endpoints
