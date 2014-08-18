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
    lambda do |*targs|
      if targs.size != tests.size # short circuit any testing if the airity doesn't match
        return false
      elsif targs.size > 0 # when the airity matches and there are arguments run the tests
        test = true;
        param_test_pairs = targs.zip(tests)
        param_test_pairs.each {|pair| if (pair[1].nil? or (pair[1].call(pair[0]) == false)); test = false; break; end; }
        return test
      elsif tests.size == 0 # When arguments given are empty and the tests array is empty
        return true
      else # When the arguments given are empty but the tests array is Not empty
        return false
      end
    end
  end

  def self.dispatch_clone(dispatch)
    dispatch.keys.inject({}) {|nd,key| nd[key] = dispatch[key].clone; nd } if dispatch
  end

  def self.inherited(klass,subklass)
    subklass.instance_variable_set(:@defmatch_dispatch_info,Defmatch.dispatch_clone(klass.instance_variable_get(:@defmatch_dispatch_info)))
    subklass.instance_variable_set(:@defclassmatch_dispatch_info,Defmatch.dispatch_clone(klass.instance_variable_get(:@defclassmatch_dispatch_info)))
  end

  def inherited(subklass)
    Defmatch.inherited(self,subklass)
  end

  def defmatch(method,*args,&block)
    @defmatch_dispatch_info ||= {} # setup the methods in an instance variable
    @defmatch_dispatch_info[method] ||= [] # setup the ordered array for the method the first time
    # add the hash for the test proc and the run proc (block given) to the list of matchers
    @defmatch_dispatch_info[method] << {
      :test => Defmatch.signiture_match(method,args),
      :block => block}

    # define dispatch method the first time
    unless self.instance_methods.include?(method)
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

  # Lost of duplication between this and defmatch, but the rule is 1,2,n and we haven't hit n
  def defclassmatch(method,*args,&block)
    @defclassmatch_dispatch_info ||= {} # setup the methods in an instance variable
    @defclassmatch_dispatch_info[method] ||= [] # setup the ordered array for the method the first time
    @defclassmatch_dispatch_info[method] << {:test => Defmatch.signiture_match(method,args), :block => block} # add the hash for the test proc and the run proc (block given) to the list of matchers

    # define dispatch method the first time
    unless respond_to?(method)
      eigenclass = class << self; self; end
      eigenclass.instance_eval do
        define_method(method) do |*args|
          self.instance_variable_get(:@defclassmatch_dispatch_info)[method].each do |hash|
            if hash[:test].call(*args)
              return self.instance_exec(*args,&hash[:block])
            end
          end
          raise ArgumentError, "No function clause matching arguments"
        end
      end
    end
  end

end
