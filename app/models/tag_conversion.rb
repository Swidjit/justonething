module TagConversion
  extend ActiveSupport::Concern
  included do
  
    before_validation :convert_tag_list_to_tags
    attr_accessor :tag_list, :geo_tag_list
    
    private
    
    def convert_tag_list_to_tags
      convert_tags
      convert_geo_tags
    end
    
    def auto_tag_field
      # name of field on model that you want to scan for matches with existing tags
      # override on model
    end

    def convert_tags
      self.tags = []
      temp_tags = []
      tag_list.split(',').map{|t| temp_tags << Tag.find_or_initialize_by_name(t.strip.downcase)} if tag_list.present?
      if auto_tag_field.present?
        self.auto_tag_field.scan(/(\s|^)#([a-zA-Z0-9-]+)/) do |tag|
          unless tag[1].strip.match(/^\d+$/)
            temp_tags << Tag.find_or_initialize_by_name(tag[1].strip.downcase)
          end
        end
      end
      if temp_tags.reject{|tag| tag.valid? }.any?
        self.tag_list = temp_tags.uniq.map(&:name).join(',') #ensure we carry over any from the desc
        self.errors.add(:tags, 'must begin with a letter and can only contain letters, numbers, and hyphens')
      else
        self.tags = temp_tags.uniq
      end
    end

    def convert_geo_tags
      self.geo_tags = []
      temp_geo_tags = []
      geo_tag_list.split(',').map{|t| temp_geo_tags << GeoTag.find_or_initialize_by_name(t.strip.downcase)} if geo_tag_list.present?

      if temp_geo_tags.reject{|tag| tag.valid? }.any?
        self.errors.add(:geo_tags, 'must begin with a letter and can only contain letters, numbers, and hyphens')
      else
        self.geo_tags = temp_geo_tags.uniq
      end
    end

  
  end
end