describe CalendarsController do
  
  before(:each) {
    
    @user = Factory :user
    
    # add a single event
    event = Factory(:event)
    event.start_datetime = 1.day.from_now + 18.hours
    event.end_datetime = event.start_datetime + 1.hour
    event.user = @user
    event.tag_list = 'foo'
    event.save

    # add a weekly event
    event = Factory(:event)
    event.start_datetime = 2.days.from_now + 18.hours
    event.end_datetime = event.start_datetime + 1.hour
    event.expires_on = 6.months.from_now
    event.weekly_day = 3
    event.rule = 'weekly'
    event.user = @user
    event.save
    
  }
  
  it "should show a calendar" do
    get :show
    assigns[:events].should_not be_empty
  end
  
  it "should show next week calendar" do
    get :show, date: 1.week.from_now.strftime('%Y-%m-%d')
    assigns[:events].should_not be_empty
    assigns[:user_events].should be_empty
  end
  
  it "show show user events" do
    sign_in @user
    get :show
    assigns[:user_events].should_not be_empty
  end
  
end