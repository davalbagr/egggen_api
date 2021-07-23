defmodule Mix.Tasks.Updatejson do
  use Mix.Task

  def get_json(url) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = :httpc.request(:get, {url, []}, [], [])
    Jason.decode!(body)
  end

  def get_id(x, i) do
    x
    |> String.slice(i .. -2)
    |> String.to_integer()
  end

  def get_move(i) do
    id = get_id(i["move"]["url"], 31)
    Enum.filter(i["version_group_details"], fn x -> x["level_learned_at"] < 2 and x["move_learn_method"]["name"] in ["egg", "level-up"] end)
    |> Enum.map(fn j -> %{"id" => id, "game" => j["version_group"]["name"], "learn_method" => j["move_learn_method"]["name"]} end)
  end

  def aux_func(i, str, acc) do
    if i["learn_method"] == str do
      [%{"id" => i["id"], "game" => i["game"]} | acc]
    else
      acc
    end
  end

  def get_moves(x) do
    x = Enum.reduce(x, [], fn (i, acc) -> get_move(i) ++ acc end)
    %{"normal_moves" => Enum.reduce(x, [], fn (i, acc) -> aux_func(i, "level-up", acc) end),
     "egg_moves" => Enum.reduce(x, [], fn (i, acc) -> aux_func(i, "egg", acc) end)}
  end

  def get_ability(x, acc) do
    r = get_json(x["ability"]["url"])
    map = %{"id" => r["id"], "gen" => r["generation"]["name"]}
    if x["is_hidden"] do
      %{"normal_abilities" => acc["normal_abilities"], "hidden_abilities" => [map | acc["hidden_abilities"]]}
    else
      %{"normal_abilities" => [map | acc["normal_abilities"]], "hidden_abilities" => acc["hidden_abilities"]}
    end
  end

  def get_abilities(x) do
    Enum.reduce(x, %{"normal_abilities" => [], "hidden_abilities" => []}, fn (i, acc) -> get_ability(i, acc) end)
  end

  def get_pokemon(url, acc, total) do
    r = get_json(url)
    if r["evolves_from_species"] == nil and !(r["is_legendary"]) and !(r["is_mythical"]) do
      id = get_id(url, 42)
      r2 = get_json("https://pokeapi.co/api/v2/pokemon/#{id}")
      moves = get_moves(r2["moves"])
      abilities = get_abilities(r2["abilities"])
      ProgressBar.render(id, total)
      [%{"pokemon_id" => id, "pokemon_normal_moves" => moves["normal_moves"], "pokemon_egg_moves" => moves["egg_moves"],
            "pokemon_normal_abilities" => abilities["normal_abilities"], "pokemon_hidden_abilities" => abilities["hidden_abilities"], "pokemon_gen" => r["generation"]["name"]} | acc]
    else
      acc
    end
  end

  @shortdoc "Updates pokemon.json"
  def run(_) do
    Mix.Task.run("app.start")
    Application.ensure_all_started(:inets)
    pokemons = get_json("https://pokeapi.co/api/v2/pokemon-species?limit=1500")
    total = pokemons["count"]
    a = Enum.reduce(pokemons["results"], [], fn (i, acc) -> get_pokemon(i["url"], acc, total) end)
    |> Jason.encode!()
    File.write!(Application.app_dir(:egggen_api, "priv/pokemons.json"), a)
  end
end
