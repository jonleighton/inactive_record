require File.dirname(__FILE__) + "/spec_helper"

class Foo
  include InactiveRecord::Base
end

describe "a class which include InactiveRecord::Base" do
  it "should also include InactiveRecord::DelegateAttr" do
    Foo.included_modules.should include(InactiveRecord::DelegateAttr)
  end
end

describe "an instance of a class which includes InactiveRecord::Base" do
  before do
    @object = Foo.new
  end
end
