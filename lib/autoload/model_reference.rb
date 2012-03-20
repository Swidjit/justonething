module ModelReference

  extend ActiveSupport::Concern

  module ClassMethods

    def references_users_in(*attributes)
      referenced_user_attributes = attributes.map{|attr| attr.to_s}

      define_singleton_method :referencing do |user|
        where_clause = []
        where_params = []
        referenced_user_attributes.each do |field|
          where_clause << "lower(#{self.table_name}.#{field}) ~ ? "
          where_params << "@#{user.display_name.downcase}([^a-z0-9]|$)"
        end
        where_params.prepend(where_clause.join(' OR '))
        self.where(where_params)
      end
    end
  end
end