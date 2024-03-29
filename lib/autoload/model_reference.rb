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

      after_save :check_and_update_user_familiarity_and_send_notification

      define_method :check_and_update_user_familiarity_and_send_notification do
        referenced_names = []
        referenced_user_attributes.each do |field|
          self.send(field).scan(/@([a-zA-Z0-9]+)/) do |profile_link|
            referenced_names << profile_link[0]
          end
          field_was = self.send("#{field}_was")
          if field_was.present?
            field_was.scan(/@([a-zA-Z0-9]+)/) do |profile_link|
              referenced_names << profile_link[0]
            end
          end
        end
        if referenced_names.size > 0
          users = User.all_by_lower_display_name(referenced_names.uniq)
          user = User.find(self.user_id)
          users.each do |usr|
            UserFamiliarity.update_for(user,usr)

            notification = Notification.new
            notification.is_mention = true
            notification.notifier = self
            notification.sender = user
            notification.receiver = usr
            notification.save
          end
        end
      end
    end
  end
end