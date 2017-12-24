module Pluggy
  class Controller
    def params=(params)
      @params = params
    end

    def env=(env)
      @env = env
    end

    private

    def params
      @params.named_captures.map { |k,v| [k.to_sym, v] }.to_h
    end

    def env
      @env
    end
  end
end