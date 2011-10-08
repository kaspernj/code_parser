class Code_parser::Language::Php
	def func_args(func_name)
		func_arg_count = 0
		args = []
		
		loop do
			if match = self.matchclear(/\A\$#{@regex_varname}\s*(,\s*|)/)
				args << {
					:name => match[1],
					:name_new => "phpvar_#{match[1]}"
				}
			elsif match = self.matchclear(/\A\)\s*\{/)
				break
			else
				raise "Could not match function arguments."
			end
		end
		
		funcdef = Code_parser::Function_definition.new(
      :name => func_name,
      :args => args
		)
		
		@blocks.last.actions << funcdef
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
        arg.args[:and] = true
				arg_found = false
			elsif arg_found and match = self.matchclear(/\A;/)
				break
			else
				raise "Could not figure out what to do."
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
				@retcont += "phpvar_#{match[1]}"
				arg_found = true
			elsif arg_found and match = self.matchclear(/\A\.\s*/)
				@retcont += " + "
				arg_found = false
			elsif arg_found and match = self.matchclear(/\A\)\s*;/)
				break
			else
				raise "Could not figure out what to do."
			end
		end
		
		return args
	end
	
	def match_semi
    str = ""
		loop do
			if match = self.matchclear(/\A[A-z\d_\.]+/)
				str += match[0]
			elsif match = self.matchclear(/\A\"/)
				break
			else
				raise "Could not figure out what to do."
			end
		end
		
		return str
	end
end