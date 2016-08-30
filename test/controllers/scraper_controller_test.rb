require 'test_helper'

class ScraperControllerTest < ActionController::TestCase
  test "should get scrape" do
    get :scrape
    assert_response :success
  end

end
