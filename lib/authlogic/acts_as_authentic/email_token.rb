# An extension to Authlogic for email confirmation tokens. Email confirmation tokens have
# a value (+email_token+) and a timestamp (+email_token_updated_at+). Email tokens are
# never maintained automatically. You must call +reset_email_token+ or
# +reset_email_token!+ yourself. At a minimum, you should do so:
#
# * When you send a confirmation email.
# * When the user follows the link in a confirmation email.
# 
# The internal structure of this module is based on Authlogic's own modules.
module Authlogic::ActsAsAuthentic::EmailToken
  def self.included(klass)
    klass.class_eval do
      # Every subclass of ActiveRecord::Base will have the class methods defined in the
      # Config module.
      extend Config
      
      add_acts_as_authentic_module(Methods)
    end
  end
  
  module Config
    def email_token_valid_for(value = nil)
      rw_config(:email_token_valid_for, (!value.nil? && value.to_i) || value, 10.minutes.to_i)
    end
    alias_method :email_token_valid_for=, :email_token_valid_for
    
    # Configures the name of the account activation boolean column. See
    # +Authlogic::ActsAsAuthentic::EmailToken::Confirmation#confirm_email+ for more info.
    def activation_method(value = nil)
      rw_config(:activation_method, value, :activate)
    end
    alias_method :activation_method=, :activation_method
  end
  
  module Methods
    def self.included(klass)
      # Do nothing if the email_token column is missing. If the email_token column
      # is present but not email_token_updated_at, raise.
      if !klass.column_names.map(&:to_s).include? 'email_token'
        return
      elsif !klass.column_names.map(&:to_s).include? 'email_token_updated_at'
        raise(
          ::Authlogic::ActsAsAuthentic::EmailToken::DBStructureError,
          "#{klass.name} has an email_token column but not email_token_updated_at. " +
          " You must add the latter. (Should be :datetime, null: false.)"
        )
      end
            
      klass.class_eval do
        extend ClassMethods
        include InstanceMethods
      
        # If this module is added to an existing app, the email_confirmation column will
        # initially be blank. To avoid errors upon save, we must phase in the new tokens.
        # 
        # Similarly, when new records are created, we must set these values.
        before_save ->(user) {
          if user.email_token.blank? or user.email_token_updated_at.blank?
            user.reset_email_token
          end
        }
      end
    end
    
    module ClassMethods
      # Use this method to find a record with an email confirmation token. This method
      # does 2 things for you:
      #
      # 1. It ignores blank tokens
      # 2. It enforces the +email_token_valid_for configuration+ option.
      #
      # If you want to use a different timeout value, just pass it as the second
      # parameter:
      #
      #   User.find_using_email_token(token, 1.hour)
      # 
      # This method is very similar to, and based heavily off of, Authlogic's
      # +#find_using_perishable_token+ method.
      def find_using_email_token(token, age = self.email_token_valid_for)
        return if token.blank?
        age = age.to_i
        
        # Authlogic builds its SQL by hand, but I prefer Arel. The logic is the same.
        t = arel_table
        conditions = t[:email_token].eq(token)
        if age > 0
          conditions = conditions.and(
            t[:email_token_updated_at].gt(age.seconds.ago)
          )
        end
        
        where(conditions).first
      end
      
      # This method will raise +ActiveRecord::RecordNotFound+ if no record is found.
      def find_using_email_token!(token, age = self.email_token_valid_for)
        find_using_email_token(token, age) || raise(ActiveRecord::RecordNotFound)
      end
    end
    
    module InstanceMethods  
      # Resets the email token to a random friendly token. Sets email_token_updated_at
      # to the current time.
      def reset_email_token
        self.email_token_updated_at = Time.now
        self.email_token = Authlogic::Random.friendly_token
      end
      
      # Same as reset_email_token, but then saves the record afterwards.
      def reset_email_token!
        reset_email_token
        save_without_session_maintenance(validate: false)
      end
    end
  end
  
  class DBStructureError < StandardError; end
end