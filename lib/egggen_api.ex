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
    gens = ["generation-i", "generation-ii", "generation-iii", "generation-iv", "generation-v", "generation-vi", "generation-vii", "generation-viii"]
    |> Enum.drop_while(fn x -> x != gen2 end)
    |> tl()
    !(gen1 in gens)
  end
  def gen_rand_ability(pokemon, generation, hidden_ability_chance) do
    if :rand.uniform(100) < hidden_ability_chance and is_gen_lower_equal(generation, "generation-iv") and pokemon["pokemon_hidden_abilities"] != [] do
      pokemon["pokemon_hidden_abilities"]
      |> Enum.random()
    else
      pokemon["pokemon_normal_abilities"]
      |> Enum.random()
    end
  end
  def count_true_false(list) do
    if list == [] do
      {0, 0}
    else
      a = hd(list)
      b = count_true_false(tl(list))
      if a do
        {elem(b, 0) + 1, elem(b, 1)}
      else
        {elem(b, 0), elem(b, 1) + 1}
      end
    end
  end
  def gen_rand_moves(pokemon, game, egg_move_chance) do
    normal_moves = pokemon["pokemon_normal_moves"] |> Enum.filter(fn %{"game" => g} -> g == game end)
    egg_moves = pokemon["pokemon_egg_moves"] |> Enum.filter(fn %{"game" => g} -> g == game end)
    if egg_moves == [] do
      Enum.take_random(normal_moves, 4)
    end
    a = [:rand.uniform(100), :rand.uniform(100), :rand.uniform(100), :rand.uniform(100)]
    |> Enum.map(fn x -> x < egg_move_chance end)
    |> count_true_false()
    Enum.take_random(normal_moves, elem(a, 1)) ++ Enum.take_random(egg_moves, elem(a, 0))
    |> Enum.map(fn %{"name" => name, "game" => _} -> name end)
  end
  def gen_rand_species(file_data, generation) do
    file_data
    |> Enum.filter(fn %{"pokemon_gen" => x} -> is_gen_lower_equal(x, generation) end)
    |> Enum.random()
  end
  def gen_rand_gender(species) do
    genderless_pokemon = [
    "arctovish", "arctozolt", "aaltoy", "aeldum", "aronzor", "aarbink", "cryogonal", "dhelmise", "dracovish",
    "dracozolt", "falinks", "golett", "klink", "lunatone", "magnemite", "minior", "polteageist", "porygon", "rotom",
    "solrock", "staryu", "unknown", "voltorb"
    ]

    female_only_pokemon = [
        "nidoran-f", "illumise", "happiny", "kangaskhan", "smoochum", "miltank", "petilil", "vullaby", "flabébé",
        "bounsweet", "hatenna", "milcrey"
    ]

    male_only_pokemon = [
        "nidoran-m", "tyrogue", "tauros", "throh", "tawk", "rufflet", "impidimp"
    ]
    cond do
      species in genderless_pokemon -> "N"
      species in female_only_pokemon -> "F"
      species in male_only_pokemon -> "M"
      true -> Enum.random(["M", "F"])
    end
  end
  def enum_at_wrapper(enum, ind) do
    a = Enum.at(enum, ind)
    if a == nil do
      ""
    else
      a
    end
  end
  def pokemon_new(file_data, game, egg_move_chance, hidden_ability_chance, shiny_chance) do
    generation = game_to_gen(game)
    pokemon = gen_rand_species(file_data, generation)
    rand_moves = gen_rand_moves(pokemon, game, egg_move_chance)
    %{
      "Species" => pokemon["pokemon_name"],
      "Ability" => gen_rand_ability(pokemon, generation, hidden_ability_chance),
      "Gender" => gen_rand_gender(pokemon["pokemon_name"]),
      "Level" => 1,
      "isEgg" => true,
      "isShiny" => shiny_chance > :rand.uniform(100),
      "Nature" => Enum.random(["Hardy", "Lonely", "Adamant", "Naughty", "Brave", "Bold", "Docile", "Impish", "Lax", "Relaxed", "Modest", "Mild", "Bashful", "Rash", "Quiet", "Calm", "Gentle", "Careful", "Quirky", "Sassy", "Timid", "Hasty", "Jolly", "Naive", "Serious"]),
      "HP" => :rand.uniform(31),
      "Atk" => :rand.uniform(31),
      "Def" => :rand.uniform(31),
      "SpA" => :rand.uniform(31),
      "SpD" => :rand.uniform(31),
      "Spe" => :rand.uniform(31),
      "MoveOne" => enum_at_wrapper(rand_moves, 0),
      "MoveTwo" => enum_at_wrapper(rand_moves, 1),
      "MoveThree" => enum_at_wrapper(rand_moves, 2),
      "MoveFour" => enum_at_wrapper(rand_moves, 3)
    }
  end
  def gen_pokemons(numb_to_gen, game, egg_move_chance, hidden_ability_chance, shiny_chance) do
    file_data = File.read!(Application.app_dir(:egggen_api, "priv/pokemons.json")) |> Jason.decode!()
    Enum.map(0..numb_to_gen, fn _x -> pokemon_new(file_data, game, egg_move_chance, hidden_ability_chance, shiny_chance) end)
  end
end
