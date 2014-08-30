require 'test_helper'

# Tests the ActsAsAuthentic::EmailToken module.
class EmailTokenTest < Minitest::Test
  def test_raises_if_email_token_exists_without_email_token_updated_at
    assert_raises(::Authlogic::ActsAsAuthentic::EmailToken::DBStructureError) do
      # EmailToken::Methods is included upon a call to acts_as_authentic. When that
      # module is included, we check the validity of the DB structure.
      MissingUpdatedAt.class_eval { acts_as_authentic }
    end
  end
  
  def test_recovers_gracefully_if_email_token_does_not_exist
    NoEmailToken.class_eval { acts_as_authentic }
  end
  
  def test_initializes_columns_on_create
    Authlogic::Random.expects(:friendly_token).returns('IMvEDB6NJIm5Z7cSe2a')
    t = Time.now
    Timecop.freeze(t) do
      o = BasicModel.create!
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t, o.email_token_updated_at
    end
  end
  
  def test_initializes_blank_columns_on_update
    Authlogic::Random.expects(:friendly_token).twice.returns('IMvEDB6NJIm5Z7cSe2a')
    o = BasicModel.create!
    o.update_columns(email_token: nil, email_token_updated_at: nil)
    o.reload
    assert_nil o.email_token
    assert_nil o.email_token_updated_at
    t = Time.now
    Timecop.freeze(t) do
      o.save!
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t, o.email_token_updated_at
    end
  end
  
  def test_find_using_email_token_returns_matching_record
    o = BasicModel.create!
    assert_equal o, BasicModel.find_using_email_token(o.email_token)
  end
  
  def test_find_using_email_token_expiration
    o = BasicModel.create!
    Timecop.travel(25.hours.from_now) do
      assert_nil BasicModel.find_using_email_token(o.email_token, 1.day)
    end
    Timecop.travel(23.hours.from_now) do
      assert_equal o, BasicModel.find_using_email_token(o.email_token, 1.day)
    end
  end
  
  def test_find_using_email_token_custom_expiration
    # The CustomExpiration class calls email_token_valid_for=.
    o = CustomExpiration.create!
    Timecop.travel(367.days.from_now) do
      assert_nil CustomExpiration.find_using_email_token(o.email_token)
    end
    Timecop.travel(364.days.from_now) do
      assert_equal o, CustomExpiration.find_using_email_token(o.email_token)
    end
  end
  
  def test_find_using_email_token_with_invalid_token
    o = BasicModel.create!
    assert_nil BasicModel.find_using_email_token('InvalidToken')
  end
  
  def test_find_using_email_token_bang_raises_if_not_found
    assert_raises(ActiveRecord::RecordNotFound) do
      BasicModel.find_using_email_token! 'InvalidToken'
    end
  end
  
  def test_reset_email_token
    Authlogic::Random.expects(:friendly_token).returns('IMvEDB6NJIm5Z7cSe2a')
    o = BasicModel.new
    t = Time.now
    Timecop.freeze(t) do
      o.reset_email_token
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t, o.email_token_updated_at
      assert o.new_record?
    end
  end
  
  def test_reset_email_token!
    Authlogic::Random.expects(:friendly_token).returns('IMvEDB6NJIm5Z7cSe2a')
    o = BasicModel.new
    t = Time.now
    Timecop.freeze(t) do
      o.reset_email_token!
      assert_equal 'IMvEDB6NJIm5Z7cSe2a', o.email_token
      assert_equal t, o.email_token_updated_at
      assert o.persisted?
    end
  end
end