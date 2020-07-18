class SecretFile
  attr_reader :security
  def initialize(secret_data)
    @data = secret_data
    @security = SecurityLogger.new
  end

  def data
    @security.create_log_entry
    @data
  end
end

class SecurityLogger
  attr_reader :log_entries

  def initialize
    @log_entries = 0
  end

  def create_log_entry
    @log_entries += 1
  end
end

secret = SecretFile.new('42')
puts secret.data
puts secret.security.log_entries