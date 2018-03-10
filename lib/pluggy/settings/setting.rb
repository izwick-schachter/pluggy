module Pluggy
  class Settings
    class Setting
      attr_reader :name, :validation, :value

      def initialize(setting, locked: false, &validation)
        setting = setting.to_a[0]
        @name = setting[0]
        @value = setting[1]
        @locked = locked
        @value.freeze if @locked
        @initial_value = value.freeze
        @validation = block_given? ? validation : proc { true }
      end

      def value=(new_val)
        warn "The #{@name} setting has been locked" if @locked
        @value = new_val if !@locked && @validation.call(new_val)
      end

      def reset
        @value = @initial_value
      end

      def method_missing(method_name, *args, &block)
        @value.respond_to?(method_name) ? @value.method(m).call(*args, &block) : super
      end

      def respond_to_missing?(method_name, *args, &block)
        @value.respond_to?(method_name) || super
      end
    end
  end
end
