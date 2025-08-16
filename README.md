# Extension Backend

A simple Rails API backend for the Chrome extension.

## Structure

This is a clean, basic Rails API with:

- **Users**: Simple user authentication with secure passwords
- **Conversations**: Basic conversation storage and retrieval
- **Simple Token Authentication**: Basic token-based auth for development

## Models

### User
- `name`: User's display name
- `email`: Unique email address
- `password_digest`: Encrypted password (using bcrypt)

### Conversation
- `user_id`: Reference to the user who created it
- `original_text`: The original text input
- `final_text`: The processed/response text

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create a new user
- `POST /api/auth/login` - Login existing user

### Users
- `GET /api/users/profile` - Get current user profile
- `GET /api/users/:id` - Get user by ID

### Conversations
- `GET /api/conversations` - List user's conversations
- `POST /api/conversations` - Create new conversation
- `GET /api/conversations/:id` - Get conversation by ID

## Setup

1. Install dependencies: `bundle install`
2. Setup database: `bin/rails db:create db:migrate db:seed`
3. Start server: `bin/rails server`

## Testing

Run tests with: `bin/rails test`

## Authentication

For development, the system uses simple tokens in the format: `token_{user_id}_{timestamp}`

Include in headers: `Authorization: Bearer token_1_1234567890`

**Note**: This is for development only. In production, use proper JWT tokens.
