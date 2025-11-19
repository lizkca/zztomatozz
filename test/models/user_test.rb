require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    u = User.new(email: "u@example.com", password: "secret", password_confirmation: "secret")
    assert u.valid?
  end
end
