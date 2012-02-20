step "I visit a Want It I posted" do
  @want_it = Factory(:want_it, :user => @current_user)
  visit want_it_path(@want_it)
end

step 'I click delete' do
  click_link 'Delete'
end

step 'the Want It should be deleted' do
  WantIt.find_all_by_id(@want_it.id).count.should == 0
end