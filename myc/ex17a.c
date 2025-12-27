#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

// #define MAX_DATA 512
// #define MAX_ROWS 100


struct Address {
    int id;
    int set;
    char *name;
    char *email;
    int phone;
    int QQ;
};

struct Database {
    int max_data;
    int max_rows;
    struct Address *rows;
};


struct Connection {
    FILE *file;
    struct Database *db;
};

struct Connection *conn = NULL;
void Database_close()
{
    if(conn) {
        if(conn->file) fclose(conn->file);
        if(conn->db) {
            if(conn->db->rows) {
                for(int i = 0; i < conn->db->max_rows; i++) {
                    if(conn->db->rows[i].name){free(conn->db->rows[i].name);}
                    if(conn->db->rows[i].email){free(conn->db->rows[i].email);}
                }
                free(conn->db->rows);
            }
            free(conn->db);
        }
        free(conn);
    }
}


void die(const char *message)
{
    if(errno){perror(message);}
    else{printf("ERROR: %s\n", message);}

    if(conn){Database_close();}
    exit(1);
}

void Address_print(struct Address *addr)
{
    if(addr!=NULL){
        printf("%d %s %s %d %d\n", addr->id, addr->name, addr->email, addr->phone, addr->QQ);
    }
}

void Database_load()
{
    if(!conn) die("errL0");
    if(!conn->db) die("errL1");
    if(!conn->file) die("errL2");
    if(fread(&conn->db->max_data, sizeof(int), 1, conn->file) != 1){die("errL3");}
    if(fread(&conn->db->max_rows, sizeof(int), 1, conn->file) != 1){die("errL4");}
    //AA
    conn->db->rows = malloc(sizeof(struct Address) * conn->db->max_rows);
    if(!conn->db->rows){die("errL5");}

    int rc = fread(conn->db->rows, sizeof(struct Address), conn->db->max_rows, conn->file);
    if(rc != conn->db->max_rows) die("errL6");

    for(int i = 0; i < conn->db->max_rows; i++) {
        conn->db->rows[i].name = malloc(conn->db->max_data);
        conn->db->rows[i].email = malloc(conn->db->max_data);

        if(conn->db->rows[i].name==NULL){die("errL7");}
        if(conn->db->rows[i].email==NULL){die("errL8");}
        
        if(fread(conn->db->rows[i].name, conn->db->max_data, 1, conn->file) != 1){die("errL9");}
        if(fread(conn->db->rows[i].email, conn->db->max_data, 1, conn->file) != 1){die("errL10");}
    }
}



 void Database_open(const char *filename, char mode, int max_data, int max_rows)
{
    if(!filename) die("errO0");

    conn = malloc(sizeof(struct Connection));
    if(!conn) die("errO1");

    conn->db = malloc(sizeof(struct Database));
    if(!conn->db) {
        free(conn);
        die("errO2");
    }

    if(mode == 'c') {
        if(max_data <= 0){die("errO3");}
        if(max_rows <= 0){die("errO4");}
        conn->db->max_data = max_data;
        conn->db->max_rows = max_rows;
        conn->file = fopen(filename, "w");
    } else {
        conn->file = fopen(filename, "r+");
        if(conn->file) {
            Database_load();
        } else {
            free(conn->db);
            free(conn);
            die("errO5");
        }
    }
}




void Database_write()
{
    if(!conn){die("errW0");}
    if(!conn->db){die("errW1");}
    if(!conn->file){die("errW2");}

    rewind(conn->file);

    if(fwrite(&conn->db->max_data, sizeof(int), 1, conn->file) != 1){die("errW3");}
    if(fwrite(&conn->db->max_rows, sizeof(int), 1, conn->file) != 1){die("errW4");}
    if(conn->db->max_data<=0){die("errW5");}
    if(conn->db->max_rows<=0){die("errW6");}
    int rc = fwrite(conn->db->rows, sizeof(struct Address), conn->db->max_rows, conn->file);
    if(rc != conn->db->max_rows){die("errW7");}

    for(int i = 0; i < conn->db->max_rows; i++) {
        if(fwrite(conn->db->rows[i].name, conn->db->max_data, 1, conn->file) != 1){
            die("errW8");}
        if(fwrite(conn->db->rows[i].email, conn->db->max_data, 1, conn->file) != 1){
            die("errW9");}
    }

    rc = fflush(conn->file);
    if(rc == -1) die("errW10");
}



void Database_create()
{
    if(!conn){die("errC0");}
    if(!conn->db){die("errC1");}

    conn->db->rows = malloc(sizeof(struct Address) * conn->db->max_rows);
    if(!conn->db->rows){die("errC2");}

    for(int i = 0; i < conn->db->max_rows; i++) {
        conn->db->rows[i].name = malloc(conn->db->max_data);
        conn->db->rows[i].email = malloc(conn->db->max_data);
        if(!conn->db->rows[i].name || !conn->db->rows[i].email){
            die("errC3");}

        conn->db->rows[i].id = i;
        conn->db->rows[i].set = 0;
        conn->db->rows[i].phone = 0;
        conn->db->rows[i].QQ = 0;
        memset(conn->db->rows[i].name, 0, conn->db->max_data);
        memset(conn->db->rows[i].email, 0, conn->db->max_data);
    }
}


