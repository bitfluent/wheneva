require File.join(File.dirname(__FILE__), "..", "support", "generator_helper")

class HelperGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "#{class_name}Helper", "#{class_name}HelperTest"

      # Helper and test directories.
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('test/unit/helpers', class_path)

      # Helper module and test.
      m.template 'helper.rb',
                  File.join('app/helpers',
                            class_path,
                            "#{file_name}_helper.rb")

      m.template 'helper_test.rb',
                  File.join('test/unit/helpers',
                            class_path,
                            "#{file_name}_helper_test.rb")
    end
  end
end
