# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@fincode-testing.com'
  layout 'mailer'
end
