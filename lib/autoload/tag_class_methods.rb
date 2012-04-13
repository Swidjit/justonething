module TagClassMethods
  def self.extended(base)
    base.class_eval do
      validates :name, :presence => true, :uniqueness => true, :format => { :with => /^[0-9a-z-]+$/ }

      attr_accessible :name

      has_and_belongs_to_many :items, :uniq => true

      belongs_to :taggable, :polymorphic => true
    end
  end
end
