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

  defmatch(:times,Fixnum) {|instance,num| num * 2 }
  defmatch(:times,Array) {|instance,list| list.collect {|i| instance.times(i) } }
end

x = TestMe.new
x.times(4) # -> 8
x.times([1,2,3,4]) # -> [2,4,6,8]
```

## How does it work and how do I use it?


## Roadmap

* Add parameter deconstruction
* Add it to the Kernel so it's available without having to include things. This will require ruby 2.0 and I'm not prepared to kill backwards compatability yet.
