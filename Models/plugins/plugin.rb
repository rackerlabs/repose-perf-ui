module PluginModule
  class Plugin
    @@plugins ||= {}
    
    attr_reader :db, :fs_ip
  
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
      return @@plugins
      #return @@plugins.find_all {|p| p.supported_os_list.include?(os)}
    end
  
=begin
   add plugins with :id => class 
=end
    def self.inherited(klass)
      full_path = caller[0].partition(":")[0]
      dir_name =  File.dirname(full_path)[File.dirname(full_path).rindex('/')+1..-1]
      @@plugins[dir_name.to_sym] = [] unless @@plugins.has_key?(dir_name.to_sym)
      @@plugins[dir_name.to_sym] = klass
    end
    
    def initialize(db, fs_ip)
      @db = db
      @fs_ip = fs_ip
    end
  end
end