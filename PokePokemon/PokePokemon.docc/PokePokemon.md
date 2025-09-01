# ``PokePokemon``

## Story - Create iOS MVVM Architecture to display Pokemon Details

Use the poke API to display a list of Pokémon. Each list item should show:
• Pokémon Name

When the user clicks on one of the Pokémon it should display a detail view of thePokémon containing the information:
• Pokémon Name
• Pokémon Image. There is a list of images in the sprites object. We only need to see one.
• Pokémon Height

It should be planned to be able to display more details in the future.

### API Documentation: https://pokeapi.co/api/v2/ https://pokeapi.co/api/v2/limit=20&offset=20 https://pokeapi.co/api/v2/pokemon/limit=20&offset=20 
You will need to call two endpoints:

- List endpoint: https://pokeapi.co/api/v2/pokemon
``Data``:
{ "results": 
    [{
        "name":<String>",
        "url":<String>
    }]
}

- Detail endpoint: https://pokeapi.co/api/v2/pokemon/{id} - {id} can be the number or the name of the Pokémon
``Data``
{
"height":<Number>,
"id":<Number>,
"name":<String>,
"sprites":{"front_default":<String>}
}


# POKEMONS LIST

## Narrative 1

As an online user
I want the app to automatically load a list with the names of the available pokemons

### Scenario 1 - Primary course
Given the user has connectivity
When the user requests to see the list
Then the app should display a list from a remote endpoint.
Then each item in the list should display the pokemon's name.

### Scenario 2 - Error course
Given the user has connectivity
When the user requests to see the list
When the response returns an error
Then no pokemon list is displayed.
Then an error message is displayed: Sorry, the pokemons appear to be on holidays and are not available at the moment, try again later.


## Narrative 2

As an offline user
I want the app to automatically display a message: No internet connectivity.
And no pokemon list is displayed.

### Scenario 3 - Offline course
Given the user has NO connectivity
When the user requests to see the list
Then no pokemon list is displayed.
Then an error message is displayed: No internet connectivity.


Pokemon List Data examples page 1 with default offset 20.
### first page of pokemons :
{"results":[
    {"name":"bulbasaur","url":"https://pokeapi.co/api/v2/pokemon/1/"},
    {"name":"ivysaur","url":"https://pokeapi.co/api/v2/pokemon/2/"},
    {"name":"venusaur","url":"https://pokeapi.co/api/v2/pokemon/3/"},
    {"name":"charmander","url":"https://pokeapi.co/api/v2/pokemon/4/"},
    {"name":"charmeleon","url":"https://pokeapi.co/api/v2/pokemon/5/"},
    {"name":"charizard","url":"https://pokeapi.co/api/v2/pokemon/6/"},
    {"name":"squirtle","url":"https://pokeapi.co/api/v2/pokemon/7/"},
    {"name":"wartortle","url":"https://pokeapi.co/api/v2/pokemon/8/"},
    {"name":"blastoise","url":"https://pokeapi.co/api/v2/pokemon/9/"},
    {"name":"caterpie","url":"https://pokeapi.co/api/v2/pokemon/10/"},
    {"name":"metapod","url":"https://pokeapi.co/api/v2/pokemon/11/"},
    {"name":"butterfree","url":"https://pokeapi.co/api/v2/pokemon/12/"},
    {"name":"weedle","url":"https://pokeapi.co/api/v2/pokemon/13/"},
    {"name":"kakuna","url":"https://pokeapi.co/api/v2/pokemon/14/"},
    {"name":"beedrill","url":"https://pokeapi.co/api/v2/pokemon/15/"},
    {"name":"pidgey","url":"https://pokeapi.co/api/v2/pokemon/16/"},
    {"name":"pidgeotto","url":"https://pokeapi.co/api/v2/pokemon/17/"},
    {"name":"pidgeot","url":"https://pokeapi.co/api/v2/pokemon/18/"},
    {"name":"rattata","url":"https://pokeapi.co/api/v2/pokemon/19/"},
    {"name":"raticate","url":"https://pokeapi.co/api/v2/pokemon/20/"}
]}

Pokemon 4 Data example  (charmander)
{
"height":6,
"id":4,
"name":"charmander",
"sprites":{"front_default":"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png"},
"weight":85
}
