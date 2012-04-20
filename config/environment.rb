# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Swidjit::Application.initialize!

module ActionDispatch::Routing::UrlFor
  def url_for(options = nil)
    case options
    when String
      options
    when nil, Hash
      options ||= {}
      options = options.symbolize_keys.reverse_merge!(url_options)
      if options[:controller] =~ /^admin\// || (options[:controller] == 'users' &&
          %w( references ).exclude?(options[:action])) ||
          options[:controller] == 'notifications' || options[:controller] =~ /^devise\// ||
          options[:use_route] == 'root'
        options.delete(:city_url_name)
      end
      _routes.url_for(options)
    else
      polymorphic_url(options)
    end
  end
end