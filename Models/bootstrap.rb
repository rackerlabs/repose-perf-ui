require_relative 'models.rb'
require_relative 'runner.rb'

module Models
	class Bootstrap
		include ResultModule

		def os
		  @os ||= (
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

		def runner_list
		  {
		  	:jmeter => Models::JMeterRunner.new,
		  	:pravega => Models::PravegaRunner.new,
		  	:flood => Models::FloodRunner.new,
		  	:autobench => Models::AutoBenchRunner.new
		  }
		end
	end
end
