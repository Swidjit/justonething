module SharedTagDecorations
  def linkifies_tags_in(attributes)
    if !attributes.is_a?(Array)
      attributes = [attributes]
    end
    attributes.each do |attr|
      define_method attr do
        if model.send(attr.to_sym).present?
          new_text = model.send(attr.to_sym).gsub(/#([a-zA-Z0-9-]+)/) do |hash_tag|
            tag_name = hash_tag[1..-1]
            link_to( "##{tag_name}", all_feeds_path(:tag_name => tag_name.downcase) )
          end
          sanitize new_text, :tags => 'a'
        end
      end
    end
  end
end