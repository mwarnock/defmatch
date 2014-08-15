# Defmatch

Switching between erlang and ruby a fair amount has me missing erlang's function definition features. Particularly dispatching based on pattern matching. In erlang it's common to write a function that handles both a single item or a list of those items like this:

```erlang
times_two(List) when is_list(List) ->
  [times_two(I) || I <- List]; %% This is a basic list comprehension (think collect if you're a ruby person)
times_two(I) when is_number(I) ->
  I * 2.

times_two(4). % Returns 8
times_two([1,2,3,4]). % Returns [2,4,6,8]
times_two("asdf"). % Throws a bad match (function clause) error
```

To do the same type of operation in ruby I'd have to write something like this:

```ruby
def times_two(number_or_list)
  if number_or_list.class == Fixnum
    number_or_list * 2
  elsif number_or_list.class == Array
    number_or_list.collect(&:times_two)
  else
    throw "Not a valid argument type"
  end
end
```

Functionally these two are identical, but from a readability stand point I'd take erlang's version every time; even more so when this type of dispatching gets really complicated.

So how would you write the same thing using Defmatch?

```ruby
class TestMe
  extend(Defmatch)

  defmatch(:times,Fixnum) {|num| num * 2 }
  defmatch(:times,Array) {|list| list.collect {|i| times(i) } }
end

x = TestMe.new
x.times(4) # -> 8
x.times([1,2,3,4]) # -> [2,4,6,8]
```

## How does it work and how do I use it?
Defmatch is written as a module and when it's used to extend a class it creates a ```defmatch``` class method. The ```defmatch``` method takes one required argument as the name of the method you're defining. The remaining arguments are the pattern to match on when calling that method. Those arguments can be classes, literals, or procedures (lambdas). It also requires a block which is the actual function body that will run when the pattern matches. Those with a java background will find this similar to method overloading, but more powerful. Those with an erlang background will feel right at home. Here are some concrete examples.

```ruby
class TestMe
  extend(Defmatch)

  # Run this function if the argument passed to magic is of type Fixnum
  defmatch(:magic,Fixnum) {|number| "I got a number #{number}" }
  # Run this function if the argument passed to magic is of type Array
  defmatch(:magic,Array) {|a| "I got an Array #{a.inspect}" }
  # Run this function if the argument passed to magic is the symbol :literally
  defmatch(:magic,:literally) {|duh| "This literally matched #{duh}" }
  # Run this function when there are two fixnums passed to magic
  defmatch(:magic,Fixnum,Fixnum) {|a,b| "Found two numbers #{a}:#{b}" }
  # Run this function when there is a single argument that is equal to "banana" (not a great example as this could be done with a literal)
  defmatch(:magic,lambda {|arg| arg == "banana" }) {|arg| "I matched using a procedure that made sure \"banana\" == #{arg}" }
  # Run this function with no arguments
  defmatch(:magic) { "nifty" }
end

#Now you have an instance method called magic that dispatches what runs based on the patterns you defined and their associated block
x = TestMe.new
x.magic(10) # -> Matches the first
x.magic([1,2,3]) # -> Matches the second
x.magic(:literally) # -> You get the idea
x.magic(2,3)
x.magic("banana")
x.magic()
```

This can come in very handy, but remember that the order in which you define things matters. Lets say I define my magic function like this:

```ruby
  #...
  defmatch(:magic,Fixnum) {|num| num * 2 }
  defmatch(:magic,1) {|num| "I got me a 1" }
  #...
```

Even if I run ```x.magic(1)``` I will get ```2``` as the result. The second defmatch will never be matched because there is a more general match case above it. Order matters. Define your most specific matches first.

If you want to create class methods (yes there are no true class methods in ruby, but it's a convient definition) you can use the ```defclassmatch``` method. It works just like ```defmatch``` but makes a class method instead.

## Roadmap

* Add parameter deconstruction
* Add it to the Kernel so it's available without having to include things. This will require ruby 2.0 and I'm not prepared to kill backwards compatability yet.
