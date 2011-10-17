class Code_parser::Language::Php
	def func_args(func_name)
		func_arg_count = 0
		args = []
		
		loop do
			if match = self.matchclear(/\A\$#{@regex_varname}\s*(,\s*|)/)
        def_val = nil
        def_val_has = false
        
        if def_match = self.matchclear(/\A\s*=\s*/)
          pos = ["\"", "'"]
          
          pos.each do |pos_val|
            if def_val_match = self.matchclear(/\A#{pos_val}(.+?)#{pos_val}\s*/)
              def_val = def_val_match[1]
              def_val_has = true
              break
            end
          end
        end
        
				args << {
					:name => match[1],
					:name_new => "phpvar_#{match[1]}",
					:default_value => def_val,
					:default_value_has => def_val_has
				}
			elsif match = self.matchclear(/\A\)\s*\{/)
				break
			else
				raise "Could not match function arguments: '#{@cont}'."
			end
		end
		
		funcdef = Code_parser::Function_definition.new(
      :name => func_name,
      :args => args
		)
		
		@cur_block.actions << funcdef
    @blocks << funcdef.block
    @cur_block = funcdef.block
		
		self.search_newstuff
	end
	
	def func_args_single_given
		arg_found = false
		args = []
		arg = nil
		
		loop do
			if !arg_found and match = self.matchclear(/\A\"/)
        arg = Code_parser::Argument.new(
          :type => :string,
          :value => self.match_semi
        )
        args << arg
				arg_found = true
			elsif !arg_found and match = self.matchclear(/\A\$(#{@regex_varname})/)
        arg = Code_parser::Argument.new(
          :type => :variable,
          :name => match[1]
        )
        
        if arg and arg.args[:and]
          arg.args[:and] = arg
        else
          args << arg
        end
        
				arg_found = true
			elsif arg_found and match = self.matchclear(/\A\.\s*/)
        arg.args[:and] = true
				arg_found = false
			elsif arg_found and match = self.matchclear(/\A;/)
				break
      elsif arg_found and match = self.matchclear(/\A\)\s*;/)
        break
      elsif arg_found and match = self.matchclear(/\A\s*,\s*/)
        arg_found = false
        next
			else
				raise "Could not figure out what to do parsing function arguments: '#{@cont}'."
			end
		end
		
		return args
	end
	
	def func_args_given
		arg_found = false
		args = []
		arg = nil
		
		loop do
			if !arg_found and match = self.matchclear(/\A\"/)
        args << Code_parser::Argument.new(
          :type => :string,
          :value => self.match_semi
        )
				arg_found = true
			elsif !arg_found and match = self.matchclear(/\A\$(#{@regex_varname})/)
				arg = Code_parser::Argument.new(
          :type => :variable,
          :name => match[1]
        )
        
        if arg and arg.args[:and]
          arg.args[:and] = arg
        else
          args << arg
        end
        
        arg_found = true
			elsif arg_found and match = self.matchclear(/\A\.\s*/)
				@retcont += " + "
				arg_found = false
			elsif arg_found and match = self.matchclear(/\A\)\s*;/)
				break
      elsif arg_found and match = self.matchclear(/\A\s*,\s*/)
        arg_found = false
        next
			else
				raise "Could not figure out what to do parsing arguments: '#{@cont}'."
			end
		end
		
		return args
	end
	
	def match_semi
    str = ""
		loop do
			if match = self.matchclear(/\A#{@regex_varcontent}/) and match[0].to_s.length > 0
				str += match[0]
			elsif match = self.matchclear(/\A\"/)
				break
			else
				raise "Could not figure out what to do matching semi: '#{@cont}'."
			end
		end
		
		return str
	end
end