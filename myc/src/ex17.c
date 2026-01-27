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
void Database_close(struct Connection *conn)
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


void die(struct Connection *conn,const char *message)
{
    if(errno){perror(message);}
    else{printf("ERROR: %s\n", message);}

    if(conn){Database_close(conn);}
    exit(1);
}

void Address_print(struct Address *addr)
{
    if(addr!=NULL){
        printf("%d %s %s %d %d\n", addr->id, addr->name, addr->email, addr->phone, addr->QQ);
    }
}

void Database_load(struct Connection *conn)
{
    if(!conn) die(NULL, "errL0");
    if(!conn->db) die(NULL, "errL1");
    if(!conn->file) die(NULL, "errL2");
    if(fread(&conn->db->max_data, sizeof(int), 1, conn->file) != 1){die(conn, "errL3");}
    if(fread(&conn->db->max_rows, sizeof(int), 1, conn->file) != 1){die(conn, "errL4");}
    //AA
    conn->db->rows = malloc(sizeof(struct Address) * conn->db->max_rows);
    if(!conn->db->rows){die(conn, "errL5");}

    int rc = fread(conn->db->rows, sizeof(struct Address), conn->db->max_rows, conn->file);
    if(rc != conn->db->max_rows) die(conn, "errL6");

    for(int i = 0; i < conn->db->max_rows; i++) {
        conn->db->rows[i].name = malloc(conn->db->max_data);
        conn->db->rows[i].email = malloc(conn->db->max_data);

        if(conn->db->rows[i].name==NULL){die(conn, "errL7");}
        if(conn->db->rows[i].email==NULL){die(conn, "errL8");}
        
        if(fread(conn->db->rows[i].name, conn->db->max_data, 1, conn->file) != 1){die(conn, "errL9");}
        if(fread(conn->db->rows[i].email, conn->db->max_data, 1, conn->file) != 1){die(conn, "errL10");}
    }
}



struct Connection *Database_open(const char *filename, char mode, int max_data, int max_rows)
{
    if(!filename) die(NULL, "errO0");

    struct Connection *conn = malloc(sizeof(struct Connection));
    if(!conn) die(NULL, "errO1");

    conn->db = malloc(sizeof(struct Database));
    if(!conn->db) {
        free(conn);
        die(NULL, "errO2");
    }

    if(mode == 'c') {
        if(max_data <= 0){die(NULL, "errO3");}
        if(max_rows <= 0){die(NULL, "errO4");}
        conn->db->max_data = max_data;
        conn->db->max_rows = max_rows;
        conn->file = fopen(filename, "w");
    } else {
        conn->file = fopen(filename, "r+");
        if(conn->file) {
            Database_load(conn);
        } else {
            free(conn->db);
            free(conn);
            die(NULL, "errO5");
        }
    }
    return conn;
}




void Database_write(struct Connection *conn)
{
    if(!conn){die(conn, "errW0");}
    if(!conn->db){die(conn, "errW1");}
    if(!conn->file){die(conn, "errW2");}

    rewind(conn->file);

    if(fwrite(&conn->db->max_data, sizeof(int), 1, conn->file) != 1){die(conn, "errW3");}
    if(fwrite(&conn->db->max_rows, sizeof(int), 1, conn->file) != 1){die(conn, "errW4");}
    if(conn->db->max_data<=0){die(conn, "errW5");}
    if(conn->db->max_rows<=0){die(conn, "errW6");}
    int rc = fwrite(conn->db->rows, sizeof(struct Address), conn->db->max_rows, conn->file);
    if(rc != conn->db->max_rows){die(conn, "errW7");}

    for(int i = 0; i < conn->db->max_rows; i++) {
        if(fwrite(conn->db->rows[i].name, conn->db->max_data, 1, conn->file) != 1){
            die(conn, "errW8");}
        if(fwrite(conn->db->rows[i].email, conn->db->max_data, 1, conn->file) != 1){
            die(conn, "errW9");}
    }

    rc = fflush(conn->file);
    if(rc == -1) die(conn, "errW10");
}



void Database_create(struct Connection *conn)
{
    if(!conn){die(conn, "errC0");}
    if(!conn->db){die(conn, "errC1");}

    conn->db->rows = malloc(sizeof(struct Address) * conn->db->max_rows);
    if(!conn->db->rows){die(conn, "errC2");}

    for(int i = 0; i < conn->db->max_rows; i++) {
        conn->db->rows[i].name = malloc(conn->db->max_data);
        conn->db->rows[i].email = malloc(conn->db->max_data);
        if(!conn->db->rows[i].name || !conn->db->rows[i].email){
            die(conn, "errC3");}

        conn->db->rows[i].id = i;
        conn->db->rows[i].set = 0;
        conn->db->rows[i].phone = 0;
        conn->db->rows[i].QQ = 0;
        memset(conn->db->rows[i].name, 0, conn->db->max_data);
        memset(conn->db->rows[i].email, 0, conn->db->max_data);
    }
}


