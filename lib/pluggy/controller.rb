module Pluggy
  class Controller
    def params=(params)
      @params = params
    end

    def env=(env)
      @env = env
    end

    def req=(req)
      @req = req
    end

    private

    def params
      @params
    end

    def env
      @env
    end

    def req
      @req
    end
  end
end