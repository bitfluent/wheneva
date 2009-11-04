require File.dirname(__FILE__) + '/../spec_helper'

describe Warden::Proxy do

  before(:all) do
    load_strategies
  end

  before(:each) do
    @basic_app = lambda{|env| [200,{'Content-Type' => 'text/plain'},'OK']}
    @authd_app = lambda do |e|
      e['warden'].authenticate
      if e['warden'].authenticated?
        [200,{'Content-Type' => 'text/plain'},"OK"]
      else
        [401,{'Content-Type' => 'text/plain'},"You Fail"]
      end
    end
    @env = Rack::MockRequest.
      env_for('/', 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => 'GET')
  end # before(:each)

  describe "authentication" do

    it "should not check the authentication if it is not checked" do
      app = setup_rack(@basic_app)
      app.call(@env).first.should == 200
    end

    it "should check the authentication if it is explicity checked" do
      app = setup_rack(@authd_app)
      app.call(@env).first.should == 401
    end

    it "should not allow the request if incorrect conditions are supplied" do
      env = env_with_params("/", :foo => "bar")
      app = setup_rack(@authd_app)
      response = app.call(env)
      response.first.should == 401
    end

    it "should allow the request if the correct conditions are supplied" do
      env = env_with_params("/", :username => "fred", :password => "sekrit")
      app = setup_rack(@authd_app)
      resp = app.call(env)
      resp.first.should == 200
    end

    describe "authenticate!" do

      it "should allow authentication in my application" do
        env = env_with_params('/', :username => "fred", :password => "sekrit")
        app = lambda do |env|
          env['warden'].authenticate
          env['warden'].should be_authenticated
          env['warden.spec.strategies'].should == [:password]
          valid_response
        end
        setup_rack(app).call(env)
      end

      it "should be false in my application" do
        env = env_with_params("/", :foo => "bar")
        app = lambda do |env|
          env['warden'].authenticate
          env['warden'].should_not be_authenticated
          env['warden.spec.strategies'].should == [:password]
          valid_response
        end
        setup_rack(app).call(env)
      end

      it "should allow me to select which strategies I use in my appliction" do
        env = env_with_params("/", :foo => "bar")
        app = lambda do |env|
          env['warden'].authenticate(:failz)
          env['warden'].should_not be_authenticated
          env['warden.spec.strategies'].should == [:failz]
          valid_response
        end
        setup_rack(app).call(env)
      end

      it "should raise error on missing strategies" do
        env = env_with_params('/')
        app = lambda do |env|
          env['warden'].authenticate(:unknown)
        end
        lambda {
          setup_rack(app).call(env)
        }.should raise_error(RuntimeError, "Invalid strategy unknown")
      end

      it "should not raise error on default missing strategies if silencing" do
        env = env_with_params('/')
        app = lambda do |env|
          env['warden'].authenticate
          valid_response
        end
        lambda {
          setup_rack(app, :silence_missing_strategies => true, :default_strategies => :unknown).call(env)
        }.should_not raise_error
      end

      it "should allow me to get access to the user at warden.user." do
        env = env_with_params("/")
        app = lambda do |env|
          env['warden'].authenticate(:pass)
          env['warden'].should be_authenticated
          env['warden.spec.strategies'].should == [:pass]
          valid_response
        end
        setup_rack(app).call(env)
      end

      it "should properly sent the scope to the strategy" do
        env = env_with_params("/")
        app = lambda do |env|
          env['warden'].authenticate!(:pass, :scope => :failz)
          env['warden'].should_not be_authenticated
          env['warden.spec.strategies'].should == [:pass]
          valid_response
        end
        setup_rack(app).call(env)
      end

      it "should try multiple authentication strategies" do
        env = env_with_params("/")
        app = lambda do |env|
          env['warden'].authenticate(:password,:pass)
          env['warden'].should be_authenticated
          env['warden.spec.strategies'].should == [:password, :pass]
          valid_response
        end
        setup_rack(app).call(env)
      end

      it "should look for an active user in the session with authenticate!" do
        app = lambda do |env|
          env['rack.session']["warden.user.default.key"] = "foo as a user"
          env['warden'].authenticate!(:pass)
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        env['warden'].user.should == "foo as a user"
      end

      it "should look for an active user in the session with authenticate?" do
        app = lambda do |env|
          env['rack.session']['warden.user.foo_scope.key'] = "a foo user"
          env['warden'].authenticate(:pass, :scope => :foo_scope)
          env['warden'].authenticated?(:foo_scope)
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        env['warden'].user(:foo_scope).should == "a foo user"
      end

      it "should login 2 different users from the session" do
        app = lambda do |env|
          env['rack.session']['warden.user.foo.key'] = 'foo user'
          env['rack.session']['warden.user.bar.key'] = 'bar user'
          env['warden'].authenticate(:pass, :scope => :foo)
          env['warden'].authenticate(:pass, :scope => :bar)
          env['warden'].authenticate(:password)
          env['warden'].authenticated?(:foo).should be_true
          env['warden'].authenticated?(:bar).should be_true
          env['warden'].authenticated?.should be_false
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        env['warden'].user(:foo).should == 'foo user'
        env['warden'].user(:bar).should == 'bar user'
        env['warden'].user.should be_nil
      end
    end
  end # describe "authentication"

  describe "set user" do
    it "should store the user into the session" do
      env = env_with_params("/")
      app = lambda do |env|
        env['warden'].authenticate(:pass)
        env['warden'].should be_authenticated
        env['warden'].user.should == "Valid User"
        env['rack.session']["warden.user.default.key"].should == "Valid User"
        valid_response
      end
      setup_rack(app).call(env)
    end

    it "should not store the user if the :store option is set to false" do
      env = env_with_params("/")
      app = lambda do |e|
        env['warden'].authenticate(:pass, :store => false)
        env['warden'].should be_authenticated
        env['warden'].user.should == "Valid User"
        env['rack.session']['warden.user.default.key'].should be_nil
        valid_response
      end
      setup_rack(app).call(env)
    end
  end

  describe "get user" do
    before(:each) do
      @env['rack.session'] ||= {}
      @env['rack.session'].delete("warden.user.default.key")
    end

    it "should return nil when not logged in" do
      app = lambda do |env|
        env['warden'].user.should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should not run strategies when not logged in" do
      app = lambda do |env|
        env['warden'].user.should be_nil
        env['warden.spec.strategies'].should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
    end

    describe "previously logged in" do

      before(:each) do
        @env['rack.session']['warden.user.default.key'] = "A Previous User"
        @env['warden.spec.strategies'] = []
      end

      it "should take the user from the session when logged in" do
        app = lambda do |env|
          env['warden'].user.should == "A Previous User"
          valid_response
        end
        setup_rack(app).call(@env)
      end

      it "should not run strategies when the user exists in the session" do
        app = lambda do |env|
          env['warden'].authenticate!(:pass)
          valid_response
        end
        setup_rack(app).call(@env)
        @env['warden.spec.strategies'].should_not include(:pass)
      end
    end
  end

  describe "logout" do

    before(:each) do
      @env = env = env_with_params
      @env['rack.session'] = {"warden.user.default.key" => "default key", "warden.user.foo.key" => "foo key", :foo => "bar"}
      app = lambda do |e|
        e['warden'].logout(env['warden.spec.which_logout'])
        valid_response
      end
      @app = setup_rack(app)
    end

    it "should logout only the scoped foo user" do
      @env['warden.spec.which_logout'] = :foo
      @app.call(@env)
      @env['rack.session']['warden.user.default.key'].should == "default key"
      @env['rack.session']['warden.user.foo.key'].should be_nil
      @env['rack.session'][:foo].should == "bar"
    end

    it "should logout only the scoped default user" do
      @env['warden.spec.which_logout'] = :default
      @app.call(@env)
      @env['rack.session']['warden.user.default.key'].should be_nil
      @env['rack.session']['warden.user.foo.key'].should == "foo key"
      @env['rack.session'][:foo].should == "bar"
    end

    it "should clear the session when no argument is given to logout" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].logout
        valid_response
      end
      setup_rack(app).call(@env)
      @env['rack.session'].should be_empty
    end

    it "should clear the user when logging out" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].user.should_not be_nil
        e['warden'].logout
        e['warden'].should_not be_authenticated
        e['warden'].user.should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
      @env['warden'].user.should be_nil

    end

    it "should clear the session data when logging out" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        # debugger
        e['warden'].user.should_not be_nil
        e['warden'].session[:foo] = :bar
        e['warden'].logout
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should clear out the session by calling reset_session! so that plugins can setup their own session clearing" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].user.should_not be_nil
        e['warden'].should_receive(:reset_session!)
        e['warden'].logout
        valid_response
      end
      setup_rack(app).call(@env)
    end
  end

  describe "messages" do

    it "should allow access to the failure message" do
      failure = lambda do |e|
        [401, {"Content-Type" => "text/plain"}, [e['warden'].message]]
      end
      app = lambda do |e|
        e['warden'].authenticate! :failz
      end
      result = setup_rack(app, :failure_app => failure).call(env_with_params)
      result.last.should == ["The Fails Strategy Has Failed You"]
    end

    it "should not die when accessing a message from a source where no authentication has occured" do
      app = lambda do |e|
        [200, {"Content-Type" => "text/plain"}, [e['warden'].message]]
      end
      result = setup_rack(app).call(env_with_params)
      result[2].should == [""]
    end
  end

  describe "when all strategies are not valid?" do
    it "should return false for authenticated when there are no valid? strategies" do
     @env['rack.session'] = {}
     app = lambda do |e|
       e['warden'].authenticated?(:invalid).should be_false
     end
     setup_rack(app).call(@env)
    end

    it "should return nil for authenticate when there are no valid strategies" do
      @env['rack.session'] = {}
      app = lambda do |e|
        e['warden'].authenticate(:invalid).should be_nil
      end
      setup_rack(app).call(@env)
    end

    it "should respond with a 401 when authenticate! cannot find any valid strategies" do
      @env['rack.session'] = {}
      app = lambda do |e|
        e['warden'].authenticate!(:invalid)
      end
      result = setup_rack(app).call(@env)
      result.first.should == 401
    end

    describe "authenticated?" do
      describe "positive authentication" do
        before do
          @env['rack.session'] = {'warden.user.default.key' => 'defult_key'}
          $captures = []
        end

        it "should return true when authenticated in the session" do
          app = lambda do |e|
            e['warden'].should be_authenticated
          end
          result = setup_rack(app).call(@env)
        end

        it "should yield to a block when the block is passed and authenticated" do
          app = lambda do |e|
            e['warden'].authenticated? do
              $captures << :in_the_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == [:in_the_block]
        end

        it "should authenticate for a user in a different scope" do
          @env['rack.session'] = {'warden.user.foo.key' => 'foo_key'}
          app = lambda do |e|
            e['warden'].authenticated?(:foo) do
              $captures << :in_the_foo_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == [:in_the_foo_block]
        end
      end

      describe "negative authentication" do
        before do
          @env['rack.session'] = {'warden.foo.default.key' => 'foo_key'}
          $captures = []
        end

        it "should return false when authenticated in the session" do
          app = lambda do |e|
            e['warden'].should_not be_authenticated
          end
          result = setup_rack(app).call(@env)
        end

        it "should not yield to a block when the block is passed and authenticated" do
          app = lambda do |e|
            e['warden'].authenticated? do
              $captures << :in_the_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == []
        end

        it "should not yield for a user in a different scope" do
          app = lambda do |e|
            e['warden'].authenticated?(:bar) do
              $captures << :in_the_bar_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == []
        end
      end
    end


    describe "unauthenticated?" do
      describe "negative unauthentication" do
        before do
          @env['rack.session'] = {'warden.user.default.key' => 'defult_key'}
          $captures = []
        end

        it "should return false when authenticated in the session" do
          app = lambda do |e|
            e['warden'].should_not be_unauthenticated
          end
          result = setup_rack(app).call(@env)
        end

        it "should not yield to a block when the block is passed and authenticated" do
          app = lambda do |e|
            e['warden'].unauthenticated? do
              $captures << :in_the_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == []
        end

        it "should not yield to the block for a user in a different scope" do
          @env['rack.session'] = {'warden.user.foo.key' => 'foo_key'}
          app = lambda do |e|
            e['warden'].unauthenticated?(:foo) do
              $captures << :in_the_foo_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == []
        end
      end

      describe "positive unauthentication" do
        before do
          @env['rack.session'] = {'warden.foo.default.key' => 'foo_key'}
          $captures = []
        end

        it "should return false when unauthenticated in the session" do
          app = lambda do |e|
            e['warden'].should be_unauthenticated
          end
          result = setup_rack(app).call(@env)
        end

        it "should yield to a block when the block is passed and authenticated" do
          app = lambda do |e|
            e['warden'].unauthenticated? do
              $captures << :in_the_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == [:in_the_block]
        end

        it "should yield for a user in a different scope" do
          app = lambda do |e|
            e['warden'].unauthenticated?(:bar) do
              $captures << :in_the_bar_block
            end
          end
          setup_rack(app).call(@env)
          $captures.should == [:in_the_bar_block]
        end
      end
    end
  end

end
