require 'fog'
require 'yaml'
require 'logging'
require_relative 'models.rb'

class Environment
  include ResultModule
  
  attr_reader :username, :apikey, :images_list
  attr_accessor :servers, :service, :lb, :lb_service 
  attr_reader :logger, :configuration
  
  def initialize(config_file = nil, logger = nil)
    if logger
      @logger = logger
    else 
      @logger = Logging.logger('logger.log')
      @logger.level = :debug
    end

    @configuration = config_file ? config_file : config
    @logger.debug "Config file: #{@config}"
    @username = @configuration['user'] 
    @apikey = @configuration['key']
    @images_list = ["repose_test_image_with_auth","repose_test_image_without_auth", "repose_test_auth_image"]
    @servers = []

  end
 
  def connect(region)
    @service = Fog::Compute.new({
        :provider => 'Rackspace',
        :rackspace_username => @username,
        :rackspace_api_key => @apikey,
        :version => :v2,
        :rackspace_region => region,
        :connection_options => {} 
    })

    @logger.info "connected to service #{@service.inspect}"

    @service.servers.each do |server|
      @servers << server
    end
  end 

  def custom_images
    @service.images.find_all {|image| image.name =~ /repose/ }
  end

  #spins up servers in potentially multiple regions
 
  def spin_up_servers(number_of_servers = 1, name = "repose", ram_size_in_gb = "4GB", region_list = :dfw, local_auth = false, port=80)
    flavor = @service.flavors.find {
      |flavor| 
      flavor.name =~ /#{Regexp.escape(ram_size_in_gb)}/
    }
    image = @service.images.find {
      |image|
      image.name =~ /repose/
    }
    created_servers = []
    number_of_servers.times do |index|
      server = create(index,name,flavor.id,image.id)
      if server.state == 'ERROR'
        server = create(index, name, flavor.id,image.id)
      end
      @servers << server  
      created_servers << server      
    end
    load_balance(region_list, created_servers, port, name) if number_of_servers > 1
  end

  def create(index, name, flavor_id, image_id)
    logger.info "spinning up server #{name}-#{index} with flavor #{flavor_id} and image #{image_id}"
    @service.servers.bootstrap(:name => "repose_pt_#{name}_#{index}", :flavor_id => flavor_id, :image_id => image_id, :public_key_path => '~/.ssh/id_rsa.pub', :private_key_path => '~/.ssh/id_rsa')
  end

  def load_balance_connect(region)
    @lb_service = Fog::Rackspace::LoadBalancers.new({
      :rackspace_username => @username,
      :rackspace_api_key => @apikey,
      :rackspace_region => region
    })
    @logger.info "connected to load balance service #{@lb_service.inspect}"
    @lb_service
  end

  
  def load_balance(region, servers, port = 80, name) 
    load_balance_connect region
    repose_nodes = []  
    origin_nodes = []  

    servers.each do |server|
      repose_nodes << {:address => server.ipv4_address, :port => 7070, :condition => 'ENABLED'}
      origin_nodes << {:address => server.ipv4_address, :port => 8080, :condition => 'ENABLED'}
    end

    @logger.info "Create load balancer with repose"

    load_balancer = @lb_service.load_balancers.create :name => "repose_lb_#{name}_withrepose",
      :protocol => 'HTTP',
      :port => 80,
      :virtual_ips => [{:type => 'PUBLIC'}],
      :nodes => repose_nodes

    @lb = load_balancer.virtual_ips.find { |ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }

    @logger.info "Load balancer created - #{load_balancer.inspect}"
    @logger.info "Load balance vips - #{@lb.inspect}" 

    @logger.info "Create load balancer without repose"

    load_balancer = @lb_service.load_balancers.create :name => "repose_lb_withoutrepose",
      :protocol => 'HTTP',
      :port => 80,
      :virtual_ips => [{:type => 'PUBLIC'}],
      :nodes => origin_nodes

    @lb = load_balancer.virtual_ips.find { |ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }

    @logger.info "Load balancer created - #{load_balancer.inspect}"
    @logger.info "Load balance vips - #{@lb.inspect}" 
    @lb
  end
  
  def tear_down(name)
    @service.servers.each do |server| 
       test = server.name =~ /#{Regexp.escape(name)}/
       @logger.info "remove server: #{server.name} if #{test}"
       server.destroy if server.name =~ /#{Regexp.escape(name)}/
    end
    @lb_service.load_balancers.each do |lb|  
      if lb.name =~ /#{Regexp.escape(name)}/
        lb.destroy
      end
    end
    @logger.info "everything is killed."
  end
end
