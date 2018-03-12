module Pluggy
  class Hooks
    def initialize
      @hooks = Hash.new { |hsh, key| hsh[key] = [] }
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName
    def register(to:, &block)
      # rubocop:enable Naming/UncommunicativeMethodParamName
      warn "No slot #{to} to hook into" unless @hooks.include? to
      @hooks[to] << block
    end

    def call_hooks(hook, *args)
      result = @hooks[hook].map { |h| h.call(*args) }
      result
    end
  end
end
