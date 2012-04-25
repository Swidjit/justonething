module SharedDecorations

  extend ActiveSupport::Concern

  module ClassMethods
    def linkifies_all_in(*attributes)
      linkifies_profiles_in(attributes)
      linkifies_tags_in(attributes)
      attributes.each do |attr|
        define_method "linkified_#{attr}" do
          if model.send(attr.to_sym).present?
            new_text = model.send(attr.to_sym)
            new_text = linkify_profiles(new_text)
            new_text = linkify_tags(new_text)
          end
        end
      end
    end

    def linkifies_profiles_in(*attributes)
      attributes.each do |attr|
        define_method "#{attr}_with_linkified_tags" do
          if model.send(attr.to_sym).present?
            linkify_profiles(model.send(attr.to_sym))
          end
        end
      end
    end

    def linkifies_tags_in(*attributes)
      attributes.each do |attr|
        define_method "#{attr}_with_linkified_tags" do
          if model.send(attr.to_sym).present?
            linkify_tags(model.send(attr.to_sym))
          end
        end
      end
    end
  end

  def linkify_profiles(text_chunk)
    regex = /(?<start_of_string>\s|^)@(?<display_name>[a-zA-Z0-9-]+)/
    new_text = text_chunk.gsub(regex) do |profile_link|
      display_name = profile_link[regex, :display_name]
      "#{$~[:start_of_string]}#{h.link_to( "@#{display_name}", h.profile_path(:display_name => display_name), :class => 'no-text-dec' )}"
    end
    h.sanitize new_text, :tags => 'a'
  end

  def linkify_tags(text_chunk)
    regex = /(?<start_of_string>\s|^)#(?<tag_name>[a-zA-Z0-9-]+)/
    new_text = text_chunk.gsub(regex)do |hash_tag|
      tag_name = hash_tag[regex, :tag_name]
      "#{$~[:start_of_string]}#{h.link_to( "##{tag_name}", h.main_feeds_path(:type => 'all', :tag_name => tag_name.downcase), :class => 'no-text-dec' )}"
    end
    h.sanitize new_text, :tags => 'a'
  end
end
