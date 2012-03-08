class Delegate < ActiveRecord::Base
  belongs_to :delegator, :class_name => "User"
  belongs_to :delegatee, :class_name => "User"
end
