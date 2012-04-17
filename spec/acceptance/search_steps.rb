step 'I submit a search that matches an item' do
  @item = Factory(:want_it, :title => "Searchable")
  fill_in 'q', :with => "searchable"
  click_button "search"
end

step 'the search should return valid results' do
  page.find('.itemTitle a').text.should =~ /searchable/i
end
