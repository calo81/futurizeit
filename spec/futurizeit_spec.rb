require '../lib/futurizeit'

class Futurized
  def do_something_long
    sleep 3
    "Done!"
  end
end

class FuturizedWithModuleIncluded
  include Futurizeit
  def do_something_long
    sleep 3
    "Done!"
  end
  futurize :do_something_long
end


describe "Futurizer" do
  before(:all) do
    Futurizeit::futurize(Futurized, :do_something_long)
  end

  it "should wrap methods in futures and return correct values" do
    object = Futurized.new
    start_time = Time.now.sec
    value = object.do_something_long
    end_time = Time.now.sec
    (end_time - start_time).should < 2
    value.to_s.should == 'Done!'
  end

  it "should allow calling the value twice" do
     object = Futurized.new
     value = object.do_something_long
     value.to_s.should == 'Done!'
     value.to_s.should == 'Done!'
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

  it "should work with class including module" do
      object = FuturizedWithModuleIncluded.new
      start_time = Time.now.sec
      value = object.do_something_long
      end_time = Time.now.sec
      (end_time - start_time).should < 2
      value.to_s.should == 'Done!'
    end

  after(:all) do
    Futurizeit.executor.shutdown
  end
end