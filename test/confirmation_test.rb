require 'test_helper'

# Tests the ActsAsAuthentic::EmailToken::Confirmation module.
class Confirmation < Minitest::Test
  def test_confirm_email
    Authlogic::Random.expects(:friendly_token).returns('IMvEDB6NJIm5Z7cSe2a')
    o = Confirmable.new email: 'a@example.com', new_email: 'b@example.com'
    t = Time.now
    Timecop.freeze(t) do
      o.confirm_email
      assert_equal 'b@example.com', o.email
      assert_nil o.read_attribute(:new_email)
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t, o.email_token_updated_at
      assert o.new_record?
    end
  end
  
  def test_confirm_email_bang
    Authlogic::Random.expects(:friendly_token).returns('IMvEDB6NJIm5Z7cSe2a')
    o = Confirmable.new email: 'a@example.com', new_email: 'b@example.com'
    t = Time.now
    Timecop.freeze(t) do
      o.confirm_email!
      assert_equal 'b@example.com', o.email
      assert_nil o.read_attribute(:new_email)
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t, o.email_token_updated_at
      assert o.persisted?
      o.reload
      assert_equal 'b@example.com', o.email
      assert_nil o.read_attribute(:new_email)
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t.utc, o.email_token_updated_at.utc
    end
  end
  
  def test_confirm_email_activates
    o = Activatable.new
    o.confirm_email
    assert o.activated
    assert o.new_record?
  end
  
  def test_confirm_email_bang_activates
    o = Activatable.create! email: 'a@example.com'
    o.confirm_email!
    assert o.activated
    assert o.persisted?
    o.reload
    assert o.activated
  end
  
  def test_custom_activation_method
    o = CustomMailerClassAndMethod
  end
  
  def test_send_email_confirmation_when_changing_address
    o = Confirmable.create! email: 'a@example.com', new_email: nil
    o.update_attributes! new_email: 'b@example.com'
    c = mock # The mailer requires a controller.
    m = mock # The mailer will return this mock message.
    m.expects(:deliver_now)
    UserMailer.expects(:email_confirmation).with(o, c).returns(m)
    assert o.maybe_deliver_email_confirmation!(c)
  end
  
  def test_custom_mailer_class_and_method
    o = CustomMailerClassAndMethod.create! email: 'a@example.com', new_email: nil
    o.update_attributes! new_email: 'b@example.com'
    c = mock # The mailer requires a controller.
    m = mock # The mailer will return this mock message.
    m.expects(:deliver_now)
    CustomUserMailer.expects(:custom_method).with(o, c).returns(m)
    assert o.maybe_deliver_email_confirmation!(c)
  end
  
  def test_email_changed_previously_returns_false_for_clean_record
    o = Confirmable.create! email: 'a@example.com'
    o.reload
    refute o.email_changed_previously?
  end
  
  def test_email_changed_previously_returns_false_for_clean_record_with_new_email_set_to_same_value
    o = Confirmable.create! email: 'a@example.com'
    o.update_attributes! new_email: 'a@example.com'
    o.reload
    refute o.email_changed_previously?
  end
  
  def test_email_changed_previously_returns_true_when_email_changed
    o = Confirmable.create! email: 'a@example.com'
    o.reload
    o.update_attributes! email: 'b@example.com'
    assert o.email_changed_previously?
  end
  
  def test_email_changed_previously_returns_false_when_email_set_to_same_value
    o = Confirmable.create! email: 'a@example.com'
    o.reload
    o.update_attributes! email: 'a@example.com'
    refute o.email_changed_previously?
  end
  
  def test_email_changed_previously_returns_true_when_new_email_changed
    o = Confirmable.create! email: 'a@example.com'
    o.reload
    o.update_attributes! new_email: 'b@example.com'
    assert o.email_changed_previously?
  end
  
  def test_email_changed_previously_returns_false_when_new_email_set_to_same_value
    o = Confirmable.create! email: 'a@example.com', new_email: 'b@example.com'
    o.reload
    o.update_attributes! new_email: 'b@example.com'
    refute o.email_changed_previously?
  end
  
  def test_new_email_defaults_to_current_email
    o = Confirmable.new email: 'a@example.com'
    assert_equal 'a@example.com', o.new_email
    assert_equal 'a@example.com', o.new_email_before_type_cast
  end
  
  def test_new_email_not_set_if_equal_to_current_email
    o = Confirmable.new email: 'a@example.com'
    o.new_email = 'a@example.com'
    assert_nil o.read_attribute(:new_email)
    o.save
    o.reload
    assert_nil o.read_attribute(:new_email)
  end
end