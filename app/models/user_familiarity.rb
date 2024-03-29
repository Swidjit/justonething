class UserFamiliarity < ActiveRecord::Base

  belongs_to :user
  belongs_to :familiar, :class_name => 'User'

  validates_presence_of :user_id, :familiar_id, :familiarness

  validates_uniqueness_of :familiar_id, :scope => :user_id

  def self.update_all_users
    all_combos = User.select("#{User.table_name}.id AS user_id, familiar.id AS familiar_id").joins(
      "CROSS JOIN #{User.table_name} familiar").where("#{User.table_name}.id <> familiar.id")
    all_combos.each do |cmb|
      self.update_for(User.find(cmb.user_id), User.find(cmb.familiar_id))
    end
  end

  def self.update_for(user, familiar)
    return if user.id == familiar.id
    user_familiarity = UserFamiliarity.find_or_initialize_by_user_id_and_familiar_id(user.id,familiar.id)
    new_familiarness = 0

    # +10 User adds Familiar to a list
    num_lists = user.lists.joins("INNER JOIN lists_users lu ON lu.list_id = #{List.table_name}.id
      AND lu.user_id = #{familiar.id}").select("DISTINCT #{List.table_name}.id").count
    new_familiarness += (num_lists * 10)

    # +10 User mentions Familiar using @ symbol
    num_mentions_in_items = user.items.referencing(familiar).count
    num_mentions_in_recommendations = user.recommendations.referencing(familiar).count
    num_mentions_in_comments = user.comments.referencing(familiar).count

    num_total_mentions = num_mentions_in_items + num_mentions_in_recommendations + num_mentions_in_comments
    new_familiarness += (num_total_mentions * 10)

    # +6 User adds Familiar to a custom feed
    # Not implemented yet

    # +4 User shares item posted by Familiar
    # Not implemented yet

    # +4 User recommends item posted by Familiar
    num_recommends = familiar.items.joins(:recommendations).where(
      "#{Recommendation.table_name}.user_id = ?", user.id).select(
      "DISTINCT #{Item.table_name}.id").count
    new_familiarness += (num_recommends * 4)

    # +4 User bookmarks item posted by Familiar
    num_bookmarks = user.bookmarks.joins(:item).where("#{Item.table_name}.user_id = ?",familiar.id).count
    new_familiarness += (num_bookmarks * 4)

    # +2 User comments on item posted by Familiar
    num_user_comments = user.comments.joins(:item).where("#{Item.table_name}.user_id = ?", familiar.id).count
    new_familiarness += (num_user_comments * 2)

    # +1 Familiar comments on item posted by User
    num_familiar_comments = familiar.comments.joins(:item).where("#{Item.table_name}.user_id = ?", user.id).count
    new_familiarness += (num_familiar_comments * 1)

    # -20 User flags Familiar
    # Not implemented yet

    if new_familiarness != 0 || user_familiarity.persisted?
      user_familiarity.familiarness = new_familiarness
      user_familiarity.save
    end
  end

end
