require 'spec_helper'

shared_examples "a referencing object" do |options|

  options[:fields].each do |field|
    it 'should update user familiarity on save and send notification to mentioned person' do
      subject = Factory(options[:factory])
      user = Factory(:user)

      subject.send("#{field}=","I know @#{user.display_name} too!")
      subject.save
      uf = UserFamiliarity.find_by_user_id_and_familiar_id(subject.user.id,user.id)
      uf.familiarness.should > 0

      user.notifications.count == 1
    end
  end
end
