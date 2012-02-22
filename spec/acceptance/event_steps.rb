step 'I click the link to Post an Event' do
  click_link 'post_event'
end

step 'the Event should be posted' do
  Event.count.should == 1
  @event = Event.first
  current_path.should == event_path(@event)
end

step "I visit a Event I posted" do
  @event = Factory(:event, :user => @current_user)
  visit event_path(@event)
end

step 'the Event should be deleted' do
  Event.find_all_by_id(@event.id).count.should == 0
end

step 'the Event should be updated' do
  @event.reload
  @event.updated_at.should_not == @event.created_at
end

step 'I fill out all required fields of the form for an Event' do
  fill_in 'Location', :with => 'The moon'
  fill_in 'Start date', :with => '01/01/1999'
  fill_in 'Start time', :with => '12:30 pm'
  fill_in 'End date', :with => '01/01/2050'
  fill_in 'End time', :with => '12:30 pm'
end