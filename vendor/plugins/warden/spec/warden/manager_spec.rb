require File.dirname(__FILE__) + '/../spec_helper'

describe Warden::Manager do

  before(:all) do
    load_strategies
  end

  it "should insert a Base object into the rack env" do
    env = env_with_params
    setup_rack(success_app).call(env)
    env["warden"].should be_an_instance_of(Warden::Proxy)
  end

  describe "user storage" do
    it "should take a user and store it in the provided session" do
      session = {}
      Warden::Manager._store_user("The User", session, "some_scope")
      session["warden.user.some_scope.key"].should == "The User"
    end
  end

  describe "thrown auth" do
    before(:each) do
      @basic_app = lambda{|env| [200,{'Content-Type' => 'text/plain'},'OK']}
      @authd_app = lambda do |e|
        if e['warden'].authenticated?
          [200,{'Content-Type' => 'text/plain'},"OK"]
        else
          [401,{'Content-Type' => 'text/plain'},"Fail From The App"]
        end
      end
      @env = Rack::MockRequest.
        env_for('/', 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => 'GET')
    end # before(:each)

    describe "Failure" do
      it "should respond with a 401 response if the strategy fails authentication" do
         env = env_with_params("/", :foo => "bar")
         app = lambda do |env|
           env['warden'].authenticate(:failz)
           throw(:warden, :action => :unauthenticated)
         end
         result = setup_rack(app, :failure_app => @fail_app).call(env)
         result.first.should == 401
      end

      it "should use the failure message given to the failure method" do
        env = env_with_params("/", {})
        app = lambda do |env|
          env['warden'].authenticate(:failz)
          throw(:warden)
        end
        result = setup_rack(app, :failure_app => @fail_app).call(env)
        result.last.should == ["You Fail!"]
      end

      it "should render the failure app when there's a failure" do
        app = lambda do |e|
          throw(:warden, :action => :unauthenticated) unless e['warden'].authenticated?(:failz)
        end
        fail_app = lambda do |e|
          [401, {"Content-Type" => "text/plain"}, ["Failure App"]]
        end
        result = setup_rack(app, :failure_app => fail_app).call(env_with_params)
        result.last.should == ["Failure App"]
      end

      it "should call failure app if warden is thrown even after successful authentication" do
        env = env_with_params("/", {})
        app = lambda do |env|
          env['warden'].authenticate(:pass)
          throw(:warden)
        end
        result = setup_rack(app, :failure_app => @fail_app).call(env)
        result.first.should == 401
        result.last.should == ["You Fail!"]
      end
    end # failure

  end

  describe "integrated strategies" do
    before(:each) do
      RAS = Warden::Strategies unless defined?(RAS)
      Warden::Strategies.clear!
      @app = setup_rack do |env|
        env['warden'].authenticate!(:foobar)
        [200, {"Content-Type" => "text/plain"}, ["Foo Is A Winna"]]
      end
    end

    describe "redirecting" do

      it "should redirect with a message" do
        RAS.add(:foobar) do
          def authenticate!
            redirect!("/foo/bar", {:foo => "bar"}, :message => "custom redirection message")
          end
        end
        result = @app.call(env_with_params)
        result[0].should == 302
        result[1]["Location"].should == "/foo/bar?foo=bar"
        result[2].should == ["custom redirection message"]
      end

      it "should redirect with a default message" do
        RAS.add(:foobar) do
          def authenticate!
            redirect!("/foo/bar", {:foo => "bar"})
          end
        end
        result = @app.call(env_with_params)
        result[0].should == 302
        result[1]['Location'].should == "/foo/bar?foo=bar"
        result[2].should == ["You are being redirected to /foo/bar?foo=bar"]
      end

      it "should redirect with a permanent redirect" do
        RAS.add(:foobar) do
          def authenticate!
            redirect!("/foo/bar", {}, :permanent => true)
          end
        end
        result = @app.call(env_with_params)
        result[0].should == 301
      end

      it "should redirect with a content type" do
        RAS.add(:foobar) do
          def authenticate!
            redirect!("/foo/bar", {:foo => "bar"}, :content_type => "text/xml")
          end
        end
        result = @app.call(env_with_params)
        result[0].should == 302
        result[1]["Location"].should == "/foo/bar?foo=bar"
        result[1]["Content-Type"].should == "text/xml"
      end

      it "should redirect with a default content type" do
        RAS.add(:foobar) do
          def authenticate!
            redirect!("/foo/bar", {:foo => "bar"})
          end
        end
        result = @app.call(env_with_params)
        result[0].should == 302
        result[1]["Location"].should == "/foo/bar?foo=bar"
        result[1]["Content-Type"].should == "text/plain"
      end
    end

    describe "failing" do
      it "should fail according to the failure app" do
        RAS.add(:foobar) do
          def authenticate!
            fail!
          end
        end
        env = env_with_params
        result = @app.call(env)
        result[0].should == 401
        result[2].should == ["You Fail!"]
        env['PATH_INFO'].should == "/unauthenticated"
      end

      it "should allow you to customize the response" do
        app = lambda do |e|
          e['warden'].custom_failure!
          [401,{'Content-Type' => 'text/plain'},["Fail From The App"]]
        end
        env = env_with_params
        result = setup_rack(app).call(env)
        result[0].should == 401
        result[2].should == ["Fail From The App"]
      end

      it "should render the failure application for a 401 if no custom_failure flag is set" do
        app = lambda do |e|
          [401,{'Content-Type' => 'text/plain'},["Fail From The App"]]
        end
        result = setup_rack(app).call(env_with_params)
        result[0].should == 401
        result[2].should == ["You Fail!"]
      end

    end # failing

    describe "custom rack response" do
      it "should return a custom rack response" do
        RAS.add(:foobar) do
          def authenticate!
            custom!([523, {"Content-Type" => "text/plain", "Custom-Header" => "foo"}, ["Custom Stuff"]])
          end
        end
        result = @app.call(env_with_params)
        result[0].should == 523
        result[1]["Custom-Header"].should == "foo"
        result[2].should == ["Custom Stuff"]
      end
    end

    describe "success" do
      it "should pass through to the application when there is success" do
        RAS.add(:foobar) do
          def authenticate!
            success!("A User")
          end
        end
        env = env_with_params
        result = @app.call(env)
        result[0].should == 200
        result[2].should == ["Foo Is A Winna"]
      end
    end
  end # integrated strategies

end
