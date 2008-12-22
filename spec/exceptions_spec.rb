require File.dirname(__FILE__) + "/spec_helper"

describe InactiveRecord::RecordInvalid, "initialized with a record" do
  before do
    @record = stub("record")
    @error = InactiveRecord::RecordInvalid.new(@record)
  end
  
  it "should have that record as an accessor" do
    @error.record.should == @record
  end
end
