step 'I click the link to Post a Thought' do
  click_link 'post_thought'
end

step 'the Thought should be posted' do
  Thought.count.should == 1
  @thought = Thought.first
  current_path.should == thought_path(@thought)
end

step "I visit a Thought I posted" do
  @thought = Factory(:thought, :user => @current_user)
  visit thought_path(@thought)
end

step 'the Thought should be deleted' do
  Thought.find_all_by_id(@thought.id).count.should == 0
end

step 'the Thought should be updated' do
  @thought.reload
  @thought.updated_at.should_not == @thought.created_at
end