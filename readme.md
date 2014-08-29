## Installation

Add this to your `Gemfile`:

    gem 'authlogic_email_token'

Add two columns to your user model:

    def change
      add_column :users, :email_token, :string, null: false, after: :perishable_token
      add_column :users, :email_token_updated_at, :datetime, null: false, after: :email_token
    end