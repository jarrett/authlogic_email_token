## Installation

Add this to your `Gemfile`:

    gem 'authlogic_email_token'

Add two columns to your user model:

    def change
      add_column :users, :email_token, :string, after: :perishable_token
      add_column :users, :email_token_updated_at, :datetime, after: :email_token
    end