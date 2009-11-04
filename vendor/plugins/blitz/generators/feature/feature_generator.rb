require File.join(File.dirname(__FILE__), "..", "support", "generator_helper")

class FeatureGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory 'features'
      m.directory 'features/step_definitions'
      m.directory 'features/support'

      path = File.join('features', "#{resources}.feature")
      m.template 'feature.feature', path

      path = File.join('features', 'step_definitions', "#{resources}_steps.rb")
      m.template 'step_definition.rb', path

      if actions.any?
        path = File.join('features', 'support', "paths.rb")
        m.insert_cucumber_path path, insertable_path
      end
    end
  end

  def insertable_path
   if %w(new create).any? { |action| actions.include?(action) }
     "    when /the new #{resource} page/i\n" <<
     "      new_#{resource}_path\n"
   elsif %w(edit update).any? { |action| actions.include?(action) }
     "    when /the edit \"([^\\\"]*)\" #{resource} page/i do |name|\n" <<
     "      post = #{resource_class}.find_by_name(name)\n"
     "      edit_#{resource}_path(#{resource})"
   end
  end
end

