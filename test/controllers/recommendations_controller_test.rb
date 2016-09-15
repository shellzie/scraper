require 'test_helper'

class RecommendationsControllerTest < ActionController::TestCase
  test "the format_date method returns correctly formatted string" do
    assert equal '2016-06-01', @controller.send(:format_st, "6/1/2015")
    # assert true
  end
end
