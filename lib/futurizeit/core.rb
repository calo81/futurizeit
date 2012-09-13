require 'java'
java_import 'java.util.concurrent.ExecutorService'
java_import 'java.util.concurrent.Executors'
java_import 'java.util.concurrent.Future'
java_import 'java.util.concurrent.TimeUnit'
java_import 'java.util.concurrent.Callable'

module Futurizeit
  module ClassMethods
    def futurize(*methods)
      Futurizeit.futurize(self, *methods)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def self.executor
    @executor ||= Executors.newFixedThreadPool(10)
  end

  def self.futurize(klass, *methods)
    klass.class_eval do
      methods.each do |method|
        alias :"non_futurized_#{method}" :"#{method}"
        define_method :"#{method}" do |*args|
          @future = Futurizeit.executor.submit(CallableRuby.new { self.send(:"non_futurized_#{method}", *args) })
          Futuwrapper.new(@future)
        end
      end
    end
  end
end

module Futurizeit
  class Futuwrapper < BasicObject
    def initialize(future)
      @future = future
    end

    def method_missing(method, *params)
      instance = @future.get
      instance.send(method, *params)
    end
  end

  class CallableRuby
    include Callable

    def initialize(&block)
      @block = block
    end

    def call
      @block.call
    end
  end
end


