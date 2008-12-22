require File.dirname(__FILE__) + "/spec_helper"

describe "a class which include InactiveRecord::Base" do
  before do
    @klass = Class.new
    @klass.class_eval do
      include InactiveRecord::Base
    end
  end

  it "should also include InactiveRecord::DelegateAttr" do
    @klass.included_modules.should include(InactiveRecord::DelegateAttr)
  end
  
  it "should set the attributes with the given hash when initialized" do
    attributes = stub("attributes")
    @klass.any_instance.expects(:attributes=).with(attributes)
    @klass.new(attributes)
  end
  
  it "should humanize the given parameter when asked for the human attribute name" do
    string = "whatever"
    humanized_string = stub("humanized_string")
    string.stubs(:humanize).returns(humanized_string)
    @klass.human_attribute_name(string).should == humanized_string
  end
  
  it "should create a new instance and save it, returning the object, if successfully asked to create a new object with some attributes" do
    attributes = stub("attributes")
    object = @klass.new
    @klass.stubs(:new).with(attributes).returns(object)
    object.expects(:save).returns(true)
    
    @klass.create(attributes).should == object
  end
  
  it "should create a new instance and save it, returning false, if unsuccessfully asked to create a new object with some attributes" do
    attributes = stub("attributes")
    object = @klass.new
    @klass.stubs(:new).with(attributes).returns(object)
    object.expects(:save).returns(false)
    
    @klass.create(attributes).should == false
  end
  
  it "should create a new instance and save! it, returning the object, if asked to create! a new object with some attributes" do
    attributes = stub("attributes")
    object = @klass.new
    @klass.stubs(:new).with(attributes).returns(object)
    object.expects(:save!).returns(true)
    
    @klass.create!(attributes).should == object
  end
end

class ActiveRecord
  class Errors
  end
end

describe "an instance of a class which includes InactiveRecord::Base" do
  before do
    @klass = Class.new
    @klass.class_eval do
      include InactiveRecord::Base
    end
    @object = @klass.new
  end
  
  it "should call the assignment methods for each of the keys in the hash when the attributes are assigned" do
    @object.expects(:foo=).with("a")
    @object.expects(:bar=).with("b")
    
    @object.attributes = { :foo => "a", :bar => "b" }
  end
  
  it "should return and memoize ActiveRecord::Errors when asked for the errors" do
    errors = stub("errors")
    ActiveRecord::Errors.stubs(:new).with(@object).returns(errors)
    
    # Doing it twice assures that the memoizing happens
    @object.errors.should == errors
    @object.errors.should == errors
  end
  
  it "should clear the errors, add the delegated attribute errors, and then check if the errors are empty, when asked if it is valid" do
    errors = stub("errors")
    valid = sequence("valid")
    errors_empty = stub("errors_empty")
    @object.stubs(:errors).returns(errors)
    
    errors.expects(:clear).in_sequence(valid)
    @object.expects(:add_delegated_attribute_errors_to).with(errors).in_sequence(valid)
    errors.stubs(:empty?).returns(errors_empty).in_sequence(valid)
    
    @object.valid?.should == errors_empty
  end
  
  it "should raise a NotImplementedError when save is called" do
    lambda { @object.save }.should raise_error(NotImplementedError)
  end
  
  it "should call save and return true when save! is called and the save is successful" do
    @object.expects(:save).returns(true)
    @object.save!.should == true
  end
  
  it "should call save and raise an InactiveRecord::RecordInvalid errors when save! is called and the save is unsucessful" do
    @object.expects(:save).returns(false)
    lambda { @object.save! }.should raise_error(InactiveRecord::RecordInvalid) { |e| e.record.should == @object }
  end
  
  it "should have an id of nil" do
    @object.id.should == nil
  end
end
