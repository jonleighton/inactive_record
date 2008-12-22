module InactiveRecord::Base
  def self.included(klass)
    klass.send(:extend, ClassMethods)
    klass.send(:include, InactiveRecord::DelegateAttr)
  end
  
  module ClassMethods
    # This method is deprecated in rails, but still used by, for example, error_messages_for
    def human_attribute_name(attribute_key_name)
      attribute_key_name.humanize
    end
    
    def create(params = {})
      obj = new(params)
      obj.save && obj
    end
    
    def create!(params = {})
      obj = new(params)
      obj.save! && obj
    end
  end
  
  def initialize(params = {})
    self.attributes = params
  end
  
  def attributes=(params)
    params.each_pair do |attr_name, attr_value|
      send("#{attr_name}=", attr_value)
    end
  end
  
  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end
  
  def valid?
    errors.clear
    add_delegated_attribute_errors_to(errors)
    errors.empty?
  end
  
  # Implement your own save semantics here. This method should return true if the save
  # is successful, and false otherwise
  def save
    raise NotImplementedError, "#{self.class}#save not implemented"
  end
  
  def save!
    if save
      true
    else
      raise InactiveRecord::RecordInvalid.new(self)
    end
  end
  
  # id is nil by default. This prevents the deprecated Object#id being called, which will
  # raise a warning
  def id
    nil
  end
end
