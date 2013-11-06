# config/initializers/rabl_rails.rb
RablRails.configure do |config|
  config.include_json_root = false
  config.enable_jsonp_callbacks = true
  # These are the default
  # config.cache_templates = true  
  # config.json_engine = :oj
  # config.xml_engine = 'LibXML'
  # config.use_custom_responder = false
  # config.default_responder_template = 'show'
end