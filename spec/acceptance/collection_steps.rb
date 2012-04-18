step 'I click the link to Post a Collection' do
  click_link 'post_collection'
end

step 'the Collection should be posted' do
  Collection.count.should == 1
  @collection = Collection.first
  current_path.should == collection_path(@collection)
end

step "I visit a Collection I posted" do
  @collection = Factory(:collection, :user => @current_user)
  visit collection_path(@collection)
end

step 'the Collection should be deleted' do
  Collection.find_all_by_id(@collection.id).count.should == 0
end

step 'the Collection should be updated' do
  @collection.reload
  @collection.updated_at.should_not == @collection.created_at
end