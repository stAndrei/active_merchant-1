require 'test_helper'
require 'common_data/bit_pay'

class BitPayNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Iframes
  include CommonData::BitPay

  def setup
    @bit_pay = BitPay::Notification.new(http_raw_data, :credential1 => "api_key")
  end

  def test_accessors
    assert @bit_pay.complete?
    assert_equal "complete", @bit_pay.status
    assert_equal "w1GRw1q86WPSUlT1r2cGsCZffrUM-KqT9fMFnbC9jo=", @bit_pay.transaction_id
    assert_equal nil, @bit_pay.item_id
    assert_equal 1, @bit_pay.gross
    assert_equal "USD", @bit_pay.currency
    assert_equal nil, @bit_pay.received_at
    assert !@bit_pay.test? #BitPay doesn't support test-mode
  end

  def test_compositions
    assert_equal Money.new(100, 'USD'), @bit_pay.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement
    @bit_pay.stubs(:ssl_get).returns(stub(:code => 200, :body => invoice_raw_data))
    assert @bit_pay.acknowledge

    @bit_pay.stubs(:ssl_get).returns(stub(:code => 500, :body => invoice_raw_data))
    assert_raise StandardError do
      @bit_pay.acknowledge
    end
  end

  def test_respond_to_acknowledge
    assert @bit_pay.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    '{"id":"w1GRw1q86WPSUlT1r2cGsCZffrUM-KqT9fMFnbC9jo=","url":"https://bitpay.com/invoice/w1GRw1q86WPSUlT1r2cGsCZffrUM-KqT9fMFnbC9jo=","status":"complete","btcPrice":"0.0083","price":1,"currency":"USD","invoiceTime":1370539476654,"expirationTime":1370540376654,"currentTime":1370539573956}'
  end

  def invoice_raw_data
    CommonData::BitPay.raw_invoice_json
  end
end