module InheritedResources

  # = has_scopes
  #
  # This module in included in your controller when has_scope is called for the
  # first time.
  #
  module HasScopeHelpers
    TRUE_VALUES = ["true", true, "1", 1] unless self.const_defined?(:TRUE_VALUES)

    protected

      # Overwrites apply to scope to implement default scope logic.
      #
      def apply_scope_to(target_object) #:nodoc:
        @current_scopes ||= {}

        self.scopes_configuration.each do |scope, options|
          next unless apply_scope_to_action?(options)
          key = options[:as]

          if params.key?(key)
            value, call_scope = params[key], true
          elsif options.key?(:default)
            value, call_scope = options[:default], true
            value = value.call(self) if value.is_a?(Proc)
          end

          if call_scope
            @current_scopes[key] = value

            if options[:boolean]
              target_object = target_object.send(scope) if TRUE_VALUES.include?(value)
            else
              target_object = target_object.send(scope, value)
            end
          end
        end

        target_object
      end

      # Given an options with :only and :except arrays, check if the scope
      # can be performed in the current action.
      #
      def apply_scope_to_action?(options) #:nodoc:
        return false unless applicable?(options[:if], true)
        return false unless applicable?(options[:unless], false)
        if options[:only].empty?
          if options[:except].empty?
            true
          else
            !options[:except].include?(action_name.to_sym)
          end
        else
          options[:only].include?(action_name.to_sym)
        end
      end

      # Evaluates the scope options :if or :unless. Returns true if the proc
      # method, or string evals to the expected value.
      #
      def applicable?(string_proc_or_symbol, expected)
        case string_proc_or_symbol
          when String
            eval(string_proc_or_symbol) == expected
          when Proc
            string_proc_or_symbol.call(self) == expected
          when Symbol
            send(string_proc_or_symbol) == expected
          else
            true
        end
      end

      # Returns the scopes used in this action.
      #
      def current_scopes
        @current_scopes || {}
      end

  end
end
