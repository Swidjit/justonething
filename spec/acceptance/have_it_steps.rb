step 'I click the link to Post a Have It' do
  click_link 'post_have_it'
end

step 'the Have It should be posted' do
  HaveIt.count.should == 1
  @have_it = HaveIt.first
  current_path.should == have_it_path(@have_it)
end

step "I visit a Have It I posted" do
  @have_it = Factory(:have_it, :user => @current_user)
  visit have_it_path(@have_it)
end

step 'the Have It should be deleted' do
  HaveIt.find_all_by_id(@have_it.id).count.should == 0
end

step 'the Have It should be updated' do
  @have_it.reload
  @have_it.updated_at.should_not == @have_it.created_at
end

step 'I fill out all required fields of the form for a Have It' do
  select 'New'
end