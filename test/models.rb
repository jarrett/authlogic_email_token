ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class ActiveRecord::ConnectionAdapters::TableDefinition
  def authlogic
    string :persistence_token
    timestamps
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
end

class MissingUpdatedAt < ActiveRecord::Base; end
class NoEmailToken < ActiveRecord::Base; end
class BasicModel < ActiveRecord::Base
  acts_as_authentic
end