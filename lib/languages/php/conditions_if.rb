class Code_parser::Language::Php
  def condition_if(args = {})
    conds = []
    
    if match = self.matchclear(/\A\s*\$(#{@regex_varname})\s+==/)
      var_name = match[1]
      type = :equals
      
      if self.match(/\A\s*("|')/)
        str_def = self.variable_match_string
        
        cond_def = Code_parser::Condition.new(
          :type => type,
          :from => {:type => :var, :var_name => var_name},
          :to => {:type => :string, :str => str_def}
        )
        
        conds << cond_def
      else
        raise "Could not figure out what was next in the if-condition variables: #{@cont}"
      end
      
      if self.matchclear(/\A\s*\)\s*{\s*/)
        block = Code_parser::Block.new
        condition_group = Code_parser::Condition_group.new(
          :conditions => conds
        )
        condition_if = Code_parser::Condition_if.new(
          :group => condition_group,
          :block => block
        )
        
        @cur_block.actions << condition_if
        @blocks << block
        @cur_block = @blocks.last
      else
        raise "Could not figure out what comes after the condition: #{@cont}"
      end
    else
      raise "Could not figure out what was next in the if-condition: #{@cont}"
    end
  end
end