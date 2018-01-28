module Pluggy
  module Hook
    class << self
      def register(to:, &block)
        setup
        warn "No slot #{to} to hook into" unless @hooks.include? to
        @hooks[to] << block
      end

      def call_hooks(hook, *args)
        setup
        @hooks[hook].each { |h| h.call(*args) }
      end

      def setup
        @hooks ||= Hash.new {|hsh, key| hsh[key] = [] }
      end
    end
  end
end
