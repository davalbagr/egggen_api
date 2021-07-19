defmodule EgggenApiWeb.Router do
  use EgggenApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EgggenApiWeb do
    pipe_through :api
    get "/:numb_to_gen/:game/:egg_move_chance/:hidden_ability_chance/:shiny_chance", EgggenController, :index
  end

  scope "/maxivs", EgggenApiWeb do
    pipe_through :api
    get "/:numb_to_gen/:game/:egg_move_chance/:hidden_ability_chance/:shiny_chance", EgggenController, :index2
  end

end
