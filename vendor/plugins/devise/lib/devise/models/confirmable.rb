require 'devise/hooks/confirmable'

module Devise
  module Models

    # Confirmable is responsible to verify if an account is already confirmed to
    # sign in, and to send emails with confirmation instructions.
    # Confirmation instructions are sent to the user email after creating a
    # record, after updating it's email and also when manually requested by
    # a new confirmation instruction request.
    # Whenever the user update it's email, his account is automatically unconfirmed,
    # it means it won't be able to sign in again without confirming the account
    # again through the email that was sent.
    #
    # Configuration:
    #
    #   confirm_within: the time you want the user will have to confirm it's account
    #                   without blocking his access. When confirm_within is zero, the
    #                   user won't be able to sign in without confirming. You can
    #                   use this to let your user access some features of your
    #                   application without confirming the account, but blocking it
    #                   after a certain period (ie 7 days). By default confirm_within is
    #                   zero, it means users always have to confirm to sign in.
    #
    # Examples:
    #
    #   User.find(1).confirm!      # returns true unless it's already confirmed
    #   User.find(1).confirmed?    # true/false
    #   User.find(1).send_confirmation_instructions # manually send instructions
    #   User.find(1).reset_confirmation! # reset confirmation status and send instructions
    module Confirmable

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          before_create :generate_confirmation_token
          after_create  :send_confirmation_instructions
        end
      end

      # Confirm a user by setting it's confirmed_at to actual time. If the user
      # is already confirmed, add en error to email field
      def confirm!
        unless_confirmed do
          self.confirmation_token = nil
          self.confirmed_at = Time.now
          save(false)
        end
      end

      # Verifies whether a user is confirmed or not
      def confirmed?
        !new_record? && confirmed_at?
      end

      # Send confirmation instructions by email
      def send_confirmation_instructions
        ::DeviseMailer.deliver_confirmation_instructions(self)
      end

      # Remove confirmation date and send confirmation instructions, to ensure
      # after sending these instructions the user won't be able to sign in without
      # confirming it's account
      def reset_confirmation!
        unless_confirmed do
          generate_confirmation_token
          save(false)
          send_confirmation_instructions
        end
      end

      # Verify whether a user is active to sign in or not. If the user is
      # already confirmed, it should never be blocked. Otherwise we need to
      # calculate if the confirm time has not expired for this user, in other
      # words, if the confirmation is still valid.
      def active?
        confirmed? || confirmation_period_valid?
      end

      protected

        # Checks if the confirmation for the user is within the limit time.
        # We do this by calculating if the difference between today and the
        # confirmation sent date does not exceed the confirm in time configured.
        # Confirm_in is a model configuration, must always be an integer value.
        #
        # Example:
        #
        #   # confirm_within = 1.day and confirmation_sent_at = today
        #   confirmation_period_valid?   # returns true
        #
        #   # confirm_within = 5.days and confirmation_sent_at = 4.days.ago
        #   confirmation_period_valid?   # returns true
        #
        #   # confirm_within = 5.days and confirmation_sent_at = 5.days.ago
        #   confirmation_period_valid?   # returns false
        #
        #   # confirm_within = 0.days
        #   confirmation_period_valid?   # will always return false
        #
        def confirmation_period_valid?
          confirmation_sent_at? &&
            (Time.now.utc - confirmation_sent_at.utc) < confirm_within
        end

        # Checks whether the record is confirmed or not, yielding to the block
        # if it's already confirmed, otherwise adds an error to email.
        def unless_confirmed
          unless confirmed?
            yield
          else
            errors.add(:email, :already_confirmed, :default => 'already confirmed')
            false
          end
        end

        # Generates a new random token for confirmation, and stores the time
        # this token is being generated
        def generate_confirmation_token
          self.confirmed_at = nil
          self.confirmation_token = friendly_token
          self.confirmation_sent_at = Time.now.utc
        end

      module ClassMethods

        # Attempt to find a user by it's email. If a record is found, send new
        # confirmation instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user email
        def send_confirmation_instructions(attributes={})
          confirmable = find_or_initialize_with_error_by_email(attributes[:email])
          confirmable.reset_confirmation! unless confirmable.new_record?
          confirmable
        end

        # Find a user by it's confirmation token and try to confirm it.
        # If no user is found, returns a new user with an error.
        # If the user is already confirmed, create an error for the user
        # Options must have the confirmation_token
        def confirm!(attributes={})
          confirmable = find_or_initialize_by_confirmation_token(attributes[:confirmation_token])
          if confirmable.new_record?
            confirmable.errors.add(:confirmation_token, :invalid)
          else
            confirmable.confirm!
          end
          confirmable
        end
      end

      Devise::Models.config(self, :confirm_within, 0.days)
    end
  end
end
