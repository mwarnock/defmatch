module Defmatch

  def self.signiture_match(method,args)
    tests = args.collect do |arg|
      if arg.class == Proc
        arg
      else
        lambda {|param| param.class == arg }
      end
    end
    lambda do |*args|
      test = true;
      param_test_pairs = args.zip(tests)
      param_test_pairs.each {|pair| if pair[1].call(pair[0]) == false; test = false; break; end; }
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
           return hash[:block].call(self,*args)
          end
        end
        throw "No function clause matching arguments" #This should be a real Exception
      end
    end

  end

end

# Need to turn this into legit test suite and this whole thing into a gem
class Monkey
  extend(Defmatch)

  defmatch(:times,Fixnum) {|instance,num| num * 2 }
  defmatch(:times,Array) {|instance,list| list.collect {|i| instance.times(i) } } #how do I refer to the instance method in this context?
  defmatch(:times,lambda {|asdf| asdf == :asdf }) {|instance,asdf| puts asdf }
end

# defmatch(:times,Array) {|list| list.collect {|i| self.times(i) } }
# defmatch(:times,Fixnum) {|num| num * 2 }
# self.times(2) => 4
# self.times([1,2,3,4]) => [2,4,6,8]
x = Monkey.new
x.times(4)
x.times([1,2,3,4])
x.times(:asdf)
