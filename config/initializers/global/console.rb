module Console
  def self.log(msg)
    Rails.logger.info msg
  end
end