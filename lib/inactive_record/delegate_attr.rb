module InactiveRecord::DelegateAttr
  def self.included(klass)
    klass.send(:extend, ClassMethods)
  end
  
  module ClassMethods
    def delegated_attrs
      @delegated_attrs ||= {}
    end
    
    def delegate_attr(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      raise ArgumentError, "you must specify the :to option" if options[:to].nil?
      
      args.each do |attr_name|
        method_name = options[:prefix] ? "#{options[:to]}_#{attr_name}" : attr_name
        
        class_eval do
          define_method method_name do
            instance_eval(options[:to].to_s).send(attr_name)
          end
          
          define_method "#{method_name}=" do |val|
            instance_eval(options[:to].to_s).send("#{attr_name}=", val)
          end
        end
        
        delegated_attrs[options[:to].to_s] ||= {}
        delegated_attrs[options[:to].to_s][method_name] = attr_name
      end
    end
  end
  
  # Add errors from the attributes which are delegated using delegate_attr to a
  # given to an ActiveRecord::Errors object
  def add_delegated_attribute_errors_to(errors)
    self.class.delegated_attrs.each_pair do |record, delegations|
      record = send(record)
      record.valid?
      
      delegations.each_pair do |from, to|
        Array(record.errors[to]).each do |error|
          errors.add(from, error)
        end
      end
    end
  end
end
