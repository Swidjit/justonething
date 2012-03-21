require 'spec_helper'

describe Vouch do
  it { should belong_to :voucher }
  it { should belong_to :vouchee }
end
