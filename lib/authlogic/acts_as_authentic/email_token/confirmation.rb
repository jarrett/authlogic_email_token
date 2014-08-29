# This module is an optional part of the authlogic_email_token gem. It provides some
# standard logic for confirming email addresses.
# 
# Include this module in your +User+ model and add a +new_email+ column to the +users+
# table:
# 
#   add_column :users, :new_email, :string, null: true, after: :email
# 
# You can then use the +new_email+ attribute in your account settings form like so:
# 
#   <%= form_for current_user do |f| %>
#     <% if f.object.email_change_unconfirmed? %>
#       <div>
#         Your email address (<%= f.object.new_email %>) has not been confirmed yet. In the
#         meantime, emails will continue to be sent to <%= f.object.email %>.
#       </div>
#     <% end %>
#   
#     <div>
#       <%= f.label 'Email address:' %>
#       <%= f.text_field :new_email %>
#     </div>
#   <% end %>
# 
# 

module Authlogic::ActsAsAuthentic::EmailToken::Confirmation
  
  # Call this when you have verified the user's email address. (Typically, as a result of
  # the user clicking the link in a confirmation email.)
  # 
  # Sets +email+ to +new_email+ and +new_email+ to nil, if appropriate. Resets
  # the +email_token+.
  # 
  # You can use this for at least two purposes:
  # 
  # * verifying changes of address for existing accounts; and
  # * verifying new accounts.
  # 
  # For the latter purpose, this method looks for a method called +activate+, and if it
  # exists, calls it. (Or a method of a different name, if you configured
  # +activation_method+.)
  def confirm_email
    send(self.class.activation_method) if respond_to?(self.class.activation_method)
    if new_email.present?
      self.email = new_email
      self.new_email = nil
    end
    reset_email_token
  end
  
  def confirm_email!
    confirm_email
    save_without_session_maintenance(validate: false)
  end
  
  # Returns true if and only if:
  # 
  #   * +email+ changed during the previous save; or
  #   * +new_email+ changed during the previous save.
  def email_changed_previously?
    (previous_changes.has_key?(:email) and previous_changes[:email][1].present?) or
    (previous_changes.has_key?(:new_email) and previous_changes[:new_email][1].present?)
  end
  
  # Returns true if and only if new_email != email. Should only ever be true when user
  # changes email address. When user creates new account and activation is pending, this
  # is not true.
  def email_change_unconfirmed?
    read_attribute(:new_email).present? and (read_attribute(:new_email) != email)
  end
  
  # Sends a confirmation message if and only if +#email_changed_previously?+ returns true.
  # (In other words, if +#email+ or +#new_email+ changed on the last save.)
  # 
  # By default, this methods assumes that the following method exists:
  # 
  #   UserMailer.email_confirmation(user, controller)
  # 
  # If you don't like that, you can override it by providing a block to this method. E.g.:
  # 
  #   # This would be in a controller action, so self refers to the controller.
  #   user.maybe_deliver_email_confirmation!(self) do
  #     MyOtherMailer.whatever_message(user).deliver
  #   end
  # 
  # Recommended usage looks something like this:
  #
  #   class UsersController < ApplicationController
  #     def create
  #       @user = User.new user_params
  #       if @user.save
  #         @user.maybe_deliver_email_confirmation! self
  #         redirect_to root_url, notice: 'Confirmation email sent.'
  #       else
  #         render action: :new
  #       end
  #     end
  #     
  #     def update
  #       if current_user.update_attributes user_params
  #         if current_user.maybe_deliver_email_confirmation! self
  #           redirect_to(edit_user_url, notice: 'Confirmation email sent.'
  #         else
  #           redirect_to edit_user_url, notice: 'Account settings saved.'
  #         end
  #       else
  #         render action: 'edit'
  #       end
  #     end
  #   end
  def maybe_deliver_email_confirmation!(controller)
    if email_changed_previously?
      reset_email_token!
      if block_given?
        yield
      else
        UserMailer.email_confirmation(self, controller).deliver
      end
      true
    else
      false
    end
  end
  
  # Returns the contents of the +new_email+ column. Or, if that column is blank, returns
  # the contents of the +email+ column instead. Designed to be called from an account
  # settings form, e.g.:
  # 
  #   <%= f.text_field :new_email %>
  def new_email
    e = read_attribute :new_email
    e.present? ? e : email
  end
end