# Authlogic Email Token

This Authlogic extension sends confirmation emails when a user signs up and when an
existing user changes her address.

## RDOC

[rdoc.info](http://rdoc.info/github/jarrett/authlogic_email_token/master/index)

## Installation

Add this to your `Gemfile`:

    gem 'authlogic_email_token'

### Migration

Add some columns to your user model.

    def change
      add_column :users, :new_email, :string, after: :email
      add_column :users, :email_token, :string, after: :perishable_token
      add_column :users, :email_token_updated_at, :datetime, after: :email_token
      # Technically the :activated column isn't necessary. This gem doesn't access it
      # directly. Instead, it calls User#activate, which you must implement.
      # (See below.)
      add_column :users, :activated, :boolean, after: :id, null: false, default: false
    end

### User Model

Configure your user model and add an `activate` method.
  
    class User
      acts_as_authentic
      include Authlogic::ActsAsAuthentic::EmailToken::Confirmation
      
      # This method can do anything you want. This gem only cares that the activate
      # method exists, not what it does. The simplest option is to set a boolean field to
      # true, as we do here. Also, the name of the activation method is configurable if
      # you don't like calling it activate. See "Configuration" below.
      def activate
        self.activated = true
      end
    end

### Session Model
	
When the user tries to log in, ensure her account has been activated.
	
    class UserSession < Authlogic::Session::Base
      validate :must_be_activated
  
      private
  
      def must_be_activated
        if attempted_record and !attempted_record.activated
          errors.add(:activation, 'You have not yet activated your account.')
        end
      end
    end

### Controller

Add a `confirm_email` action. Call `.maybe_deliver_email_confirmation!`.

    class UsersController < ApplicationController
      def confirm_email
        if user = User.find_using_email_token(params[:token], 5.days)
          was_unactivated = !user.activated
          user.confirm_email!
          UserSession.create(user)
          if was_unactivated
            redirect_to root_url, notice: 'Your account has been activated.'
          else
            redirect_to root_url, notice: 'Your email address has been confirmed.'
          end
        else
          render action: :bad_confirmation_email
        end
      end
      
      def create
        @user = User.new user_params
        if @user.save
          @user.maybe_deliver_email_confirmation! self
          redirect_to root_url, notice: 'Confirmation email sent.'
        else
          render action: :new
        end
      end
      
      def update
        if current_user.update_attributes user_params
          if current_user.maybe_deliver_email_confirmation! self
            redirect_to root_url, notice: 'Confirmation email sent.'
          else
            redirect_to root_url, notice: 'Account settings saved.'
          end
        else
          render action: 'edit'
        end
      end
    end

### Mailer

Implement the following mailer method:

    UserMailer.email_confirmation(user, controller)

In other words, create a class called `UserMailer`. Give it a method called
`email_confirmation` that takes a user and a controller. Authlogic Email Token looks for
that class and method. If you don't like that default, you can
[override it](http://rdoc.info/github/jarrett/authlogic_email_token/master/Authlogic/ActsAsAuthentic/EmailToken/Confirmation#maybe_deliver_email_confirmation!-instance_method).

Whatever email you send should contain a link to `UsersController#confirm_email`, and
should have the user's `email_token` in the params. For example, in the mailer:

    def email_confirmation(user, controller)
      @url = controller.confirm_email_url user.email_token
      # #new_email defaults to #email if new_email column is blank. So this works for both
      # signup and changing address.
      mail to: user.new_email, subject: 'Confirm your email address'
    end

And in the email template:
    
    <p>Activate your account:</p>
    
    <p><%= link_to @url, @url %></p>

## Configuration

See [documentation for the `Config` module](http://rdoc.info/github/jarrett/authlogic_email_token/master/Authlogic/ActsAsAuthentic/EmailToken/Config).