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

step 'I fill out all required fields of the form' do
  fill_in 'Description', :with => 'Basic description'
  fill_in 'Title', :with => 'Title here'
  choose 'Never'
end

step 'I change the description' do
  fill_in 'Description', :with => 'New Basic description'
end

step 'I submit the form' do
  click_button 'Post'
end

step 'I click edit' do
  click_link 'Edit'
end

step 'I click Update' do
  click_button 'Update'
end

step 'I click delete' do
  click_link 'Delete'
end
