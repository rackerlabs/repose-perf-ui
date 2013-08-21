require 'fog'
require 'yaml'

class Environment
  
  attr_reader :username, :apikey, :images_list
  attr_accessor :servers, :service, :lb, :lb_service 
  
  def initialize
    config = YAML.load_file("/root/repose/dist/config.yaml")
    @username = config['user'] 
    @apikey = config['key']
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
    
    p "connected to service #{@service.inspect}"

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
    load_balance(region_list, created_servers, port) if number_of_servers > 1
  end

  def create(index, name, flavor_id, image_id)
    p "spinning up server #{name}-#{index} with flavor #{flavor_id} and image #{image_id}"
    @service.servers.bootstrap(:name => "repose_pt_#{name}_#{index}", :flavor_id => flavor_id, :image_id => image_id, :public_key_path => '~/.ssh/id_rsa.pub', :private_key_path => '~/.ssh/id_rsa')
  end

  def load_balance_connect(region)
    @lb_service = Fog::Rackspace::LoadBalancers.new({
      :rackspace_username => @username,
      :rackspace_api_key => @apikey,
      :rackspace_region => region
    })
    p "connected to load balance service #{@lb_service.inspect}"
    @lb_service
  end

  
  def load_balance(region, servers, port = 80, name) 
    load_balance_connect region
    nodes = []  

    servers.each do |server|
      nodes << {:address => server.ipv4_address, :port => port, :condition => 'ENABLED'}
    end

    p "Create load balancer"

    load_balancer = @lb_service.load_balancers.create :name => "repose_lb_#{name}",
      :protocol => 'HTTP',
      :port => 80,
      :virtual_ips => [{:type => 'PUBLIC'}],
      :nodes => nodes

    @lb = load_balancer.virtual_ips.find { |ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }

    p "Load balancer created - #{load_balancer.inspect}"
    p "Load balance vips - #{@lb.inspect}" 
    @lb
  end
  
  def tear_down(name)
    @service.servers.each do |server| 
       server.destroy if server.name =~ /#{Regexp.escape(name)}/
    end
    @lb_service.load_balancers.each {|lb| lb.destroy}
    p "everything is killed."
  end
end
