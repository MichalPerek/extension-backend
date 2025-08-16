# User Roles System

This document describes the user roles system implemented in the extension backend to control user permissions on the frontend.

## Overview

The system implements two basic user roles:
- **admin**: Full access to all features
- **standard**: Limited access to basic features

## Database Changes

### Migration
- Added `role` field to users table (string, default: 'standard', indexed)
- Field is required and validates against allowed values

### Schema Update
```ruby
# Users table now includes:
t.string "role", default: "standard", null: false
t.index ["role"]
```

## User Model Updates

### Validations
- Role must be present
- Role must be one of: 'admin', 'standard'

### New Methods
- `admin?` - Returns true if user has admin role
- `standard?` - Returns true if user has standard role
- `can_manage_users?` - Returns true for admins only
- `can_manage_plans?` - Returns true for admins only
- `can_view_all_conversations?` - Returns true for admins only
- `role_permissions` - Returns hash of permission flags

### Permission Flags
```ruby
# Admin permissions
{
  canManageUsers: true,
  canManagePlans: true,
  canViewAllConversations: true,
  canDeleteContent: true,
  canModifySettings: true
}

# Standard user permissions
{
  canManageUsers: false,
  canManagePlans: false,
  canViewAllConversations: false,
  canDeleteContent: false,
  canModifySettings: false
}
```

## API Updates

### User Endpoints
The following endpoints now return role information:
- `GET /api/users/:id` (show)
- `GET /api/users/profile` (profile)

### Response Format
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "admin",
    "rolePermissions": {
      "canManageUsers": true,
      "canManagePlans": true,
      "canViewAllConversations": true,
      "canDeleteContent": true,
      "canModifySettings": true
    },
    "plan": {...},
    "joinDate": "August 2025",
    "usage": {...}
  }
}
```

## Frontend Usage

### Checking Permissions
```javascript
// Check if user can perform admin actions
if (user.rolePermissions.canManageUsers) {
  // Show user management UI
}

// Check role directly
if (user.role === 'admin') {
  // Show admin features
}
```

### Conditional Rendering
```javascript
// Example: Only show admin panel for admins
{user.role === 'admin' && (
  <AdminPanel />
)}

// Example: Disable buttons based on permissions
<button 
  disabled={!user.rolePermissions.canDeleteContent}
  onClick={handleDelete}
>
  Delete
</button>
```

## Database Seeding

The system includes default users:
- **Admin User**: admin@example.com (admin role, 1000 points)
- **Standard User**: user@example.com (standard role, 100 points)

## Testing

Run the test suite to verify role functionality:
```bash
bin/rails test test/models/user_test.rb
```

## Migration Commands

To apply the role system:

1. Run the migration:
```bash
bin/rails db:migrate
```

2. Seed the database:
```bash
bin/rails db:seed
```

## Future Enhancements

Consider adding:
- Role-based API endpoint protection
- Audit logging for admin actions
- Custom role definitions
- Role inheritance system
- Permission groups
