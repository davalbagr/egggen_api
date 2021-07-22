import requests, json, os

def fetch_moves(r):
    normal_moves = []
    egg_moves = []
    for i in r:
        for j in i['version_group_details']:
            if j['level_learned_at'] < 2:  
                if j['move_learn_method']['name'] == 'egg':
                    egg_moves.append(
                        {'id': int(i['move']['url'][31:-1]), 'game': j['version_group']['name']})
                elif j['move_learn_method']['name'] == 'level-up':
                    normal_moves.append(
                        {'id': int(i['move']['url'][31:-1]), 'game': j['version_group']['name']})
    return normal_moves, egg_moves

def fetch_abilities(r2):
    normal_abilities = []
    hidden_abilities = []
    for i in r2:
        r3 = requests.get(i['ability']['url']).json()
        if i['is_hidden']:
            hidden_abilities.append({'id': r3['id'], "gen": r3['generation']['name']})
        else:
            normal_abilities.append({'id': r3['id'], "gen": r3['generation']['name']})
    return normal_abilities, hidden_abilities


if __name__ == '__main__':
    tmp = requests.get("https://pokeapi.co/api/v2/pokemon-species").json()
    count = tmp['count']
    pokemons = []
    for counter in range(1, count):
        r = requests.get("https://pokeapi.co/api/v2/pokemon-species/{0}".format(counter)).json()
        if r['evolves_from_species'] is None and not r['is_legendary'] and not r['is_mythical']:
            r2 = requests.get("https://pokeapi.co/api/v2/pokemon/{0}".format(r['id'])).json()
            (pokemon_normal_moves, pokemon_egg_moves) = fetch_moves(r2['moves'])
            (pokemon_normal_abilities, pokemon_hidden_abilities) = fetch_abilities(r2['abilities'])
            pokemons.append(
            {'pokemon_id': counter, 'pokemon_normal_moves': pokemon_normal_moves, 'pokemon_egg_moves': pokemon_egg_moves,
            'pokemon_normal_abilities': pokemon_normal_abilities, 'pokemon_hidden_abilities': pokemon_hidden_abilities, 'pokemon_gen': r['generation']['name']})
            print("inserted {0}".format(counter))    

    f = open("priv/pokemons2.json", "w")
    f.write(json.dumps(pokemons))
    f.close()
