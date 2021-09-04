from simplejson import dumps, loads
import aiohttp, asyncio


async def get(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return loads(await response.content.read())


async def fetch_moves(r):
    egg_moves = []
    normal_moves = []
    for i in r:
        for j in i['version_group_details']:
            if j['level_learned_at'] < 2:
                move_learn_method = j['move_learn_method']['name']
                if move_learn_method == 'egg':
                    egg_moves.append({'id': int(i['move']['url'][31:-1]), 'game': j['version_group']['name']})
                elif move_learn_method == 'level-up':
                    normal_moves.append({'id': int(i['move']['url'][31:-1]), 'game': j['version_group']['name']})
    return normal_moves, egg_moves


async def fetch_abilities(r2):
    normal_abilities = []
    hidden_abilities = []
    for abilities in r2:
        r3 = await get(abilities['ability']['url'])
        if abilities['is_hidden']:
            hidden_abilities.append(
                {'id': r3['id'], "gen": r3['generation']['name']})
        else:
            normal_abilities.append(
                {'id': r3['id'], "gen": r3['generation']['name']})

    return normal_abilities, hidden_abilities


async def fetch_pokemon(json):
    rtrnval = []
    for i in json:
        r = await get(i['url'])
        if r['evolves_from_species'] is None and not r['is_legendary'] and not r['is_mythical']:
            r2 = await get("https://pokeapi.co/api/v2/pokemon/{0}".format(r['id']))
            (normal_moves, egg_moves) = await fetch_moves(r2['moves'])
            (normal_abilities, hidden_abilities) = await fetch_abilities(r2['abilities'])
            rtrnval.append({'pokemon_id': r['id'], 'normal_moves': normal_moves,
                            'egg_moves': egg_moves, 'normal_abilities': normal_abilities,
                            'hidden_abilities': hidden_abilities, 'pokemon_gen': r['generation']['name']})
            print(r['id'])
    return rtrnval


async def main():
    json = await get("https://pokeapi.co/api/v2/pokemon-species?limit=10000")
    with open("priv/pokemons.json", "w") as f:
        pokemons = await fetch_pokemon(json['results'])
        f.write(dumps(pokemons))


if __name__ == '__main__':
    asyncio.run(main())