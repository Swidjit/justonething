step 'I click edit' do
  click_link 'Edit'
end

step 'I click Update' do
  click_button 'Update'
end

step 'the Want It should be updated' do
  @want_it.reload
  @want_it.updated_at.should_not == @want_it.created_at
end