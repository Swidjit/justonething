module TagClassMethods
  def self.extended(base)
    base.class_eval do
      validates :name, :presence => true, :format => { :with => /(?!^\d+$)(?=^[0-9a-z-]+$)/ }
      validates_uniqueness_of :name, :scope => :type

      attr_accessible :name
    end
  end
end