void Database_set(struct Connection *conn, int id, const char *name, const char *email, int phone,int QQ)
{
    if(!conn){die(conn, "errS0");}
    if(!conn->db){die(conn, "errS1");}
    if(!conn->db->rows){die(conn, "errS2");}
    if(id < 0){die(conn, "errS3");}
    if(id >= conn->db->max_rows){die(conn, "errS4");}
    if(!name){die(conn, "errS5");}
    if(!email){die(conn, "errS6");}

    struct Address *addr = &conn->db->rows[id];
    if(addr->set){die(conn, "errS7");}
    addr->set = 1;
    addr->phone = phone;
    addr->QQ = QQ;
    strncpy(addr->name, name, conn->db->max_data - 1);
    addr->name[conn->db->max_data - 1] = '\0';
    strncpy(addr->email, email, conn->db->max_data - 1);
    addr->email[conn->db->max_data - 1] = '\0';
}



void Database_get(struct Connection *conn, int id)
{
    if(!conn){die(conn, "errG0");}
    if(!conn->db){die(conn, "errG1");}
    struct Address *addr = &conn->db->rows[id];
    if(!addr){die(conn, "errG2");}
    if(addr->set) {
        Address_print(addr);
    } else {
        die(conn,"errG3");
    }
}

void Database_delete(struct Connection *conn, int id)
{
    if(!conn){die(conn, "errD0");}
    if(!conn->db){die(conn, "errD1");}
    if(!conn->db->rows){die(conn, "errD2");}
    if(id < 0){die(conn, "errD3");}
    if(id >= conn->db->max_rows){die(conn, "errD4");}
    
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
    if(!conn->db->rows[id].name) {die(conn, "errD5");}
    if(!conn->db->rows[id].email){die(conn, "errD6");}
    
    conn->db->rows[id].id = id;
    conn->db->rows[id].set = 0;
    conn->db->rows[id].phone = 0;
    conn->db->rows[id].QQ = 0;
    memset(conn->db->rows[id].name, 0, conn->db->max_data);
    memset(conn->db->rows[id].email, 0, conn->db->max_data);
}


void Database_list(struct Connection *conn)
{
    if(!conn){die(conn, "errL0");}
    if(!conn->db){die(conn, "errL1");}

    for(int i = 0; i < conn->db->max_rows; i++) {
        struct Address *cur = &conn->db->rows[i];
        if(cur->set) {
            Address_print(cur);
        }
    }
}

void dataFind(struct Connection *conn, int idFind, char* nameFind, char* emailFind,int phoneFind, int QQFind)
{
    if(!conn){die(conn, "errF0");}
    if(!conn->db){die(conn, "errF1");}
    if(!conn->db->rows){die(conn, "errF2");}
    for(int i = 0; i < conn->db->max_rows; i++) {
        struct Address *cur = &conn->db->rows[i];
        if(!cur){die(conn, "errF3");}
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
    if(argc < 3) die(NULL,"USAGE: ex17 <dbfile> <action> [action params]");

    char *filename = argv[1];
    char action = argv[2][0];
    struct Connection *conn = NULL;
    int id = 0;
    int phone = 0;
    int QQ = 0;

    if(action == 'c') {
        if(argc < 5) die(NULL, "Need max_data and max_rows to create database");
        int max_data = atoi(argv[3]);
        int max_rows = atoi(argv[4]);
        if(max_data <= 0 || max_rows <= 0) die(NULL, "Invalid database size parameters");
        conn = Database_open(filename, action, max_data, max_rows);
    } else {
        conn = Database_open(filename, action, 0, 0);
        if(argc > 3) id = atoi(argv[3]);
        if(id >= conn->db->max_rows) die(conn, "There's not that many records.");
    }

    if(argc>=7){ phone = atoi(argv[6]);}
    if(argc>=8){ QQ = atoi(argv[7]);}
    switch(action) {
        case 'c':
            Database_create(conn);
            Database_write(conn);
            break;

        case 'g':
            if(argc != 4) die(conn,"Need an id to get");

            Database_get(conn, id);
            break;

        case 's':
            if(argc < 6) die(conn,"Need id, name, email to set");

            Database_set(conn, id, argv[4], argv[5],phone, QQ);
            Database_write(conn);
            break;

        case 'd':
            if(argc < 4) die(conn,"Need id to delete");

            Database_delete(conn, id);
            Database_write(conn);
            break;

        case 'l':
            Database_list(conn);
            break;
        case 'f':
            if(argc < 4) die(conn,"Need something to find");
            dataFind(conn, id, argv[4], argv[5] ,phone, QQ);
            break;
        default:
            die(conn,"Invalid action, only: c=create, g=get, s=set, d=del, l=list, f=find");
    }

    Database_close(conn);

    return 0;
}