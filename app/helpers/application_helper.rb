module ApplicationHelper

  def current_decorated_user
    @current_decorated_user ||= UserDecorator.decorate current_user
  end

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

  def truncate_on_word(text,char_len)
    return text if text.length <= char_len

    # Get text with two extra chars so we can ensure to break on word boundary
    text = text[0..(char_len+1)]
    words = text.split(/\s/)
    if words.count == 1
      text = words[0]
    else
      text = words[0..(words.count-2)].join(' ')
    end

    text + '...'
  end

  def tabbed_item_types(param_to_overwrite)
    tabs = []
    Item.classes.map{|kls| kls.pluralize }.unshift('All').each do |item_type|
      if params[param_to_overwrite.to_sym] == item_type.underscore
        tabs << content_tag(:li, link_to(item_type.titleize, '#'))
      else
        tabs << content_tag(:li, link_to(item_type.titleize, params.merge({param_to_overwrite.to_sym => item_type.underscore})))
      end
    end

    content_tag(:ul, tabs.join(' ').html_safe, :class=> 'tabbed_types') + content_tag(:div, '', :class => 'clear')
  end
end
