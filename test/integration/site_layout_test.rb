require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    #both these users are from fixtures
   @user = users(:michael)
   @other_user = users(:archer)
  end
  
  test "layout links" do
      get root_path
      assert_select "a[href=?]", users_path, count:0
      log_in_as(@user)
      get root_path
      #check if home page has 2 root path links
      assert_template 'static_pages/home'
      assert_select "a[href=?]", root_path, count: 2
      assert_select "a[href=?]", help_path
      assert_select "a[href=?]", about_path
      assert_select "a[href=?]", contact_path
      get signup_path
      assert_select "title" , full_title("Sign up")
      assert_select "a[href=?]", users_path
    end
end
