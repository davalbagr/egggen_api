defmodule EgggenApiWeb.EgggenController do
  use EgggenApiWeb, :controller

  plug :action

  def index(conn, %{"numb_to_gen" => numb_to_gen, "game" => game, "egg_move_chance" => egg_move_chance, "hidden_ability_chance" => hidden_ability_chance, "shiny_chance" => shiny_chance}) do
    pokemons = EgggenApi.gen_pokemons(String.to_integer(numb_to_gen), game, String.to_integer(egg_move_chance), String.to_integer(hidden_ability_chance), String.to_integer(shiny_chance), false)
    json(conn, pokemons)
  end

  def index2(conn, %{"numb_to_gen" => numb_to_gen, "game" => game, "egg_move_chance" => egg_move_chance, "hidden_ability_chance" => hidden_ability_chance, "shiny_chance" => shiny_chance}) do
    pokemons = EgggenApi.gen_pokemons(String.to_integer(numb_to_gen), game, String.to_integer(egg_move_chance), String.to_integer(hidden_ability_chance), String.to_integer(shiny_chance), true)
    json(conn, pokemons)
  end
end
