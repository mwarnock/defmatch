module Defmatch

  def self.signiture_match(method,args)
    tests = args.collect do |arg|
      if arg.class == Proc
        arg
      elsif arg.class == Class
        lambda {|param| param.class == arg }
      else
        lambda {|param| param == arg }
      end
    end
    lambda do |*args|
      test = true;
      param_test_pairs = args.zip(tests)
      param_test_pairs.each {|pair| if (pair[1].nil? or (pair[1].call(pair[0]) == false)); test = false; break; end; }
      return test
    end
  end

  def defmatch(method,*args,&block)
    @defmatch_dispatch_info ||= {} # setup the methods in an instance variable
    @defmatch_dispatch_info[method] ||= [] # setup the ordered array for the method the first time
    @defmatch_dispatch_info[method] << {:test => Defmatch.signiture_match(method,args), :block => block} # add the hash for the test proc and the run proc (block given) to the list of matchers

    # define dispatch method the first time
    unless respond_to?(method)
      self.send(:define_method,method) do |*args|
        self.class.instance_variable_get(:@defmatch_dispatch_info)[method].each do |hash|
          if hash[:test].call(*args)
           return self.instance_exec(*args,&hash[:block])
          end
        end
        raise ArgumentError, "No function clause matching arguments"
      end
    end

  end

end

