module Pluggy
  # A template class for any pluggy controller. It is important because it sets
  # up the {params}, {env}, and {req} methods, for calling inside the action and
  # for caling inside the view.
  class Controller
    # Used by {Router::Route::Controller} to set the values of {params}, {env},
    # and {req}.
    attr_writer :params, :env, :req

    private

    # Sytatic sugar for easier use of these variables within the class.
    attr_reader :params, :env, :req
  end
end
