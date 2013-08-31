module ResultModule
  def config(file_path = nil)
    if file_path && File.exists?(file_path)
      YAML.load_file(file_path) 
    else
      YAML.load_file(File.expand_path("../../config/config.yaml", __FILE__))
    end
  end
end