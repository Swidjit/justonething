step "I visit the Home Page" do
  visit root_url
end

step "I am logged in" do
  @current_user = Factory(:user, :password => 'fakepass', :password_confirmation => 'fakepass')
  visit new_user_session_path
  within '#login_form' do
    fill_in 'user_email', :with => @current_user.email
    fill_in 'user_password', :with => 'fakepass'
    click_button 'Sign in'
  end
end

step 'I click the link to Post a Want-it' do
  click_link 'post_want_it'
end

step 'I fill out all required fields of the form' do
  fill_in 'want_it_description', :with => 'Basic description'
  fill_in 'want_it_title', :with => 'Title here'
  choose '30 days'
end

step 'I submit the form' do
  click_button 'Post'
end

step 'the Want-it should be posted' do
  # TODO: Make this reflect how we want interface to act when we find out what that is
  WantIt.count.should == 1
end