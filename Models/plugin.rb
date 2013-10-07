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
    @@plugins = @@plugins.find_all {|p| puts p; puts p.supported_os_list; p.supported_os_list.include?(os)}
  end

  def self.inherited(klass)
    puts klass
    @@plugins << klass
  end

end

class LinuxPerfMon < Plugin
  def self.supported_os_list
    [:linux]
  end 
  def test
    puts "fplug"
  end
end

class MacosxPerfMon < Plugin
  def self.supported_os_list
    [:macosx]
  end 
end

class Test
  def initialize
    puts "this is the load plugin list: #{Plugin.plugin_list}"
  end
end 