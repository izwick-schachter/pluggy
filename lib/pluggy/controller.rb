module Pluggy
  class Controller
    attr_writer :params, :env, :req

    private

    attr_reader :params, :env, :req
  end
end
