require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  #stuff in setup is run before every test
  def setup
    #@ makes it an instance variable, available to all methods in this class, also makes it available in the view
    @base_title = "Ruby on Rails Tutorial Sample App"
  end
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end
  
  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

end
