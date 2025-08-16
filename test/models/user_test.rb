require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should not save user without role" do
    user = User.new(name: "Test User", email: "test@example.com")
    assert_not user.save, "Saved the user without a role"
  end

  test "should not save user with invalid role" do
    user = User.new(name: "Test User", email: "test@example.com", role: "invalid_role")
    assert_not user.save, "Saved the user with invalid role"
  end

  test "should save user with valid role" do
    user = User.new(name: "Test User", email: "test@example.com", role: "standard")
    assert user.save, "Could not save user with valid role"
  end

  test "admin? method returns true for admin role" do
    user = User.new(role: "admin")
    assert user.admin?
  end

  test "admin? method returns false for standard role" do
    user = User.new(role: "standard")
    assert_not user.admin?
  end

  test "standard? method returns true for standard role" do
    user = User.new(role: "standard")
    assert user.standard?
  end

  test "standard? method returns false for admin role" do
    user = User.new(role: "admin")
    assert_not user.standard?
  end

  test "role permissions for admin" do
    user = User.new(role: "admin")
    permissions = user.role_permissions
    
    assert permissions[:canManageUsers]
    assert permissions[:canManagePlans]
    assert permissions[:canViewAllConversations]
    assert permissions[:canDeleteContent]
    assert permissions[:canModifySettings]
  end

  test "role permissions for standard user" do
    user = User.new(role: "standard")
    permissions = user.role_permissions
    
    assert_not permissions[:canManageUsers]
    assert_not permissions[:canManagePlans]
    assert_not permissions[:canViewAllConversations]
    assert_not permissions[:canDeleteContent]
    assert_not permissions[:canModifySettings]
  end
end
