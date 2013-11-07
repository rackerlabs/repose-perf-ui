require 'nokogiri'
require './Models/xsd.rb'

class ChildElement
  def initialize

  end

end

class RootElement
  def initialize

  end
end

@option = {}


d = Nokogiri::XML(File.read('/Users/dimi5963/projects/repose_cleanup/project-set/components/client-ip-identity/src/main/resources/META-INF/schema/config/ip-identity-configuration.xsd'))
namespace = d.namespaces.find {|k,v| v == d.children[0].attributes['targetNamespace'].value}[0]
prefix = namespace.split(':')[1]
root_element = d.children[0].children.find {|e| e.name == 'element' }
root_name = root_element.attributes['name'].value
#puts "root name: #{root_name}"

main_element = d.children[0].children.find do |c| 
	c.attributes['name'].value == root_element.attributes['type'].value.split(':')[1] if c.attributes['name'] 
end

root_type = case 
when main_element.name == 'complexType' && !main_element.children.find {|c| c.name == 'sequence' }.nil? then 	:collection
when main_element.name == 'complexType' && !main_element.children.find_all {|c| c.name == 'all' }.nil? then 	:complex
else
	:string
end

#puts "root type: #{root_type}"

root_description = main_element.children.find {|c| c.name == 'annotation'}.children.find do |c| 
	c.name == 'documentation' 
end.children.find {|c| c.name == 'p' }.content if main_element.children.find {|c| c.name == 'annotation'}
#puts "root description: #{root_description}"


repose_main_element = XSD::Element.new(root_name,root_description,true,root_type)

puts "test: #{main_element.children.find {|c| c.name == 'all' }.nil?}"
puts "test2: #{main_element.children.find {|c| c.name == 'sequence' }.nil?}"

main_element.children.find {|c| c.name == 'all' }.children.find_all {|c| c.name == 'element' }.each do |el| 
  name = el.attributes['name'].value
  #puts "child element name: #{name}"
  element = d.children[0].children.find do |e|
    e.attributes['name'].value == el.attributes['type'].value.split(':')[1] if e.attributes['name']
  end
  type = el.attributes['type'] unless element
  #puts "type: #{type}"
  @option = {}

  collection_type = nil


  description = element.children.find {|c| c.name == 'annotation'}.children.find do |c| 
    c.name == 'documentation' 
  end.children.find {|c| c.name == 'p' }.content if element.children.find {|c| c.name == 'annotation'}
  #puts "child element description: #{description}"
  is_required = el.attributes['minOccurs'].content.to_i > 0
  #puts "is child element required: #{is_required}"
  default = el.attributes['default'].value if el.attributes['default']
  #puts "default: #{default}"

  element.children.find do |c| 
    if c.name == 'restriction'
      type = c.attributes['base'].value
      puts "type: #{type}"
      @option = {:type => nil, :value => {}}
      if c.children.any? {|d| d.name == 'minInclusive' or d.name == 'maxInclusive' }
        @option[:type] = :range
        c.children.find_all {|d| d.name == 'minInclusive' or d.name == 'maxInclusive'}.each do |d| 
		  @option[:value].merge!({ d.name.to_sym => d.attributes['value'].value })
		end
	  end
	end
  end
  
  type = case 
  when element.name == 'complexType' && !element.children.find {|c| c.name == 'sequence' }.nil? then 	:collection
  when element.name == 'complexType' && !element.children.find_all {|c| c.name == 'all' }.nil? then 	:complex
  else
    :string
  end unless type

  collection_type = element.children.find {|c| c.name == 'sequence' }.children.find {|c| c.name == 'element' } if type == :collection
  
	#puts "collection type: #{collection_type.attributes['name']}" if collection_type
	# this is to get the collection type

  element_object = XSD::Element.new(name,description,is_required,type,collection_type,default, @option)
  element_object.parent = repose_main_element
  element_object.collection_type = collection_type['name'] if collection_type
  repose_main_element.children << element_object
end
puts repose_main_element.inspect
puts repose_main_element.load

[10.23.244.82]:29418 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNgzIbF+wNwT5pHfR5CuTgVfSmi3qFvlmuiucU5hy0Pi8OhKPi+vr9aep/t7RxwYaPi2rCG/8QHAdxDtEiKCDW0uoTL0o1PmjuLtFMuMItdXt6wDSLo+RtpROCsiY9e0ZcjDqb1TR/3R6NFAa1d9yltLr+rxgmg1+YoAtwvrfMY7Jw6GY8BJfVcduiKDX7/mCs6kqhuFZyiRX9yWymAXwvIm/QsxaPiDZsYPPOBTNYMiDbtdvYwPhZsqDEFC3bTPV1SEIVPUi9KRL9TQYxkMl7qkYJ8g2VTd/7B/dRxSW6iYNRqkggeuemo3yrBhj40YIdVulGmr+5SNuxm7pRm3Ln

