require File.dirname(__FILE__) + "/spec_helper"

describe "an instance of a class which includes InactiveRecord::DelegateAttr, " +
         "delegates its 'foo' and 'bar' attributes to 'sam', " +
         "and delegates it 'baz' attribute to 'harry' with a prefix" do
  before do
    @klass = Class.new
    @klass.class_eval do
      include InactiveRecord::DelegateAttr
      delegate_attr :foo, :bar, :to => :sam
      delegate_attr :baz, :to => :harry, :prefix => true
    end
    @object = @klass.new
    
    @sam, @harry = stub, stub
    @object.stubs(:sam).returns(@sam)
    @object.stubs(:harry).returns(@harry)
  end
  
  it "should have public getters and setter methods 'foo', 'bar' and 'harry_baz'" do
    ["foo", "bar", "harry_baz"].each do |meth|
      @klass.public_method_defined?(meth).should == true
      @klass.public_method_defined?("#{meth}=").should == true
    end
  end
  
  it "should return sam.foo when asked for foo" do
    foo = stub
    @sam.stubs(:foo).returns(foo)
    @object.foo.should == foo
  end
  
  it "should assign to sam.foo when asked to assign to foo" do
    foo = stub
    @sam.expects(:foo=).with(foo)
    @object.foo = foo
  end
  
  it "should return harry.baz when asked for harry_baz" do
    baz = stub
    @harry.stubs(:baz).returns(baz)
    @object.harry_baz.should == baz
  end
  
  it "should assign to harry.baz when asked to assign to harry_baz" do
    baz = stub
    @harry.expects(:baz=).with(baz)
    @object.harry_baz = baz
  end
  
  it "should validate each of the records attributes are delegated to, " + 
     "and then copy their errors to the given errors object, " +
     "when asked to add delegated attribute errors to an errors object" do
    @sam.expects(:valid?)
    @harry.expects(:valid?)
    
    # Can I just say that the fact ActiveRecord::Errors#on can return nil, a string, or
    # an array is completely fucking stupid.
    @sam.stubs(:errors).returns(
      :foo => nil,
      :bar => "should be a hiphopopotamus"
    )
    @harry.stubs(:errors).returns(
      :baz => ["should dance", "should not sing"]
    )
    
    errors = stub
    errors.expects(:add).with("bar", "should be a hiphopopotamus")
    errors.expects(:add).with("harry_baz", "should dance")
    errors.expects(:add).with("harry_baz", "should not sing")
    
    @object.add_delegated_attribute_errors_to(errors)
  end
end
