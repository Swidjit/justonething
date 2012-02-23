module ApplicationHelper

  def error_messages_for(resource)
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def expires_on_fields(f)
    expires_on_input = f.input :expires_on, :as => :string_for_radio, :input_html => {:class => 'datepicker'}
    f.input :has_expiration, :as => :radio, :label => 'Expires', :collection => { 'Never' => 0, "#{expires_on_input}".html_safe => 1 }
  end

  def tabbed_item_types(param_to_overwrite)
    tabs = []
    %w( All WantIts HaveIts Events Thoughts Links ).each do |item_type|
      if params[:action] == item_type.underscore
        tabs << item_type.titleize
      else
        tabs << link_to(item_type.titleize, params.merge({param_to_overwrite.to_sym => item_type.underscore}))
      end
    end

    tabs.join(' ').html_safe
  end
end
