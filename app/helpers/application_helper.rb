module ApplicationHelper

  def current_decorated_user
    @current_decorated_user ||= UserDecorator.decorate current_user
  end

  def tag_cloud_for(feed_items, type_link='all')
    if feed_items.present?
      taglist = Tag.find(:all,
                          :select => 'tags.name, count(tags.name) as tag_count',
                          :conditions => ['items.id in (?)', feed_items.collect(&:id)],
                          :joins => 'INNER JOIN "items_tags" ON "items_tags"."tag_id" = "tags"."id" INNER JOIN "items" ON "items"."id" = "items_tags"."item_id"',
                          :order => 'count(tags.name) DESC, tags.name',
                          :limit => '20',
                          :group => 'tags.name')
    else
      taglist = []
    end

    html = '';
    taglist.each do |this_tag|
      html  << content_tag(:span,
                          (link_to this_tag.name, main_feeds_path(type: type_link, tag_name: this_tag.name), :id => "droplet-#{this_tag.name}"),
                          :class => 'tag_droplet')
      html << ' '.html_safe
    end

    content_tag :div, html.html_safe
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

    content_tag(:ul, tabs.join(' ').html_safe, :class=> 'tabbed_types clearfix') + content_tag(:div, '', :class => 'clear')
  end
  
  def id_from_object_name(f)
    str = f.object_name.gsub(/\[|\]/,"_").gsub('__', '_').sub(/_$/, '')
  end
  
  def slider(attributes={})
    unless attributes.nil? then
    values=attributes[:values]
    default_value=attributes[:default_value].to_s
    object=attributes[:object].to_s
    instance=attributes[:instance].to_s
    unit=attributes[:unit] || ""
    text_div_id=object + "_" + instance + "_slider_text_div"
    slider_id=object + "_" + instance + "_slider"

    concat(raw(
      "<div id=\"#{slider_id}\" class=\"slider\">
         <div class=\"handle\"></div>
       </div>"
    ))

    concat(raw(hidden_field(object, instance, :value => default_value.to_i)))
    concat(raw("<div id=\"#{text_div_id}\">" + default_value + " " + unit + "</div>"))

    js_text = <<JS3
    (function() {
      var zoom_slider = $('#{slider_id}');
      var text_div = $('#{text_div_id}');
      var hidden_item = $('#{object + "_" + instance}');
      var values=#{values.inspect};

      var values_length = values.length;
      var min=40;
      var max=200;

      var unit = Math.ceil((max - min) / values_length);
      var range = $R(min, max - unit);

      var pix_values = new Array();
      for(i=1;i<=values_length;i++){
        pix_values[i-1]=min + (unit * (i - 1));
      }

      var default_value=pix_values[#{values.index(default_value.to_i)}];

      new Control.Slider(zoom_slider.down('.handle'), zoom_slider, {
        range: range,
        sliderValue: default_value,
              increment: unit,
              values: pix_values,
        onSlide: function(value) {
                  text_div.innerHTML=values[pix_values.indexOf(value)] + " #{unit}";
                  hidden_item.value=values[pix_values.indexOf(value)];
        },
        onChange: function(value) { 
                  text_div.innerHTML=values[pix_values.indexOf(value)] + " #{unit}";
                  hidden_item.value=values[pix_values.indexOf(value)];
        }
      });
    })();

JS3
        concat(raw(javascript_tag(js_text)))
    end
  end

  def page_title
    title = []
    if defined?(@item) && @item.try(:title).present?
      title << @item.title 
    elsif @title.present?
      title << @title
    end
    title << current_city.name
    title << "Swidjit"
    title.join(' - ')
  end

  def community_list(communities)
    raise TypeError, 'communities must be an array' unless communities.is_a? Array
    return if communities.count == 0

    communities.collect do |comm|
      raise TypeError, 'item must be a community or community id' unless (comm.is_a? Community or comm.is_a? Integer)
      if comm.is_a? Community
        link_to(comm.name, url_for(comm))
      else
        c = Community.find(comm)
        link_to(c.name, url_for(c))
      end
    end.join(', ').html_safe
  end

  def category_feeds
    links = []
    links << link_to('have its', main_feeds_path(type: 'have_its'))
    links << link_to('want its', main_feeds_path(type: 'want_its'))
    links << link_to('thoughts', main_feeds_path(type: 'thoughts'))
    links << link_to('links', main_feeds_path(type: 'links'))
    links << link_to('events', main_feeds_path(type: 'events'))
    links << link_to('collections', main_feeds_path(type: 'collections'))
    ('<ul><li>'+links.join("</li><li>")+'</li></ul>').html_safe
  end

  def system_feeds
    links = []
    links << link_to('recommendations', recommendations_feeds_path)
    links << link_to('all items', main_feeds_path)
    if signed_in?
      links << link_to('familiar users', familiar_users_feeds_path)
      links << link_to('suggestions', suggested_items_feeds_path)
      links << link_to('mentions', references_user_path(current_user))
      links << link_to('inactive items', drafts_feeds_path)
      if current_user.geo_tags.present?
        links << link_to('nearby', nearby_feeds_path)
      end
    end
    ('<ul><li>'+links.join("</li>\n<li>")+'</li></ul>').html_safe
  end

  def custom_feeds
    links = [];


    ('<ul><li>'+links.join("</li>\n<li>")+'</li></ul>').html_safe.html_safe
  end

  def community_feeds
    links = []
    if signed_in?
      links << link_to('create a community', new_community_path)
      current_user.communities.each do |comm|
        links << link_to(comm.name, comm)
      end
    end
    links << link_to('all communities', communities_path)
    ('<ul><li>'+links.join("</li>\n<li>")+'</li></ul>').html_safe
  end

  def trending_tags
    links = []

    ('<ul><li>'+links.join("</li>\n<li>")+'</li></ul>').html_safe
  end

  def social_links

  end

  def posting_box
    form_tag({}, {:class => "posting-form"}) do
      haml_tag :div, :class => "field-desc" do
        haml_tag :textarea, :placeholder => 'tell us about what you have to offer, what you need, or something interesting around town...'
      end
    end
  end

  def type_filter_links
    links = []
    links << link_to('all')
    links << link_to('have-its')
    links << link_to('want-its')
    links << link_to('thoughts')
    links << link_to('events')
    links << link_to('collections')

    links.join(' | ').html_safe
  end

  def tag_filter_links
    links = []

    links.join(' ').html_safe
  end
  
end
