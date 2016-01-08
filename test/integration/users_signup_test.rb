require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  
  test "invalid signup information" do
    get signup_path #technically this is unneccessary
    #make sure the count stays the same
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
    #could make these more explicit, like adding stuff
    assert_select 'div#error_explanation'
    assert_select 'div.alert-danger'
  end
  
  test "valid signup information" do
      get signup_path
      assert_difference 'User.count', 1 do
        post_via_redirect users_path, user: { name:  "Example User",
                                              email: "user@example.com",
                                              password:              "password",
                                              password_confirmation: "password" }
      end
      assert_template 'users/show'
      assert_not flash.nil?
      assert is_logged_in? #logged is defined in test helper
    end
end
