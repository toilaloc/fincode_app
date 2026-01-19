# frozen_string_literal: true

class MagicLinkMailer < ApplicationMailer
  def magic_link_email(user:, magic_token:)
    @user = user
    @magic_token = magic_token
    @magic_link_url = "http://localhost:3006/verify?token=#{@magic_token}&email=#{@user.email}"

    mail(
      to: user.email,
      subject: 'Your magic sign-in link'
    )
  end
end
