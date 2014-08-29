module Authlogic::ActsAsAuthentic::EmailToken
  class Railtie < Rails::Railtie
    initializer 'authlogic_email_token.configure_rails_initialization' do
      ::ActiveRecord::Base.class_eval do
        include Authlogic::ActsAsAuthentic::EmailToken
      end
    end
  end
end