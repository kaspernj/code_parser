class Code_parser::Writer::Ruby
  def initialize(args)
    @args = args
  end
  
  def to_s
    str = ""
    @args[:block].actions.each do |action|
      if action.is_a?(Code_parserl)
        
      else
        raise "Unknown action: '#{action.class.name}'."
      end
    end
    
    return str
  end
end