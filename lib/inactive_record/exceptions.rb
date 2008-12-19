class InactiveRecord::RecordInvalid < StandardError
  attr_reader :record
  
  def initialize(record)
    @record = record
  end
end
