class ErrorUtility
  def self.log_and_notify(e)
    Rails.logger.error e.class
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    Raven.capture_exception(e)
  end
end
