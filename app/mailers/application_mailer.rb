# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ENV['RAILS_ENV'] == 'production'
    default from: 'noreply@circle-tree.com'
  else
    default from: 'kiichirotoyoizumi0221@gmail.com'
  end
  layout 'mailer'
end
