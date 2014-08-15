require 'spec_helper'

describe Defmatch do

  class Tester
    extend(Defmatch)

    defmatch(:times,Fixnum) {|num| num * 2 }
    defmatch(:times,Array) {|list| list.collect {|i| times(i) } } #how do I refer to the instance method in this context?
    defmatch(:times,lambda {|asdf| asdf == :asdf }) {|asdf| :asdf }
    defmatch(:times,1) {|num| puts "this should never get run"; num }
    defmatch(:times,"matchme") {|string| "matched literal #{string}" }
    defmatch(:times,String) {|string| string*2 }
    defmatch(:times) { "no args" }

    defmatch(:scope) { self }

    defclassmatch(:cscope) { self }
  end

  it 'should create methods' do
    expect(Tester).to respond_to(:defmatch)
    expect(Tester).to respond_to(:defclassmatch)
  end

  it 'should have an instance method "times"' do
    expect(Tester.new).to respond_to(:times)
  end

  it 'should have an instance method "scope"' do
    expect(Tester.new).to respond_to(:scope)
  end

  it 'should have a class method "cscope"' do
    expect(Tester).to respond_to(:cscope)
  end

  it '\'s blocks should have the proper scope' do
    expect(Tester.cscope).to equal(Tester)
  end

  instance = Tester.new

  describe instance do

    it '\'s blocks should have the correct scope' do
      expect(instance.scope).to equal(instance)
    end

    it 'should handle an integer' do
      expect(instance.times(4)).to equal(8)
    end

    it 'should handle a list of integers' do
      expect(instance.times([1,2,3,4])).to eq([2,4,6,8])
    end

    it 'should handle a string' do
      expect(instance.times("a")).to eq("aa")
    end

    it 'should match a basic proc matcher' do
      expect(instance.times(:asdf)).to equal(:asdf)
    end

    it 'should match on literals' do
      expect(instance.times("matchme")).to eq("matched literal matchme")
    end

    it 'should match on no arguments' do
      expect(instance.times).to eq("no args")
    end

    it 'should run the first valid match based on defmatch declaration order' do
      expect(instance.times(1)).to equal(2)
      expect(instance.times("matchme")).to eq("matched literal matchme")
    end

    it 'should throw an argument error when arguments that don\'t match anything are given' do
      expect { instance.times("will","break","this") }.to raise_error(ArgumentError)
    end

  end

end
