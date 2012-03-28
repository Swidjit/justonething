require 'spec_helper'

describe Notification do
  it { should belong_to :sender }
  it { should belong_to :receiver }
  it { should belong_to :notifier }
end
