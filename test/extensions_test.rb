require File.dirname(__FILE__) + '/helper'

describe 'Registering extensions' do
  module FooExtensions
    def foo
    end

    private
      def im_hiding_in_ur_foos
      end
  end

  module BarExtensions
    def bar
    end
  end

  module BazExtensions
    def baz
    end
  end

  module QuuxExtensions
    def quux
    end
  end

  it 'will add the methods to the DSL for the class in which you register them and its subclasses' do
    Sinatra::Base.register FooExtensions
    assert Sinatra::Base.respond_to?(:foo)

    Sinatra::Default.register BarExtensions
    assert Sinatra::Default.respond_to?(:bar)
    assert Sinatra::Default.respond_to?(:foo)
    assert !Sinatra::Base.respond_to?(:bar)
  end

  it 'allows extending by passing a block' do
    Sinatra::Base.register {
      def im_in_ur_anonymous_module; end
    }
    assert Sinatra::Base.respond_to?(:im_in_ur_anonymous_module)
  end

  it 'will make sure any public methods added via Default#register are delegated to Sinatra::Delegator' do
    Sinatra::Default.register FooExtensions
    assert Sinatra::Delegator.private_instance_methods.include?("foo")
    assert !Sinatra::Delegator.private_instance_methods.include?("im_hiding_in_ur_foos")
  end

  it 'will not delegate methods on Base#register' do
    Sinatra::Base.register QuuxExtensions
    assert !Sinatra::Delegator.private_instance_methods.include?("quux")
  end

  it 'will extend the Sinatra::Default application by default' do
    Sinatra.register BazExtensions
    assert !Sinatra::Base.respond_to?(:baz)
    assert Sinatra::Default.respond_to?(:baz)
  end
end
