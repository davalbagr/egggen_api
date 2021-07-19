import requests, json, os

first = True
def insert_pokemon(file, pokemons):
    global first
    if not first:
        file.write(',')
    else:
        first = False
    file.write(json.dumps(
        {'pokemon_id': pokemons[0], 'pokemon_normal_moves': pokemons[1], 'pokemon_egg_moves': pokemons[2],
         'pokemon_normal_abilities': pokemons[3], 'pokemon_hidden_abilities': pokemons[4], 'pokemon_gen': pokemons[5]}))
    print("inserted {0}".format(pokemons[0]))     

def parse_move_id(x):
    x = x[31:]
    return int(x[:-1])

def fetch_moves(r):
    normal_moves = []
    egg_moves = []
    counter = 0
    while True:
        try:
            r2 = r[counter]['version_group_details']
            counter2 = 0
            has_been_requested = []
            while True:
                try:
                    move_types = ['egg', 'level-up']
                    if r2[counter2]['level_learned_at'] < 2 and r2[counter2]['move_learn_method']['name'] in move_types:
                        move_id = parse_move_id(r[counter]['move']['url'])   
                        if r2[counter2]['move_learn_method']['name'] == 'egg':
                            egg_moves.append(
                                {'id': move_id, 'game': r2[counter2]['version_group']['name']})
                        else:
                            normal_moves.append(
                                {'id': move_id, 'game': r2[counter2]['version_group']['name']})
                except:
                    break
                counter2 = counter2 + 1
        except:
            break
        counter = counter + 1
    return normal_moves, egg_moves

def parse_ability_id(x):
    x = x[34:]
    return int(x[:-1])

def fetch_abilities(r2):
    normal_abilities = []
    hidden_abilities = []
    counter = 0
    while True:
        try:
            ability_id = parse_ability_id(r2[counter]['ability']['url'])
            if r2[counter]['is_hidden']:
                hidden_abilities.append({'id': ability_id, "gen": r3['generation']['name']})
            else:
                normal_abilities.append({'id': ability_id, "gen": r3['generation']['name']})
        except:
            break
        counter = counter + 1
    return normal_abilities, hidden_abilities


if __name__ == '__main__':
    if os.path.exists("priv/pokemons.json"):
        os.remove("priv/pokemons.json")
    f = open("priv/pokemons.json", "a")
    f.write('[')
    counter = 1
    while True:
        try:
            r = requests.get("https://pokeapi.co/api/v2/pokemon-species/{0}".format(counter)).json()
        except:
            break
        if r is None:
            break
        if r['evolves_from_species'] is not None or r['is_legendary'] or r['is_mythical']:
            counter = counter + 1
            continue
        try:
            r2 = requests.get("https://pokeapi.co/api/v2/pokemon/{0}".format(counter)).json()
        except:
            break
        (pokemon_normal_moves, pokemon_egg_moves) = fetch_moves(r2['moves'])
        (pokemon_normal_abilities, pokemon_hidden_abilities) = fetch_abilities(r2['abilities'])
        insert_pokemon(f, [counter, pokemon_normal_moves, pokemon_egg_moves, pokemon_normal_abilities,
                           pokemon_hidden_abilities, r['generation']['name']])
        counter = counter + 1

    f.write(']')
    f.close()