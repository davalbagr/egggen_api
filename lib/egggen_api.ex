defmodule EgggenApi do
  def game_to_gen("red-blue"), do: "generation-i"
  def game_to_gen("yellow"), do: "generation-i"
  def game_to_gen("gold-silver"), do: "generation-ii"
  def game_to_gen("crystal"), do: "generation-ii"
  def game_to_gen("firered-leafgreen"), do: "generation-iii"
  def game_to_gen("ruby-sapphire"), do: "generation-iii"
  def game_to_gen("emerald"), do: "generation-iii"
  def game_to_gen("platinum"), do: "generation-iv"
  def game_to_gen("diamond-pearl"), do: "generation-iv"
  def game_to_gen("heartgold-soulsilver"), do: "generation-iv"
  def game_to_gen("black-white"), do: "generation-v"
  def game_to_gen("black-2-white-2"), do: "generation-v"
  def game_to_gen("x-y"), do: "generation-vi"
  def game_to_gen("omega-ruby-alpha-sapphire"), do: "generation-vi"
  def game_to_gen("sun-moon"), do: "generation-vii"
  def game_to_gen("ultra-sun-ultra-moon"), do: "generation-vii"
  def game_to_gen("sword-shield"), do: "generation-viii"

  def is_gen_lower_equal(gen1, gen2) do
    gens = %{"generation-i" => 1, "generation-ii" => 2, "generation-iii" => 3, "generation-iv" => 4, "generation-v" => 5, "generation-vi" => 6, "generation-vii" => 7, "generation-viii" => 8}
    gens[gen1] <= gens[gen2]
  end
  def gen_rand_ability(pokemon, generation, hidden_ability_chance) do
    if is_gen_lower_equal(generation, "generation-ii") do
      0
    else
      if :rand.uniform(100) < hidden_ability_chance and !(is_gen_lower_equal(generation, "generation-iv")) and pokemon["pokemon_hidden_abilities"] != [] do
        a = pokemon["pokemon_hidden_abilities"]
        |> Enum.filter(fn %{"gen" => x} -> is_gen_lower_equal(x, generation) end)
        if a != [] do
          a
          |> Enum.random()
          |> Map.get("id")
        end
      end
      pokemon["pokemon_normal_abilities"]
      |> Enum.filter(fn %{"gen" => x} -> is_gen_lower_equal(x, generation) end)
      |> Enum.random()
      |> Map.get("id")
    end
  end

  def gen_rand_moves(pokemon, game, egg_move_chance) do
    normal_moves = pokemon["pokemon_normal_moves"] |> Enum.filter(fn %{"game" => g} -> g == game end)
    egg_moves = pokemon["pokemon_egg_moves"] |> Enum.filter(fn %{"game" => g} -> g == game end)
    if egg_moves == [] do
      Enum.take_random(normal_moves, 4)
    end
    a = [:rand.uniform(100), :rand.uniform(100), :rand.uniform(100), :rand.uniform(100)]
    |> Enum.count(fn x -> x < egg_move_chance end)
    Enum.take_random(normal_moves, 4-a) ++ Enum.take_random(egg_moves, a)
    |> Enum.map(fn %{"id" => id} -> id end)
  end
  def gen_rand_species(file_data, generation) do
    file_data
    |> Enum.filter(fn %{"pokemon_gen" => x} -> is_gen_lower_equal(x, generation) end)
    |> Enum.random()
  end
  def gen_rand_gender(species) do
    genderless_pokemon = [883, 881, 343, 374, 436, 703, 615, 781, 882, 880, 870, 622, 599, 337, 81, 774, 855, 137, 479, 338, 120, 201, 100]

    female_only_pokemon = [29, 314, 440, 115, 238, 241, 548, 629, 669, 761, 856, 868]

    male_only_pokemon = [32, 236, 128, 538, 539, 627, 859]

    cond do
      species in genderless_pokemon -> 2
      species in female_only_pokemon -> 1
      species in male_only_pokemon -> 0
      true -> Enum.random([0, 1])
    end
  end

  def pokemon_new(file_data, game, egg_move_chance, hidden_ability_chance, shiny_chance, max_ivs) do
    generation = game_to_gen(game)
    pokemon = gen_rand_species(file_data, generation)
    rand_moves = gen_rand_moves(pokemon, game, egg_move_chance)
    %{
      "Species" => pokemon["pokemon_id"],
      "Ability" => gen_rand_ability(pokemon, generation, hidden_ability_chance),
      "Gender" => gen_rand_gender(pokemon["pokemon_id"]),
      "isShiny" => shiny_chance > :rand.uniform(100),
      "Nature" => :rand.uniform(25),
      "HP" => if max_ivs do 31 else :rand.uniform(31) end,
      "Atk" => if max_ivs do 31 else :rand.uniform(31) end,
      "Def" => if max_ivs do 31 else :rand.uniform(31) end,
      "SpA" => if max_ivs do 31 else :rand.uniform(31) end,
      "SpD" => if max_ivs do 31 else :rand.uniform(31) end,
      "Spe" => if max_ivs do 31 else :rand.uniform(31) end,
      "MoveOne" => Enum.at(rand_moves, 0) |> then(fn x -> if x == nil do 0 else x end end),
      "MoveTwo" => Enum.at(rand_moves, 1) |> then(fn x -> if x == nil do 0 else x end end),
      "MoveThree" => Enum.at(rand_moves, 2) |> then(fn x -> if x == nil do 0 else x end end),
      "MoveFour" => Enum.at(rand_moves, 3) |> then(fn x -> if x == nil do 0 else x end end)
    }
  end
  def gen_pokemons(numb_to_gen, game, egg_move_chance, hidden_ability_chance, shiny_chance, max_ivs) do
    file_data = File.read!(Application.app_dir(:egggen_api, "priv/pokemons.json")) |> Jason.decode!()
    Enum.map(0..numb_to_gen, fn _x -> pokemon_new(file_data, game, egg_move_chance, hidden_ability_chance, shiny_chance, max_ivs) end)
  end
end
