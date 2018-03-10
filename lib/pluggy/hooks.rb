module Pluggy
  module Hook
    class << self
      # rubocop:disable Naming/UncommunicativeMethodParamName
      def register(to:, &block)
        # rubocop:enable Naming/UncommunicativeMethodParamName
        warn "No slot #{to} to hook into" unless hooks.include? to
        hooks[to] << block
      end

      def call_hooks(hook, *args)
        hooks[hook].map { |h| h.call(*args) }
      end

      private

      def hooks
        @hooks ||= Hash.new { |hsh, key| hsh[key] = [] }
      end
    end
  end
end
