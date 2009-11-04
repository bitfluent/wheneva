require 'test_helper'

class <%= class_name %>ControllerTest < ActionController::TestCase
<% if actions.include?("index") -%>
  context 'GET to index' do
    setup { get :index }

    should_render_template :index
    should_respond_with    :success
  end

<% end -%>
<% if actions.include?("new") -%>
  context 'GET to new' do
    setup { get :new }

    should_assign_to       :<%= resource %>
    should_render_template :new
    should_respond_with    :success
  end

<% end -%>
<% if actions.include?("create") -%>
  context 'POST to create with valid parameters' do
    setup do
      post :create, :<%= resource %> => Factory.attributes_for(:<%= resource %>)
    end

    should_set_the_flash_to /created/i
    should_redirect_to('<%= resources %> index') { <%= resources %>_path }
  end

<% end -%>
<% if actions.include?("show") -%>
  context 'GET to show for existing <%= resource %>' do
    setup do
      @<%= resource %> = Factory(:<%= resource %>)
      <%= resource_class %>.stubs(:find).returns(@<%= resource %>)
      get :show, :id => @<%= resource %>.to_param
    end

    should 'find <%= resource %>' do
      assert_received(<%= resource_class %>, :find) do |expects|
        expects.with(@<%= resource %>.to_param)
      end
    end

    should_render_template :show
    should_respond_with    :success
  end

<% end -%>
<% if actions.include?("edit") -%>
  context 'GET to edit for existing <%= resource %>' do
    setup do
      @<%= resource %> = Factory(:<%= resource %>)
      <%= resource_class %>.stubs(:find).returns(@<%= resource %>)
      get :edit, :id => @<%= resource %>.to_param
    end

    should 'find <%= resource %>' do
      assert_received(<%= resource_class %>, :find) do |expects|
        expects.with(@<%= resource %>.to_param)
      end
    end

    should_render_template :edit
    should_respond_with    :success
  end

<% end -%>
<% if actions.include?("update") -%>
  context 'PUT to update for existing <%= resource %>' do
    setup do
      @<%= resource %> = Factory(:<%= resource %>)
      put :update, :id => @<%= resource %>.to_param,
        :<%= resource %> => Factory.attributes_for(:<%= resource %>)
    end

    should_set_the_flash_to /updated/i
    should_redirect_to('<%= resources %> index') { <%= resources %>_path }
  end

<% end -%>
<% if actions.include?("destroy") -%>
  context 'given a <%= resource %>' do
    setup { @<%= resource %> = Factory(:<%= resource %>) }

    context 'DELETE to destroy' do
      setup { delete :destroy, :id => @<%= resource %>.to_param }

      should_set_the_flash_to /deleted/i
      should_redirect_to('<%= resources %> index') { <%= resources %>_path }
    end
  end

<% end -%>
end

