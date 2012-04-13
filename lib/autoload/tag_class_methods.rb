module TagClassMethods
  def self.extended(base)
    base.class_eval do
      validates :name, :presence => true, :format => { :with => /^[0-9a-z-]+$/ }
      validates_uniqueness_of :name, :scope => :type

      attr_accessible :name

      has_and_belongs_to_many :items, :uniq => true
    end
  end
end
