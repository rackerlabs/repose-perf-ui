class Plugin
  @@plugins ||= []

  def self.os
    (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
      end
    )
  end 

  def self.plugin_list
    @@plugins = @@plugins.find_all {|p| p.supported_os_list.include?(os)}
  end

  def self.inherited(klass)
    @@plugins << klass
  end
end
