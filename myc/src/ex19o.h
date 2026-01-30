#ifndef _object_h
#define _object_h
#include <stddef.h>
typedef enum {
    NORTH, SOUTH, EAST, WEST
} Direction;

typedef struct {
    char *description;
    int (*init)(void *self);
    void (*describe)(void *self);
    void (*destroy)(void *self);
    void *(*move)(void *self, Direction direction);
    int (*attack)(void *self, int damage);
} Object;

int Object_init(void *self);
void Object_destroy(void *self);
void Object_describe(void *self);
void *Object_move(void *self, Direction direction);
int Object_attack(void *self, int damage);
void *Object_new(size_t size, Object proto, char *description);

struct Monster {
    Object proto;
    int hit_points;
};
typedef struct Monster Monster;
struct Room {
    Object proto;

    Monster *bad_guy;

    struct Room *north;
    struct Room *south;
    struct Room *east;
    struct Room *west;
};

typedef struct Room Room;
struct Map {
    Object proto;
    Room *start;
    Room *location;
};
typedef struct Map Map;
int process_input(Map *game);


int Monster_attack(void *self, int damage);
int Monster_init(void *self);


void *Room_move(void *self, Direction direction);
int Room_attack(void *self, int damage);
int Room_init(void *self);

void *Map_move(void *self, Direction direction);
int Map_attack(void *self, int damage);
int Map_init(void *self);

void *Map_move(void *self, Direction direction);
int Map_attack(void *self, int damage);
extern Object RoomProto;

int Monster_attack(void *self, int damage);
int Monster_init(void *self);
extern Object MonsterProto;

void *Map_move(void *self, Direction direction);
int Map_attack(void *self, int damage);
int Map_init(void *self);
extern Object MapProto;

#define NEW(T, N) Object_new(sizeof(T), T##Proto, N)
#define _(N) proto.N

#endif
