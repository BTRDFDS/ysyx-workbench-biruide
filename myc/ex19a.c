#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "object.h"

int Map_init(void *self)
{
    Map *map = self;

    // make some rooms for a small map
    Room *hall = NEW(Room, "The great Hall");
    Room *throne = NEW(Room, "The throne room");
    Room *arena = NEW(Room, "The arena, with the minotaur");
    Room *kitchen = NEW(Room, "Kitchen, you have the knife now");

    // 新增房间
    Room *dungeon = NEW(Room, "The dark dungeon, chains hang from the walls");
    Room *garden = NEW(Room, "The royal garden, flowers bloom everywhere");
    Room *library = NEW(Room, "The ancient library, books line the walls");
    Room *armory = NEW(Room, "The armory, weapons and armor are stored here");
    Room *tower = NEW(Room, "The wizard's tower, magical energy crackles in the air");
    // put the bad guy in the arena
    arena->bad_guy = NEW(Monster, "The evil minotaur");

    dungeon->bad_guy = NEW(Monster, "The dark knight");
    library->bad_guy = NEW(Monster, "The possessed librarian");
    tower->bad_guy = NEW(Monster, "The evil wizard");

    // setup the map rooms
    hall->north = throne;

    throne->west = arena;
    throne->east = kitchen;
    throne->south = hall;

    arena->east = throne;
    kitchen->west = throne;

    throne->north = library;
    library->west = tower;
    library->east = garden;
    library->south = throne;
    dungeon->south = kitchen;
    kitchen->north = dungeon;
    tower->east = library;
    garden->west = library;
    garden->south = armory;
    armory->north = garden;
    
    // start the map and the character off in the hall
    map->start = hall;
    map->location = hall;

    return 1;
}


int main(int argc, char *argv[])
{
    // simple way to setup the randomness
    srand(time(NULL));

    // make our map to work with
    Map *game = NEW(Map, "The Hall of the Minotaur.");

    printf("You enter the ");
    game->location->_(describe)(game->location);

    while(process_input(game)) {
    }

    return 0;
}