void Database_set(int id, const char *name, const char *email, int phone,int QQ)
{
    if(!conn){die("errS0");}
    if(!conn->db){die("errS1");}
    if(!conn->db->rows){die("errS2");}
    if(id < 0){die("errS3");}
    if(id >= conn->db->max_rows){die("errS4");}
    if(!name){die("errS5");}
    if(!email){die("errS6");}

    struct Address *addr = &conn->db->rows[id];
    if(addr->set){die("errS7");}
    addr->set = 1;
    addr->phone = phone;
    addr->QQ = QQ;
    strncpy(addr->name, name, conn->db->max_data - 1);
    addr->name[conn->db->max_data - 1] = '\0';
    strncpy(addr->email, email, conn->db->max_data - 1);
    addr->email[conn->db->max_data - 1] = '\0';
}



void Database_get(int id)
{
    if(!conn){die("errG0");}
    if(!conn->db){die("errG1");}
    struct Address *addr = &conn->db->rows[id];
    if(!addr){die("errG2");}
    if(addr->set) {
        Address_print(addr);
    } else {
        die("errG3");
    }
}

void Database_delete(int id)
{
    if(!conn){die("errD0");}
    if(!conn->db){die("errD1");}
    if(!conn->db->rows){die("errD2");}
    if(id < 0){die("errD3");}
    if(id >= conn->db->max_rows){die("errD4");}
    
    if(conn->db->rows[id].name){
        free(conn->db->rows[id].name);
        conn->db->rows[id].name = NULL;
    }
    if(conn->db->rows[id].email){
        free(conn->db->rows[id].email);
        conn->db->rows[id].email = NULL;
    }
    conn->db->rows[id].name = malloc(conn->db->max_data);
    conn->db->rows[id].email = malloc(conn->db->max_data);
    if(!conn->db->rows[id].name) {die("errD5");}
    if(!conn->db->rows[id].email){die("errD6");}
    
    conn->db->rows[id].id = id;
    conn->db->rows[id].set = 0;
    conn->db->rows[id].phone = 0;
    conn->db->rows[id].QQ = 0;
    memset(conn->db->rows[id].name, 0, conn->db->max_data);
    memset(conn->db->rows[id].email, 0, conn->db->max_data);
}


void Database_list()
{
    if(!conn){die("errL0");}
    if(!conn->db){die("errL1");}

    for(int i = 0; i < conn->db->max_rows; i++) {
        struct Address *cur = &conn->db->rows[i];
        if(cur->set) {
            Address_print(cur);
        }
    }
}

void dataFind(int idFind, char* nameFind, char* emailFind,int phoneFind, int QQFind)
{
    if(!conn){die("errF0");}
    if(!conn->db){die("errF1");}
    if(!conn->db->rows){die("errF2");}
    for(int i = 0; i < conn->db->max_rows; i++) {
        struct Address *cur = &conn->db->rows[i];
        if(!cur){die("errF3");}
        if(cur->set) {
            int nameMatch=0;
            int emailMatch=0;
            int idMatch = (idFind >= 0 && cur->id == idFind);
            if(nameFind){nameMatch = (nameFind && strstr(cur->name, nameFind) != NULL);}
            if(emailFind){emailMatch = (emailFind && strstr(cur->email, emailFind) != NULL);}
            
            int phoneMatch = (cur->phone == phoneFind)&&(phoneFind != 0);
            int QQMatch = (cur->QQ == QQFind)&&(QQFind != 0);
            
            if(idMatch || nameMatch || emailMatch || phoneMatch || QQMatch) {
                Address_print(cur);
            }
        }
    }
}


int main(int argc, char *argv[])
{
    if(argc < 2){
        //打印定义的相关结构体的大小
        printf("Connection: %zu\n", sizeof(struct Connection));
        printf("-file: %zu\n", sizeof(FILE*));
        printf("-Database*: %zu\n", sizeof(struct Database*));
        printf("Database: %zu\n", sizeof(struct Database));
        printf("-max_data: %zu\n", sizeof(int));
        printf("-max_rows: %zu\n", sizeof(int));
        printf("-rows: %zu\n", sizeof(struct Address*));
    }
    if(argc < 3) die("USAGE: ex17 <dbfile> <action> [action params]");

    char *filename = argv[1];
    char action = argv[2][0];
    int id = 0;
    int phone = 0;
    int QQ = 0;

    if(action == 'c') {
        if(argc < 5) die("Need max_data and max_rows to create database");
        int max_data = atoi(argv[3]);
        int max_rows = atoi(argv[4]);
        if(max_data <= 0 || max_rows <= 0) die("Invalid database size parameters");
        Database_open(filename, action, max_data, max_rows);
    } else {
        Database_open(filename, action, 0, 0);
        if(argc > 3) id = atoi(argv[3]);
        if(id >= conn->db->max_rows) die("There's not that many records.");
    }

    if(argc>=7){ phone = atoi(argv[6]);}
    if(argc>=8){ QQ = atoi(argv[7]);}
    switch(action) {
        case 'c':
            Database_create();
            Database_write();
            break;

        case 'g':
            if(argc != 4) die("Need an id to get");

            Database_get(id);
            break;

        case 's':
            if(argc < 6) die("Need id, name, email to set");

            Database_set(id, argv[4], argv[5],phone, QQ);
            Database_write();
            break;

        case 'd':
            if(argc < 4) die("Need id to delete");

            Database_delete(id);
            Database_write();
            break;

        case 'l':
            Database_list();
            break;
        case 'f':
            if(argc < 4) die("Need something to find");
            dataFind(id, argv[4], argv[5] ,phone, QQ);
            break;
        default:
            die("Invalid action, only: c=create, g=get, s=set, d=del, l=list, f=find");
    }

    Database_close();

    return 0;
}