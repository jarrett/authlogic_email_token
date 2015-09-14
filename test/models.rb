ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class ActiveRecord::ConnectionAdapters::TableDefinition
  def authlogic
    string :persistence_token
    timestamps null: true
  end
end

ActiveRecord::Schema.define(:version => 1) do
  create_table :missing_updated_ats do |t|
    t.string :email_token, null: false
    t.authlogic
  end
  
  create_table :no_email_tokens do |t|
    t.authlogic
  end
  
  create_table :basic_models do |t|
    t.string :email_token
    t.datetime :email_token_updated_at
    t.authlogic
  end
  
  create_table :custom_expirations do |t|
    t.string :email_token
    t.datetime :email_token_updated_at
    t.authlogic
  end
  
  create_table :confirmables do |t|
    t.string :email
    t.string :new_email
    t.string :email_token
    t.datetime :email_token_updated_at
    t.authlogic
  end
  
  create_table :activatables do |t|
    t.string :email
    t.string :new_email
    t.string :email_token
    t.datetime :email_token_updated_at
    t.boolean :activated, null: false, default: false
    t.authlogic
  end
  
  create_table :custom_activation_methods do |t|
    t.string :email
    t.string :new_email
    t.string :email_token
    t.datetime :email_token_updated_at
    t.boolean :activated, null: false, default: false
    t.authlogic
  end
  
  create_table :custom_mailer_class_and_methods do |t|
    t.string :email
    t.string :new_email
    t.string :email_token
    t.datetime :email_token_updated_at
    t.authlogic
  end
end

class MissingUpdatedAt < ActiveRecord::Base; end

class NoEmailToken < ActiveRecord::Base; end

class BasicModel < ActiveRecord::Base
  acts_as_authentic
end

class CustomExpiration < ActiveRecord::Base
  acts_as_authentic do |c|
    c.email_token_valid_for = 1.year
  end
end

class Confirmable < ActiveRecord::Base
  acts_as_authentic
  include Authlogic::ActsAsAuthentic::EmailToken::Confirmation
end

class Activatable < ActiveRecord::Base
  acts_as_authentic
  include Authlogic::ActsAsAuthentic::EmailToken::Confirmation
  
  def activate
    self.activated = true
  end
end

class CustomActivationMethod < ActiveRecord::Base
  acts_as_authentic do |c|
    c.activation_method = :make_active
  end
  include Authlogic::ActsAsAuthentic::EmailToken::Confirmation
  
  def make_active
    self.activated = true
  end
end

class CustomMailerClassAndMethod < ActiveRecord::Base
  acts_as_authentic do |c|
    c.confirmation_mailer_class = :CustomUserMailer
    c.confirmation_mailer_method = :custom_method
  end
  include Authlogic::ActsAsAuthentic::EmailToken::Confirmation
end

class UserMailer; end

class CustomUserMailer; end