# frozen_string_literal: true

require 'test_helper'

class ReceiptPdfsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get receipt_pdfs_index_url
    assert_response :success
  end
end
