defmodule EgggenApiWeb.Router do
  use EgggenApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EgggenApiWeb do
    pipe_through :api
    resources "/:numb_to_gen/:game/:egg_move_chance/:hidden_ability_chance/:shiny_chance", EgggenController
  end



end
