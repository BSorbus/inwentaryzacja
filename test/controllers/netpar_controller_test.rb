require 'test_helper'

class NetparControllerTest < ActionDispatch::IntegrationTest
  test "should get exams_ra_select2_index" do
    get netpar_exams_ra_select2_index_url
    assert_response :success
  end

  test "should get exams_mor_select2_index" do
    get netpar_exams_mor_select2_index_url
    assert_response :success
  end

end
