# frozen_string_literal: true

class HerokuSidekiqTestJob < ApplicationJob
  queue_as :default

  def perform
    puts 'Job成功！'
  end
end
