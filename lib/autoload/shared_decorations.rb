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
    new_text = text_chunk.gsub(/@([a-zA-Z0-9]+)/) do |profile_link|
      display_name = profile_link[1..-1]
      h.link_to( "@#{display_name}", h.profile_path(:display_name => display_name) )
    end
    h.sanitize new_text, :tags => 'a'
  end

  def linkify_tags(text_chunk)
    new_text = text_chunk.gsub(/#([a-zA-Z0-9-]+)/) do |hash_tag|
      tag_name = hash_tag[1..-1]
      h.link_to( "##{tag_name}", h.all_feeds_path(:tag_name => tag_name.downcase) )
    end
    h.sanitize new_text, :tags => 'a'
  end
end