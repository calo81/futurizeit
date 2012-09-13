(just in JRuby) This gem allows to execute Ruby methods in background futures, calling the future's get only when some method of the returned object is needed.

This is an example from the specs included in the source code:
```ruby
class Futurized
  def do_something_long
    sleep 3
    "Done!"
  end
end

  before(:all) do
    Futurizeit::futurize(Futurized, :do_something_long)
  end


  it "should increase performance a lot parallelizing work" do
    object1 = Futurized.new
    object2 = Futurized.new
    object3 = Futurized.new
    start_time = Time.now.sec
    value1 = object1.do_something_long
    value2 = object2.do_something_long
    value3 = object3.do_something_long
    value1.to_s.should == 'Done!'
    value2.to_s.should == 'Done!'
    value3.to_s.should == 'Done!'
    end_time = Time.now.sec
    (end_time - start_time).should < 4
  end
```
  
  You can see how it works. We futurize the method we want to be asynchrnous and then, just when we need the value (when we call value.to_s in the example) internally the future.get is called. This allow independent methods to be executed in parallel transparently, blocking, if needed as if the background task hasn't yet finalized, only when accessing the values