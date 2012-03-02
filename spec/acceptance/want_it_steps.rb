step 'I click the link to Post a Want-it' do
  click_link 'post_want_it'
end

step 'I should not see a link to post a Want It' do
  page.has_selector?('#post_want_it').should == false
end

step 'I should see a link to post a Want It' do
  page.has_selector?('#post_want_it').should == true
end

step 'the Want-it should be posted' do
  WantIt.count.should == 1
  @want_it = WantIt.first
  current_path.should == want_it_path(@want_it)
end

step "I visit a Want It I posted" do
  @want_it = Factory(:want_it, :user => @current_user)
  visit want_it_path(@want_it)
end

step 'the Want It should be deleted' do
  WantIt.find_all_by_id(@want_it.id).count.should == 0
end

step 'the Want It should be updated' do
  @want_it.reload
  @want_it.updated_at.should_not == @want_it.created_at
end