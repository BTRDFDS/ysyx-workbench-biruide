clang -fsyntax-only -Xclang -ast-dump a.c
TranslationUnitDecl 0x934ebc8 <<invalid sloc>> <invalid sloc>
|-TypedefDecl 0x934f3f0 <<invalid sloc>> <invalid sloc> implicit __int128_t '__int128'
| `-BuiltinType 0x934f190 '__int128'
|-TypedefDecl 0x934f460 <<invalid sloc>> <invalid sloc> implicit __uint128_t 'unsigned __int128'
| `-BuiltinType 0x934f1b0 'unsigned __int128'
|-TypedefDecl 0x934f768 <<invalid sloc>> <invalid sloc> implicit __NSConstantString 'struct __NSConstantString_tag'
| `-RecordType 0x934f540 'struct __NSConstantString_tag'
|   `-Record 0x934f4b8 '__NSConstantString_tag'
|-TypedefDecl 0x934f800 <<invalid sloc>> <invalid sloc> implicit __builtin_ms_va_list 'char *'
| `-PointerType 0x934f7c0 'char *'
|   `-BuiltinType 0x934ec70 'char'
|-TypedefDecl 0x934faf8 <<invalid sloc>> <invalid sloc> implicit referenced __builtin_va_list 'struct __va_list_tag[1]'
| `-ConstantArrayType 0x934faa0 'struct __va_list_tag[1]' 1 
|   `-RecordType 0x934f8e0 'struct __va_list_tag'
|     `-Record 0x934f858 '__va_list_tag'
|-TypedefDecl 0x934fb68 </usr/lib/llvm-14/lib/clang/14.0.0/include/stddef.h:46:1, col:23> col:23 referenced size_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8150 </usr/lib/llvm-14/lib/clang/14.0.0/include/stdarg.h:14:1, col:27> col:27 va_list '__builtin_va_list':'struct __va_list_tag[1]'
| `-TypedefType 0x93d8120 '__builtin_va_list' sugar
|   |-Typedef 0x934faf8 '__builtin_va_list'
|   `-ConstantArrayType 0x934faa0 'struct __va_list_tag[1]' 1 
|     `-RecordType 0x934f8e0 'struct __va_list_tag'
|       `-Record 0x934f858 '__va_list_tag'
|-TypedefDecl 0x93d81b8 <line:32:1, col:27> col:27 referenced __gnuc_va_list '__builtin_va_list':'struct __va_list_tag[1]'
| `-TypedefType 0x93d8120 '__builtin_va_list' sugar
|   |-Typedef 0x934faf8 '__builtin_va_list'
|   `-ConstantArrayType 0x934faa0 'struct __va_list_tag[1]' 1 
|     `-RecordType 0x934f8e0 'struct __va_list_tag'
|       `-Record 0x934f858 '__va_list_tag'
|-TypedefDecl 0x93d8228 </usr/include/x86_64-linux-gnu/bits/types.h:31:1, col:23> col:23 __u_char 'unsigned char'
| `-BuiltinType 0x934ed30 'unsigned char'
|-TypedefDecl 0x93d8298 <line:32:1, col:28> col:28 __u_short 'unsigned short'
| `-BuiltinType 0x934ed50 'unsigned short'
|-TypedefDecl 0x93d8308 <line:33:1, col:22> col:22 __u_int 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93d8378 <line:34:1, col:27> col:27 __u_long 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d83e8 <line:37:1, col:21> col:21 referenced __int8_t 'signed char'
| `-BuiltinType 0x934ec90 'signed char'
|-TypedefDecl 0x93d8458 <line:38:1, col:23> col:23 referenced __uint8_t 'unsigned char'
| `-BuiltinType 0x934ed30 'unsigned char'
|-TypedefDecl 0x93d84c8 <line:39:1, col:26> col:26 referenced __int16_t 'short'
| `-BuiltinType 0x934ecb0 'short'
|-TypedefDecl 0x93d8538 <line:40:1, col:28> col:28 referenced __uint16_t 'unsigned short'
| `-BuiltinType 0x934ed50 'unsigned short'
|-TypedefDecl 0x93d85a8 <line:41:1, col:20> col:20 referenced __int32_t 'int'
| `-BuiltinType 0x934ecd0 'int'
|-TypedefDecl 0x93d8618 <line:42:1, col:22> col:22 referenced __uint32_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93d8688 <line:44:1, col:25> col:25 referenced __int64_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93d86f8 <line:45:1, col:27> col:27 referenced __uint64_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8780 <line:52:1, col:18> col:18 __int_least8_t '__int8_t':'signed char'
| `-TypedefType 0x93d8750 '__int8_t' sugar
|   |-Typedef 0x93d83e8 '__int8_t'
|   `-BuiltinType 0x934ec90 'signed char'
|-TypedefDecl 0x93d8810 <line:53:1, col:19> col:19 __uint_least8_t '__uint8_t':'unsigned char'
| `-TypedefType 0x93d87e0 '__uint8_t' sugar
|   |-Typedef 0x93d8458 '__uint8_t'
|   `-BuiltinType 0x934ed30 'unsigned char'
|-TypedefDecl 0x93d88a0 <line:54:1, col:19> col:19 __int_least16_t '__int16_t':'short'
| `-TypedefType 0x93d8870 '__int16_t' sugar
|   |-Typedef 0x93d84c8 '__int16_t'
|   `-BuiltinType 0x934ecb0 'short'
|-TypedefDecl 0x93d8930 <line:55:1, col:20> col:20 __uint_least16_t '__uint16_t':'unsigned short'
| `-TypedefType 0x93d8900 '__uint16_t' sugar
|   |-Typedef 0x93d8538 '__uint16_t'
|   `-BuiltinType 0x934ed50 'unsigned short'
|-TypedefDecl 0x93d89c0 <line:56:1, col:19> col:19 __int_least32_t '__int32_t':'int'
| `-TypedefType 0x93d8990 '__int32_t' sugar
|   |-Typedef 0x93d85a8 '__int32_t'
|   `-BuiltinType 0x934ecd0 'int'
|-TypedefDecl 0x93d8a50 <line:57:1, col:20> col:20 __uint_least32_t '__uint32_t':'unsigned int'
| `-TypedefType 0x93d8a20 '__uint32_t' sugar
|   |-Typedef 0x93d8618 '__uint32_t'
|   `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93d8ae0 <line:58:1, col:19> col:19 __int_least64_t '__int64_t':'long'
| `-TypedefType 0x93d8ab0 '__int64_t' sugar
|   |-Typedef 0x93d8688 '__int64_t'
|   `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93d8b70 <line:59:1, col:20> col:20 __uint_least64_t '__uint64_t':'unsigned long'
| `-TypedefType 0x93d8b40 '__uint64_t' sugar
|   |-Typedef 0x93d86f8 '__uint64_t'
|   `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8be0 <line:63:1, col:18> col:18 __quad_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93d8c50 <line:64:1, col:27> col:27 __u_quad_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8cc0 <line:72:1, col:18> col:18 __intmax_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93d8d30 <line:73:1, col:27> col:27 __uintmax_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8da0 <line:137:22, line:145:25> col:25 __dev_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8e10 <line:137:22, line:146:25> col:25 __uid_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93d8e80 <line:137:22, line:147:25> col:25 __gid_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93d8ef0 <line:137:22, line:148:25> col:25 __ino_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8f60 <line:137:22, line:149:27> col:27 __ino64_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d8fd0 <line:137:22, line:150:26> col:26 __mode_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93d9040 <line:137:22, line:151:27> col:27 __nlink_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93d90b0 <line:137:22, line:152:25> col:25 referenced __off_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e5e90 <line:137:22, line:153:27> col:27 referenced __off64_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e5f00 <line:137:22, line:154:25> col:25 __pid_t 'int'
| `-BuiltinType 0x934ecd0 'int'
|-RecordDecl 0x93e5f58 </usr/include/x86_64-linux-gnu/bits/typesizes.h:73:24, col:47> col:24 struct definition
| `-FieldDecl 0x93e60a0 <col:33, col:44> col:37 __val 'int[2]'
|-TypedefDecl 0x93e6148 </usr/include/x86_64-linux-gnu/bits/types.h:137:22, line:155:26> col:26 __fsid_t 'struct __fsid_t':'__fsid_t'
| `-ElaboratedType 0x93e60f0 'struct __fsid_t' sugar
|   `-RecordType 0x93e5fe0 '__fsid_t'
|     `-Record 0x93e5f58 ''
|-TypedefDecl 0x93e61d0 <line:137:22, line:156:27> col:27 __clock_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6240 <line:137:22, line:157:26> col:26 __rlim_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e62b0 <line:137:22, line:158:28> col:28 __rlim64_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e6320 <line:137:22, line:159:24> col:24 __id_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93e6390 <line:137:22, line:160:26> col:26 __time_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6400 <line:137:22, line:161:30> col:30 __useconds_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93e6470 <line:137:22, line:162:31> col:31 __suseconds_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e64e0 <line:137:22, line:163:33> col:33 __suseconds64_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6550 <line:137:22, line:165:27> col:27 __daddr_t 'int'
| `-BuiltinType 0x934ecd0 'int'
|-TypedefDecl 0x93e65c0 <line:137:22, line:166:25> col:25 __key_t 'int'
| `-BuiltinType 0x934ecd0 'int'
|-TypedefDecl 0x93e6630 <line:137:22, line:169:29> col:29 __clockid_t 'int'
| `-BuiltinType 0x934ecd0 'int'
|-TypedefDecl 0x93e66a0 <line:137:22, line:172:27> col:27 __timer_t 'void *'
| `-PointerType 0x934f350 'void *'
|   `-BuiltinType 0x934ec30 'void'
|-TypedefDecl 0x93e6710 <line:137:22, line:175:29> col:29 __blksize_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6780 <line:137:22, line:180:28> col:28 __blkcnt_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e67f0 <line:137:22, line:181:30> col:30 __blkcnt64_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6860 <line:137:22, line:184:30> col:30 __fsblkcnt_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e68d0 <line:137:22, line:185:32> col:32 __fsblkcnt64_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e6940 <line:137:22, line:188:30> col:30 __fsfilcnt_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e69b0 <line:137:22, line:189:32> col:32 __fsfilcnt64_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e6a20 <line:137:22, line:192:28> col:28 __fsword_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6a90 <line:137:22, line:194:27> col:27 referenced __ssize_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6b00 <line:137:22, line:197:33> col:33 __syscall_slong_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6b70 <line:137:22, line:199:33> col:33 __syscall_ulong_t 'unsigned long'
| `-BuiltinType 0x934ed90 'unsigned long'
|-TypedefDecl 0x93e6c00 <line:203:1, col:19> col:19 __loff_t '__off64_t':'long'
| `-TypedefType 0x93e6bd0 '__off64_t' sugar
|   |-Typedef 0x93e5e90 '__off64_t'
|   `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6c70 <line:204:1, col:15> col:15 __caddr_t 'char *'
| `-PointerType 0x934f7c0 'char *'
|   `-BuiltinType 0x934ec70 'char'
|-TypedefDecl 0x93e6ce0 <line:137:22, line:207:25> col:25 __intptr_t 'long'
| `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93e6d50 <line:137:22, line:210:23> col:23 __socklen_t 'unsigned int'
| `-BuiltinType 0x934ed70 'unsigned int'
|-TypedefDecl 0x93e6dc0 <line:215:1, col:13> col:13 __sig_atomic_t 'int'
| `-BuiltinType 0x934ecd0 'int'
|-RecordDecl 0x93e7eb0 </usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h:13:9, line:21:1> line:13:9 struct definition
| |-FieldDecl 0x93e7f68 <line:15:3, col:7> col:7 __count 'int'
| |-RecordDecl 0x93e7fb8 <line:16:3, line:20:3> line:16:3 union definition
| | |-FieldDecl 0x93e8078 <<built-in>:98:23, /usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h:18:19> col:19 __wch 'unsigned int'
| | `-FieldDecl 0x93e8168 <line:19:5, col:18> col:10 __wchb 'char[4]'
| `-FieldDecl 0x93e8218 <line:16:3, line:20:5> col:5 __value 'union (unnamed union at /usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h:16:3)':'union __mbstate_t::(unnamed at /usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h:16:3)'
|-TypedefDecl 0x93e82c8 <line:13:1, line:21:3> col:3 referenced __mbstate_t 'struct __mbstate_t':'__mbstate_t'
| `-ElaboratedType 0x93e8270 'struct __mbstate_t' sugar
|   `-RecordType 0x93e7f30 '__mbstate_t'
|     `-Record 0x93e7eb0 ''
|-RecordDecl 0x93e8338 </usr/include/x86_64-linux-gnu/bits/types/__fpos_t.h:10:9, line:14:1> line:10:16 struct _G_fpos_t definition
| |-FieldDecl 0x93e8410 <line:12:3, col:11> col:11 __pos '__off_t':'long'
| `-FieldDecl 0x93e8490 <line:13:3, col:15> col:15 __state '__mbstate_t':'__mbstate_t'
|-TypedefDecl 0x93e8538 <line:10:1, line:14:3> col:3 referenced __fpos_t 'struct _G_fpos_t':'struct _G_fpos_t'
| `-ElaboratedType 0x93e84e0 'struct _G_fpos_t' sugar
|   `-RecordType 0x93e83c0 'struct _G_fpos_t'
|     `-Record 0x93e8338 '_G_fpos_t'
|-RecordDecl 0x93e85a8 </usr/include/x86_64-linux-gnu/bits/types/__fpos64_t.h:10:9, line:14:1> line:10:16 struct _G_fpos64_t definition
| |-FieldDecl 0x93e8660 <line:12:3, col:13> col:13 __pos '__off64_t':'long'
| `-FieldDecl 0x93e86c0 <line:13:3, col:15> col:15 __state '__mbstate_t':'__mbstate_t'
|-TypedefDecl 0x93e8768 <line:10:1, line:14:3> col:3 __fpos64_t 'struct _G_fpos64_t':'struct _G_fpos64_t'
| `-ElaboratedType 0x93e8710 'struct _G_fpos64_t' sugar
|   `-RecordType 0x93e8630 'struct _G_fpos64_t'
|     `-Record 0x93e85a8 '_G_fpos64_t'
|-RecordDecl 0x93e87d8 </usr/include/x86_64-linux-gnu/bits/types/__FILE.h:4:1, col:8> col:8 struct _IO_FILE
|-TypedefDecl 0x93e88d0 <line:5:1, col:25> col:25 __FILE 'struct _IO_FILE':'struct _IO_FILE'
| `-ElaboratedType 0x93e8880 'struct _IO_FILE' sugar
|   `-RecordType 0x93e8860 'struct _IO_FILE'
|     `-Record 0x93e8ce8 '_IO_FILE'
|-RecordDecl 0x93e8928 prev 0x93e87d8 </usr/include/x86_64-linux-gnu/bits/types/FILE.h:4:1, col:8> col:8 struct _IO_FILE
|-TypedefDecl 0x93e89c8 <line:7:1, col:25> col:25 referenced FILE 'struct _IO_FILE':'struct _IO_FILE'
| `-ElaboratedType 0x93e8880 'struct _IO_FILE' sugar
|   `-RecordType 0x93e8860 'struct _IO_FILE'
|     `-Record 0x93e8ce8 '_IO_FILE'
|-RecordDecl 0x93e8a20 prev 0x93e8928 </usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h:35:1, col:8> col:8 struct _IO_FILE
|-RecordDecl 0x93e8aa0 <line:36:1, col:8> col:8 struct _IO_marker
|-RecordDecl 0x93e8b40 <line:37:1, col:8> col:8 struct _IO_codecvt
|-RecordDecl 0x93e8be0 <line:38:1, col:8> col:8 struct _IO_wide_data
|-TypedefDecl 0x93e8c90 <line:43:1, col:14> col:14 referenced _IO_lock_t 'void'
| `-BuiltinType 0x934ec30 'void'
|-RecordDecl 0x93e8ce8 prev 0x93e8a20 <line:49:1, line:99:1> line:49:8 struct _IO_FILE definition
| |-FieldDecl 0x93e8d80 <line:51:3, col:7> col:7 _flags 'int'
| |-FieldDecl 0x93e8de8 <line:54:3, col:9> col:9 _IO_read_ptr 'char *'
| |-FieldDecl 0x93e8e50 <line:55:3, col:9> col:9 _IO_read_end 'char *'
| |-FieldDecl 0x93ebf68 <line:56:3, col:9> col:9 _IO_read_base 'char *'
| |-FieldDecl 0x93ebfd0 <line:57:3, col:9> col:9 _IO_write_base 'char *'
| |-FieldDecl 0x93ec038 <line:58:3, col:9> col:9 _IO_write_ptr 'char *'
| |-FieldDecl 0x93ec0a0 <line:59:3, col:9> col:9 _IO_write_end 'char *'
| |-FieldDecl 0x93ec108 <line:60:3, col:9> col:9 _IO_buf_base 'char *'
| |-FieldDecl 0x93ec170 <line:61:3, col:9> col:9 _IO_buf_end 'char *'
| |-FieldDecl 0x93ec1d8 <line:64:3, col:9> col:9 _IO_save_base 'char *'
| |-FieldDecl 0x93ec240 <line:65:3, col:9> col:9 _IO_backup_base 'char *'
| |-FieldDecl 0x93ec2a8 <line:66:3, col:9> col:9 _IO_save_end 'char *'
| |-FieldDecl 0x93ec3b0 <line:68:3, col:22> col:22 _markers 'struct _IO_marker *'
| |-FieldDecl 0x93ec480 <line:70:3, col:20> col:20 _chain 'struct _IO_FILE *'
| |-FieldDecl 0x93ec4e8 <line:72:3, col:7> col:7 _fileno 'int'
| |-FieldDecl 0x93ec550 <line:73:3, col:7> col:7 _flags2 'int'
| |-FieldDecl 0x93ec5b0 <line:74:3, col:11> col:11 _old_offset '__off_t':'long'
| |-FieldDecl 0x93ec618 <line:77:3, col:18> col:18 _cur_column 'unsigned short'
| |-FieldDecl 0x93ec680 <line:78:3, col:15> col:15 _vtable_offset 'signed char'
| |-FieldDecl 0x93ec768 <line:79:3, col:19> col:8 _shortbuf 'char[1]'
| |-FieldDecl 0x93ec818 <line:81:3, col:15> col:15 _lock '_IO_lock_t *'
| |-FieldDecl 0x93ec878 <line:89:3, col:13> col:13 _offset '__off64_t':'long'
| |-FieldDecl 0x93ec980 <line:91:3, col:23> col:23 _codecvt 'struct _IO_codecvt *'
| |-FieldDecl 0x93eca80 <line:92:3, col:25> col:25 _wide_data 'struct _IO_wide_data *'
| |-FieldDecl 0x93ecaf8 <line:93:3, col:20> col:20 _freeres_list 'struct _IO_FILE *'
| |-FieldDecl 0x93ecb60 <line:94:3, col:9> col:9 _freeres_buf 'void *'
| |-FieldDecl 0x93ecbe0 <line:95:3, col:10> col:10 __pad5 'size_t':'unsigned long'
| |-FieldDecl 0x93ecc48 <line:96:3, col:7> col:7 _mode 'int'
| `-FieldDecl 0x93ecea8 <line:98:3, col:74> col:8 _unused2 'char[20]'
|-TypedefDecl 0x93eecb0 prev 0x93d8150 </usr/include/stdio.h:52:1, col:24> col:24 va_list '__gnuc_va_list':'struct __va_list_tag[1]'
| `-TypedefType 0x93ecf00 '__gnuc_va_list' sugar
|   |-Typedef 0x93d81b8 '__gnuc_va_list'
|   `-TypedefType 0x93d8120 '__builtin_va_list' sugar
|     |-Typedef 0x934faf8 '__builtin_va_list'
|     `-ConstantArrayType 0x934faa0 'struct __va_list_tag[1]' 1 
|       `-RecordType 0x934f8e0 'struct __va_list_tag'
|         `-Record 0x934f858 '__va_list_tag'
|-TypedefDecl 0x93eed18 <line:63:1, col:17> col:17 off_t '__off_t':'long'
| `-TypedefType 0x93e83e0 '__off_t' sugar
|   |-Typedef 0x93d90b0 '__off_t'
|   `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93eeda0 <line:77:1, col:19> col:19 ssize_t '__ssize_t':'long'
| `-TypedefType 0x93eed70 '__ssize_t' sugar
|   |-Typedef 0x93e6a90 '__ssize_t'
|   `-BuiltinType 0x934ecf0 'long'
|-TypedefDecl 0x93eee30 <line:84:1, col:18> col:18 referenced fpos_t '__fpos_t':'struct _G_fpos_t'
| `-TypedefType 0x93eee00 '__fpos_t' sugar
|   |-Typedef 0x93e8538 '__fpos_t'
|   `-ElaboratedType 0x93e84e0 'struct _G_fpos_t' sugar
|     `-RecordType 0x93e83c0 'struct _G_fpos_t'
|       `-Record 0x93e8338 '_G_fpos_t'
|-VarDecl 0x93eeee8 <line:143:1, col:14> col:14 stdin 'FILE *' extern
|-VarDecl 0x93eefa8 <line:144:1, col:14> col:14 stdout 'FILE *' extern
|-VarDecl 0x93ef020 <line:145:1, col:14> col:14 stderr 'FILE *' extern
|-FunctionDecl 0x93ef170 <line:152:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:152:12 remove 'int (const char *)' extern
| |-ParmVarDecl 0x93ef0a0 <col:20, col:32> col:32 __filename 'const char *'
| `-NoThrowAttr 0x93ef218 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93ef3e0 </usr/include/stdio.h:154:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:154:12 rename 'int (const char *, const char *)' extern
| |-ParmVarDecl 0x93ef288 <col:20, col:32> col:32 __old 'const char *'
| |-ParmVarDecl 0x93ef308 <col:39, col:51> col:51 __new 'const char *'
| `-NoThrowAttr 0x93ef490 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93ef780 </usr/include/stdio.h:158:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:158:12 renameat 'int (int, const char *, int, const char *)' extern
| |-ParmVarDecl 0x93ef500 <col:22, col:26> col:26 __oldfd 'int'
| |-ParmVarDecl 0x93ef580 <col:35, col:47> col:47 __old 'const char *'
| |-ParmVarDecl 0x93ef600 <col:54, col:58> col:58 __newfd 'int'
| |-ParmVarDecl 0x93ef680 <line:159:8, col:20> col:20 __new 'const char *'
| `-NoThrowAttr 0x93ef840 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93ef9a0 </usr/include/stdio.h:178:1, col:34> col:12 fclose 'int (FILE *)' extern
| `-ParmVarDecl 0x93ef8a8 <col:20, col:26> col:26 __stream 'FILE *'
|-FunctionDecl 0x93efb38 <line:188:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:188:14 tmpfile 'FILE *(void)' extern
| `-RestrictAttr 0x93efbd8 </usr/include/x86_64-linux-gnu/sys/cdefs.h:281:47> malloc
|-FunctionDecl 0x93f4390 </usr/include/stdio.h:205:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:205:14 tmpnam 'char *(char *)' extern
| |-ParmVarDecl 0x93f4290 <col:22, col:35> col:26 'char *':'char *'
| `-NoThrowAttr 0x93f4438 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93f4588 </usr/include/stdio.h:210:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:210:14 tmpnam_r 'char *(char *)' extern
| |-ParmVarDecl 0x93f44f0 <col:24, col:41> col:29 __s 'char *':'char *'
| `-NoThrowAttr 0x93f4630 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93f4800 </usr/include/stdio.h:222:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:222:14 tempnam 'char *(const char *, const char *)' extern
| |-ParmVarDecl 0x93f46a0 <col:23, col:35> col:35 __dir 'const char *'
| |-ParmVarDecl 0x93f4720 <col:42, col:54> col:54 __pfx 'const char *'
| |-NoThrowAttr 0x93f48b0 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
| `-RestrictAttr 0x93f4908 <line:281:47> malloc
|-FunctionDecl 0x93f49d8 </usr/include/stdio.h:230:1, col:34> col:12 fflush 'int (FILE *)' extern
| `-ParmVarDecl 0x93f4940 <col:20, col:26> col:26 __stream 'FILE *'
|-FunctionDecl 0x93f4b28 <line:239:1, col:43> col:12 fflush_unlocked 'int (FILE *)' extern
| `-ParmVarDecl 0x93f4a90 <col:29, col:35> col:35 __stream 'FILE *'
|-FunctionDecl 0x93f4db8 <line:258:14> col:14 implicit fopen 'FILE *(const char *, const char *)' extern
| |-ParmVarDecl 0x93f4eb0 <<invalid sloc>> <invalid sloc> 'const char *'
| |-ParmVarDecl 0x93f4f18 <<invalid sloc>> <invalid sloc> 'const char *'
| `-BuiltinAttr 0x93f4e58 <<invalid sloc>> Implicit 838
|-FunctionDecl 0x93f4f90 prev 0x93f4db8 <col:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:258:14 fopen 'FILE *(const char *, const char *)' extern
| |-ParmVarDecl 0x93f4be8 <col:21, col:44> col:44 __filename 'const char *restrict'
| |-ParmVarDecl 0x93f4c68 <line:259:7, col:30> col:30 __modes 'const char *restrict'
| |-BuiltinAttr 0x93f5098 <<invalid sloc>> Inherited Implicit 838
| `-RestrictAttr 0x93f5040 </usr/include/x86_64-linux-gnu/sys/cdefs.h:281:47> malloc
|-FunctionDecl 0x93f7398 </usr/include/stdio.h:265:1, line:267:34> line:265:14 freopen 'FILE *(const char *restrict, const char *restrict, FILE *restrict)' extern
| |-ParmVarDecl 0x93f50d8 <col:23, col:46> col:46 __filename 'const char *restrict'
| |-ParmVarDecl 0x93f5158 <line:266:9, col:32> col:32 __modes 'const char *restrict'
| `-ParmVarDecl 0x93f51d0 <line:267:9, col:26> col:26 __stream 'FILE *restrict'
|-FunctionDecl 0x93f75f8 <line:293:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:293:14 fdopen 'FILE *(int, const char *)' extern
| |-ParmVarDecl 0x93f7468 <col:22, col:26> col:26 __fd 'int'
| |-ParmVarDecl 0x93f74e8 <col:32, col:44> col:44 __modes 'const char *'
| |-NoThrowAttr 0x93f76a8 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
| `-RestrictAttr 0x93f7700 <line:281:47> malloc
|-FunctionDecl 0x93f7958 </usr/include/stdio.h:308:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:308:14 fmemopen 'FILE *(void *, size_t, const char *)' extern
| |-ParmVarDecl 0x93f7740 <col:24, col:30> col:30 __s 'void *'
| |-ParmVarDecl 0x93f77b8 <col:35, col:42> col:42 __len 'size_t':'unsigned long'
| |-ParmVarDecl 0x93f7838 <col:49, col:61> col:61 __modes 'const char *'
| |-NoThrowAttr 0x93f7a10 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
| `-RestrictAttr 0x93f7a68 <line:281:47> malloc
|-FunctionDecl 0x93f7cb8 </usr/include/stdio.h:314:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:314:14 open_memstream 'FILE *(char **, size_t *)' extern
| |-ParmVarDecl 0x93f7ad0 <col:30, col:37> col:37 __bufloc 'char **'
| |-ParmVarDecl 0x93f7ba8 <col:47, col:55> col:55 __sizeloc 'size_t *'
| |-NoThrowAttr 0x93f7d68 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
| `-RestrictAttr 0x93f7dc0 <line:281:47> malloc
|-FunctionDecl 0x93f7f88 </usr/include/stdio.h:328:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:328:13 setbuf 'void (FILE *restrict, char *restrict)' extern
| |-ParmVarDecl 0x93f7df8 <col:21, col:38> col:38 __stream 'FILE *restrict'
| |-ParmVarDecl 0x93f7e78 <col:48, col:65> col:65 __buf 'char *restrict'
| `-NoThrowAttr 0x93f8038 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93f8380 </usr/include/stdio.h:332:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:332:12 setvbuf 'int (FILE *restrict, char *restrict, int, size_t)' extern
| |-ParmVarDecl 0x93f80a0 <col:21, col:38> col:38 __stream 'FILE *restrict'
| |-ParmVarDecl 0x93f8120 <col:48, col:65> col:65 __buf 'char *restrict'
| |-ParmVarDecl 0x93f81a0 <line:333:7, col:11> col:11 __modes 'int'
| |-ParmVarDecl 0x93f8218 <col:20, col:27> col:27 __n 'size_t':'unsigned long'
| `-NoThrowAttr 0x93f8440 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93f86c8 </usr/include/stdio.h:338:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:338:13 setbuffer 'void (FILE *restrict, char *restrict, size_t)' extern
| |-ParmVarDecl 0x93f84a8 <col:24, col:41> col:41 __stream 'FILE *restrict'
| |-ParmVarDecl 0x93f8528 <col:51, col:68> col:68 __buf 'char *restrict'
| |-ParmVarDecl 0x93f85a0 <line:339:10, col:17> col:17 __size 'size_t':'unsigned long'
| `-NoThrowAttr 0x93f8780 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93f88d8 </usr/include/stdio.h:342:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:342:13 setlinebuf 'void (FILE *)' extern
| |-ParmVarDecl 0x93f87e8 <col:25, col:31> col:31 __stream 'FILE *'
| `-NoThrowAttr 0x93f8980 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x93f8bd0 </usr/include/stdio.h:350:12> col:12 implicit fprintf 'int (FILE *, const char *, ...)' extern
| |-ParmVarDecl 0x93f8cc8 <<invalid sloc>> <invalid sloc> 'FILE *'
| |-ParmVarDecl 0x93f8d30 <<invalid sloc>> <invalid sloc> 'const char *'
| |-BuiltinAttr 0x93f8c70 <<invalid sloc>> Implicit 825
| `-FormatAttr 0x93f8da8 <col:12> Implicit printf 2 3
|-FunctionDecl 0x93f8de0 prev 0x93f8bd0 <col:1, line:351:43> line:350:12 fprintf 'int (FILE *, const char *, ...)' extern
| |-ParmVarDecl 0x93f89e8 <col:21, col:38> col:38 __stream 'FILE *restrict'
| |-ParmVarDecl 0x93f8a68 <line:351:7, col:30> col:30 __format 'const char *restrict'
| |-BuiltinAttr 0x93f8ec0 <<invalid sloc>> Inherited Implicit 825
| `-FormatAttr 0x93f8ee8 <line:350:12> Inherited printf 2 3
|-FunctionDecl 0x93f9048 <line:356:12> col:12 implicit used printf 'int (const char *, ...)' extern
| |-ParmVarDecl 0x93f9140 <<invalid sloc>> <invalid sloc> 'const char *'
| |-BuiltinAttr 0x93f90e8 <<invalid sloc>> Implicit 824
| `-FormatAttr 0x93f91b0 <col:12> Implicit printf 1 2
|-FunctionDecl 0x93f91e8 prev 0x93f9048 <col:1, col:56> col:12 used printf 'int (const char *, ...)' extern
| |-ParmVarDecl 0x93f8f38 <col:20, col:43> col:43 __format 'const char *restrict'
| |-BuiltinAttr 0x93f92c0 <<invalid sloc>> Inherited Implicit 824
| `-FormatAttr 0x93f9300 <col:12> Inherited printf 1 2
|-FunctionDecl 0x93f94f8 <line:358:12> col:12 implicit sprintf 'int (char *, const char *, ...)' extern
| |-ParmVarDecl 0x93f95f0 <<invalid sloc>> <invalid sloc> 'char *'
| |-ParmVarDecl 0x93f9658 <<invalid sloc>> <invalid sloc> 'const char *'
| |-BuiltinAttr 0x93f9598 <<invalid sloc>> Implicit 827
| `-FormatAttr 0x93f96d0 <col:12> Implicit printf 2 3
|-FunctionDecl 0x93f9708 prev 0x93f94f8 <col:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:80:49> /usr/include/stdio.h:358:12 sprintf 'int (char *, const char *, ...)' extern
| |-ParmVarDecl 0x93f9350 <col:21, col:38> col:38 __s 'char *restrict'
| |-ParmVarDecl 0x93f93d0 <line:359:7, col:30> col:30 __format 'const char *restrict'
| |-BuiltinAttr 0x93f9810 <<invalid sloc>> Inherited Implicit 827
| |-FormatAttr 0x93f9838 <line:358:12> Inherited printf 2 3
| `-NoThrowAttr 0x93f97b8 </usr/include/x86_64-linux-gnu/sys/cdefs.h:80:37>
|-FunctionDecl 0x93f9b50 </usr/include/stdio.h:365:12> col:12 implicit vfprintf 'int (FILE *, const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93f9c48 <<invalid sloc>> <invalid sloc> 'FILE *'
| |-ParmVarDecl 0x93f9cb0 <<invalid sloc>> <invalid sloc> 'const char *'
| |-ParmVarDecl 0x93f9d18 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x93f9bf0 <<invalid sloc>> Implicit 829
| `-FormatAttr 0x93f9d98 <col:12> Implicit printf 2 0
|-FunctionDecl 0x93f9dd0 prev 0x93f9b50 <col:1, line:366:28> line:365:12 vfprintf 'int (FILE *, const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93f9880 <col:22, col:39> col:39 __s 'FILE *restrict'
| |-ParmVarDecl 0x93f9900 <col:44, col:67> col:67 __format 'const char *restrict'
| |-ParmVarDecl 0x93f99e0 <line:366:8, col:23> col:23 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x93f9eb8 <<invalid sloc>> Inherited Implicit 829
| `-FormatAttr 0x93f9ee0 <line:365:12> Inherited printf 2 0
|-FunctionDecl 0x93fa0c0 <line:371:12> col:12 implicit vprintf 'int (const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93fa1b8 <<invalid sloc>> <invalid sloc> 'const char *'
| |-ParmVarDecl 0x93fa220 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x93fa160 <<invalid sloc>> Implicit 828
| `-FormatAttr 0x93fa298 <col:12> Implicit printf 1 0
|-FunctionDecl 0x93fa3b0 prev 0x93fa0c0 <col:1, col:74> col:12 vprintf 'int (const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93f9f30 <col:21, col:44> col:44 __format 'const char *restrict'
| |-ParmVarDecl 0x93f9fa8 <col:54, col:69> col:69 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x93fa490 <<invalid sloc>> Inherited Implicit 828
| `-FormatAttr 0x93fa4b8 <col:12> Inherited printf 1 0
|-FunctionDecl 0x93fa730 <line:373:12> col:12 implicit vsprintf 'int (char *, const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93fa828 <<invalid sloc>> <invalid sloc> 'char *'
| |-ParmVarDecl 0x93fa890 <<invalid sloc>> <invalid sloc> 'const char *'
| |-ParmVarDecl 0x93fa8f8 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x93fa7d0 <<invalid sloc>> Implicit 831
| `-FormatAttr 0x93fa978 <col:12> Implicit printf 2 0
|-FunctionDecl 0x93fa9b0 prev 0x93fa730 <col:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:80:49> /usr/include/stdio.h:373:12 vsprintf 'int (char *, const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93fa508 <col:22, col:39> col:39 __s 'char *restrict'
| |-ParmVarDecl 0x93fa588 <col:44, col:67> col:67 __format 'const char *restrict'
| |-ParmVarDecl 0x93fa600 <line:374:8, col:23> col:23 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x93faac0 <<invalid sloc>> Inherited Implicit 831
| |-FormatAttr 0x93faae8 <line:373:12> Inherited printf 2 0
| `-NoThrowAttr 0x93faa68 </usr/include/x86_64-linux-gnu/sys/cdefs.h:80:37>
|-FunctionDecl 0x93fadc8 </usr/include/stdio.h:378:12> col:12 implicit snprintf 'int (char *, unsigned long, const char *, ...)' extern
| |-ParmVarDecl 0x93faec0 <<invalid sloc>> <invalid sloc> 'char *'
| |-ParmVarDecl 0x93faf28 <<invalid sloc>> <invalid sloc> 'unsigned long'
| |-ParmVarDecl 0x93faf90 <<invalid sloc>> <invalid sloc> 'const char *'
| |-BuiltinAttr 0x93fae68 <<invalid sloc>> Implicit 826
| `-FormatAttr 0x93fb010 <col:12> Implicit printf 3 4
|-FunctionDecl 0x93fb048 prev 0x93fadc8 <col:1, line:380:62> line:378:12 snprintf 'int (char *, unsigned long, const char *, ...)' extern
| |-ParmVarDecl 0x93fab38 <col:22, col:39> col:39 __s 'char *restrict'
| |-ParmVarDecl 0x93fabb0 <col:44, col:51> col:51 __maxlen 'size_t':'unsigned long'
| |-ParmVarDecl 0x93fac30 <line:379:8, col:31> col:31 __format 'const char *restrict'
| |-BuiltinAttr 0x93fb190 <<invalid sloc>> Inherited Implicit 826
| |-NoThrowAttr 0x93fb100 </usr/include/x86_64-linux-gnu/sys/cdefs.h:80:37>
| `-FormatAttr 0x93fb158 </usr/include/stdio.h:380:32, col:60> printf 3 4
|-FunctionDecl 0x93fb4f0 <line:382:12> col:12 implicit vsnprintf 'int (char *, unsigned long, const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93fb5e8 <<invalid sloc>> <invalid sloc> 'char *'
| |-ParmVarDecl 0x93fb650 <<invalid sloc>> <invalid sloc> 'unsigned long'
| |-ParmVarDecl 0x93fb6b8 <<invalid sloc>> <invalid sloc> 'const char *'
| |-ParmVarDecl 0x93fb720 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x93fb590 <<invalid sloc>> Implicit 830
| `-FormatAttr 0x93fb7a8 <col:12> Implicit printf 3 0
|-FunctionDecl 0x93fb7e0 prev 0x93fb4f0 <col:1, line:384:62> line:382:12 vsnprintf 'int (char *, unsigned long, const char *, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93fb1d0 <col:23, col:40> col:40 __s 'char *restrict'
| |-ParmVarDecl 0x93fb248 <col:45, col:52> col:52 __maxlen 'size_t':'unsigned long'
| |-ParmVarDecl 0x93fb2c8 <line:383:9, col:32> col:32 __format 'const char *restrict'
| |-ParmVarDecl 0x93fb340 <col:42, col:57> col:57 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x93fb930 <<invalid sloc>> Inherited Implicit 830
| |-NoThrowAttr 0x93fb8a0 </usr/include/x86_64-linux-gnu/sys/cdefs.h:80:37>
| `-FormatAttr 0x93fb8f8 </usr/include/stdio.h:384:32, col:60> printf 3 0
|-FunctionDecl 0x93fbbe0 <line:403:1, line:405:52> line:403:12 vdprintf 'int (int, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x93fb970 <col:22, col:26> col:26 __fd 'int'
| |-ParmVarDecl 0x93fb9f0 <col:32, col:55> col:55 __fmt 'const char *restrict'
| |-ParmVarDecl 0x93fba68 <line:404:8, col:23> col:23 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| `-FormatAttr 0x93fbc98 <line:405:22, col:50> printf 2 0
|-FunctionDecl 0x93fbf08 <line:406:1, line:407:52> line:406:12 dprintf 'int (int, const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fbd18 <col:21, col:25> col:25 __fd 'int'
| |-ParmVarDecl 0x93fbd98 <col:31, col:54> col:54 __fmt 'const char *restrict'
| `-FormatAttr 0x93fbfb8 <line:407:22, col:50> printf 2 3
|-FunctionDecl 0x93fc150 <line:415:12> col:12 implicit fscanf 'int (FILE *restrict, const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fc248 <<invalid sloc>> <invalid sloc> 'FILE *restrict'
| |-ParmVarDecl 0x93fc2b0 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-BuiltinAttr 0x93fc1f0 <<invalid sloc>> Implicit 833
| `-FormatAttr 0x93fc328 <col:12> Implicit scanf 2 3
|-FunctionDecl 0x93fd3f0 prev 0x93fc150 <col:1, line:416:42> line:415:12 fscanf 'int (FILE *restrict, const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fc030 <col:20, col:37> col:37 __stream 'FILE *restrict'
| |-ParmVarDecl 0x93fc0b0 <line:416:6, col:29> col:29 __format 'const char *restrict'
| |-BuiltinAttr 0x93fd4d0 <<invalid sloc>> Inherited Implicit 833
| `-FormatAttr 0x93fd4f8 <line:415:12> Inherited scanf 2 3
|-FunctionDecl 0x93fd5e0 <line:421:12> col:12 implicit scanf 'int (const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fd6d8 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-BuiltinAttr 0x93fd680 <<invalid sloc>> Implicit 832
| `-FormatAttr 0x93fd748 <col:12> Implicit scanf 1 2
|-FunctionDecl 0x93fd780 prev 0x93fd5e0 <col:1, col:55> col:12 scanf 'int (const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fd548 <col:19, col:42> col:42 __format 'const char *restrict'
| |-BuiltinAttr 0x93fd858 <<invalid sloc>> Inherited Implicit 832
| `-FormatAttr 0x93fd880 <col:12> Inherited scanf 1 2
|-FunctionDecl 0x93fda78 <line:423:12> col:12 implicit sscanf 'int (const char *restrict, const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fdb70 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-ParmVarDecl 0x93fdbd8 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-BuiltinAttr 0x93fdb18 <<invalid sloc>> Implicit 834
| `-FormatAttr 0x93fdc50 <col:12> Implicit scanf 2 3
|-FunctionDecl 0x93fdc88 prev 0x93fda78 <col:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:423:12 sscanf 'int (const char *restrict, const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fd8d0 <col:20, col:43> col:43 __s 'const char *restrict'
| |-ParmVarDecl 0x93fd950 <line:424:6, col:29> col:29 __format 'const char *restrict'
| |-BuiltinAttr 0x93fdd90 <<invalid sloc>> Inherited Implicit 834
| |-FormatAttr 0x93fddb8 <line:423:12> Inherited scanf 2 3
| `-NoThrowAttr 0x93fdd38 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-TypedefDecl 0x93fde08 </usr/include/x86_64-linux-gnu/bits/floatn-common.h:214:1, col:15> col:15 _Float32 'float'
| `-BuiltinType 0x934edd0 'float'
|-TypedefDecl 0x93fde78 <line:251:1, col:16> col:16 _Float64 'double'
| `-BuiltinType 0x934edf0 'double'
|-TypedefDecl 0x93fdee8 <line:268:1, col:16> col:16 _Float32x 'double'
| `-BuiltinType 0x934edf0 'double'
|-TypedefDecl 0x93fdf58 <line:285:1, col:21> col:21 _Float64x 'long double'
| `-BuiltinType 0x934ee10 'long double'
|-FunctionDecl 0x93fe150 prev 0x93fd3f0 </usr/include/stdio.h:434:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:247:79> /usr/include/stdio.h:434:24 fscanf 'int (FILE *restrict, const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fdfc0 <col:33, col:50> col:50 __stream 'FILE *restrict'
| |-ParmVarDecl 0x93fe040 <line:435:5, col:28> col:28 __format 'const char *restrict'
| |-BuiltinAttr 0x93fe278 <<invalid sloc>> Inherited Implicit 833
| |-FormatAttr 0x93fe2a0 <line:415:12> Inherited scanf 2 3
| `-AsmLabelAttr 0x93fe1f0 <<scratch space>:32:1> "__isoc99_fscanf" IsLiteralLabel
|-FunctionDecl 0x9409830 prev 0x93fd780 </usr/include/stdio.h:437:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:247:79> /usr/include/stdio.h:437:24 scanf 'int (const char *restrict, ...)' extern
| |-ParmVarDecl 0x93fe2f0 <col:32, col:55> col:55 __format 'const char *restrict'
| |-BuiltinAttr 0x9409950 <<invalid sloc>> Inherited Implicit 832
| |-FormatAttr 0x9409978 <line:421:12> Inherited scanf 1 2
| `-AsmLabelAttr 0x94098d0 <<scratch space>:34:1> "__isoc99_scanf" IsLiteralLabel
|-FunctionDecl 0x9409b18 prev 0x93fdc88 </usr/include/stdio.h:439:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:439:28 sscanf 'int (const char *restrict, const char *restrict, ...)' extern
| |-ParmVarDecl 0x94099c8 <col:37, col:60> col:60 __s 'const char *restrict'
| |-ParmVarDecl 0x9409a48 <line:440:9, col:32> col:32 __format 'const char *restrict'
| |-BuiltinAttr 0x9409c68 <<invalid sloc>> Inherited Implicit 834
| |-FormatAttr 0x9409c90 <line:423:12> Inherited scanf 2 3
| |-AsmLabelAttr 0x9409bb8 <<scratch space>:36:1> "__isoc99_sscanf" IsLiteralLabel
| `-NoThrowAttr 0x9409c40 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9409f10 </usr/include/stdio.h:459:12> col:12 implicit vfscanf 'int (FILE *restrict, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940a008 <<invalid sloc>> <invalid sloc> 'FILE *restrict'
| |-ParmVarDecl 0x940a070 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-ParmVarDecl 0x940a0d8 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x9409fb0 <<invalid sloc>> Implicit 836
| `-FormatAttr 0x940a158 <col:12> Implicit scanf 2 0
|-FunctionDecl 0x940a190 prev 0x9409f10 <col:1, line:461:51> line:459:12 vfscanf 'int (FILE *restrict, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x9409cd8 <col:21, col:38> col:38 __s 'FILE *restrict'
| |-ParmVarDecl 0x9409d58 <col:43, col:66> col:66 __format 'const char *restrict'
| |-ParmVarDecl 0x9409dd0 <line:460:7, col:22> col:22 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x940a2b0 <<invalid sloc>> Inherited Implicit 836
| `-FormatAttr 0x940a248 <line:461:22, col:49> scanf 2 0
|-FunctionDecl 0x940a498 <line:467:12> col:12 implicit vscanf 'int (const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940a590 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-ParmVarDecl 0x940a5f8 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x940a538 <<invalid sloc>> Implicit 835
| `-FormatAttr 0x940a670 <col:12> Implicit scanf 1 0
|-FunctionDecl 0x940a6a8 prev 0x940a498 <col:1, line:468:51> line:467:12 vscanf 'int (const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940a2f0 <col:20, col:43> col:43 __format 'const char *restrict'
| |-ParmVarDecl 0x940a368 <col:53, col:68> col:68 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x940a7c0 <<invalid sloc>> Inherited Implicit 835
| `-FormatAttr 0x940a758 <line:468:22, col:49> scanf 1 0
|-FunctionDecl 0x940b920 <line:471:12> col:12 implicit vsscanf 'int (const char *restrict, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940ba18 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-ParmVarDecl 0x940ba80 <<invalid sloc>> <invalid sloc> 'const char *restrict'
| |-ParmVarDecl 0x940bae8 <<invalid sloc>> <invalid sloc> 'struct __va_list_tag *'
| |-BuiltinAttr 0x940b9c0 <<invalid sloc>> Implicit 837
| `-FormatAttr 0x940bb68 <col:12> Implicit scanf 2 0
|-FunctionDecl 0x940bba0 prev 0x940b920 <col:1, line:473:59> line:471:12 vsscanf 'int (const char *restrict, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940b670 <col:21, col:44> col:44 __s 'const char *restrict'
| |-ParmVarDecl 0x940b6f0 <line:472:7, col:30> col:30 __format 'const char *restrict'
| |-ParmVarDecl 0x940b768 <col:40, col:55> col:55 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x940bce8 <<invalid sloc>> Inherited Implicit 837
| |-NoThrowAttr 0x940bc58 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
| `-FormatAttr 0x940bcb0 </usr/include/stdio.h:473:30, col:57> scanf 2 0
|-FunctionDecl 0x940bf78 prev 0x940a190 <line:479:1, line:483:51> line:479:24 vfscanf 'int (FILE *restrict, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940bd20 <line:480:11, col:28> col:28 __s 'FILE *restrict'
| |-ParmVarDecl 0x940bda0 <line:481:4, col:27> col:27 __format 'const char *restrict'
| |-ParmVarDecl 0x940be18 <col:37, col:52> col:52 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x940c0e0 <<invalid sloc>> Inherited Implicit 836
| |-AsmLabelAttr 0x940c018 <<scratch space>:39:1> "__isoc99_vfscanf" IsLiteralLabel
| `-FormatAttr 0x940c0a8 </usr/include/stdio.h:483:22, col:49> scanf 2 0
|-FunctionDecl 0x940c2b8 prev 0x940a6a8 <line:484:1, line:486:51> line:484:24 vscanf 'int (const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940c120 <col:33, col:56> col:56 __format 'const char *restrict'
| |-ParmVarDecl 0x940c198 <line:485:5, col:20> col:20 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x940c418 <<invalid sloc>> Inherited Implicit 835
| |-AsmLabelAttr 0x940c358 <<scratch space>:41:1> "__isoc99_vscanf" IsLiteralLabel
| `-FormatAttr 0x940c3e0 </usr/include/stdio.h:486:22, col:49> scanf 1 0
|-FunctionDecl 0x940c6c0 prev 0x940bba0 <line:487:1, line:491:51> line:487:28 vsscanf 'int (const char *restrict, const char *restrict, struct __va_list_tag *)' extern
| |-ParmVarDecl 0x940c458 <line:488:8, col:31> col:31 __s 'const char *restrict'
| |-ParmVarDecl 0x940c4d8 <line:489:8, col:31> col:31 __format 'const char *restrict'
| |-ParmVarDecl 0x940c550 <line:490:8, col:23> col:23 __arg 'struct __va_list_tag *':'struct __va_list_tag *'
| |-BuiltinAttr 0x940c850 <<invalid sloc>> Inherited Implicit 837
| |-AsmLabelAttr 0x940c760 <<scratch space>:43:1> "__isoc99_vsscanf" IsLiteralLabel
| |-NoThrowAttr 0x940c7f0 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
| `-FormatAttr 0x940c818 </usr/include/stdio.h:491:22, col:49> scanf 2 0
|-FunctionDecl 0x940c920 <line:513:1, col:33> col:12 fgetc 'int (FILE *)' extern
| `-ParmVarDecl 0x940c888 <col:19, col:25> col:25 __stream 'FILE *'
|-FunctionDecl 0x940ca70 <line:514:1, col:32> col:12 getc 'int (FILE *)' extern
| `-ParmVarDecl 0x940c9d8 <col:18, col:24> col:24 __stream 'FILE *'
|-FunctionDecl 0x940cbe0 <line:520:1, col:25> col:12 getchar 'int (void)' extern
|-FunctionDecl 0x940cd28 <line:527:1, col:41> col:12 getc_unlocked 'int (FILE *)' extern
| `-ParmVarDecl 0x940cc90 <col:27, col:33> col:33 __stream 'FILE *'
|-FunctionDecl 0x940ce70 <line:528:1, col:34> col:12 getchar_unlocked 'int (void)' extern
|-FunctionDecl 0x940cfb8 <line:538:1, col:42> col:12 fgetc_unlocked 'int (FILE *)' extern
| `-ParmVarDecl 0x940cf20 <col:28, col:34> col:34 __stream 'FILE *'
|-FunctionDecl 0x940d210 <line:549:1, col:42> col:12 fputc 'int (int, FILE *)' extern
| |-ParmVarDecl 0x940d078 <col:19, col:23> col:23 __c 'int'
| `-ParmVarDecl 0x940d0f0 <col:28, col:34> col:34 __stream 'FILE *'
|-FunctionDecl 0x940d3f0 <line:550:1, col:41> col:12 putc 'int (int, FILE *)' extern
| |-ParmVarDecl 0x940d2d8 <col:18, col:22> col:22 __c 'int'
| `-ParmVarDecl 0x940d350 <col:27, col:33> col:33 __stream 'FILE *'
|-FunctionDecl 0x940d580 <line:556:1, col:28> col:12 putchar 'int (int)' extern
| `-ParmVarDecl 0x940d4b8 <col:21, col:25> col:25 __c 'int'
|-FunctionDecl 0x940d7a8 <line:565:1, col:51> col:12 fputc_unlocked 'int (int, FILE *)' extern
| |-ParmVarDecl 0x940d690 <col:28, col:32> col:32 __c 'int'
| `-ParmVarDecl 0x940d708 <col:37, col:43> col:43 __stream 'FILE *'
|-FunctionDecl 0x940d988 <line:573:1, col:50> col:12 putc_unlocked 'int (int, FILE *)' extern
| |-ParmVarDecl 0x940d870 <col:27, col:31> col:31 __c 'int'
| `-ParmVarDecl 0x940d8e8 <col:36, col:42> col:42 __stream 'FILE *'
|-FunctionDecl 0x940dae8 <line:574:1, col:37> col:12 putchar_unlocked 'int (int)' extern
| `-ParmVarDecl 0x940da50 <col:30, col:34> col:34 __c 'int'
|-FunctionDecl 0x940dc38 <line:581:1, col:32> col:12 getw 'int (FILE *)' extern
| `-ParmVarDecl 0x940dba0 <col:18, col:24> col:24 __stream 'FILE *'
|-FunctionDecl 0x940de10 <line:584:1, col:41> col:12 putw 'int (int, FILE *)' extern
| |-ParmVarDecl 0x940dcf8 <col:18, col:22> col:22 __w 'int'
| `-ParmVarDecl 0x940dd70 <col:27, col:33> col:33 __stream 'FILE *'
|-FunctionDecl 0x940e100 <line:592:1, col:77> col:14 fgets 'char *(char *restrict, int, FILE *restrict)' extern
| |-ParmVarDecl 0x940ded8 <col:21, col:38> col:38 __s 'char *restrict'
| |-ParmVarDecl 0x940df58 <col:43, col:47> col:47 __n 'int'
| `-ParmVarDecl 0x940dfd0 <col:52, col:69> col:69 __stream 'FILE *restrict'
|-FunctionDecl 0x940e488 <line:632:1, line:634:55> line:632:18 __getdelim '__ssize_t (char **restrict, size_t *restrict, int, FILE *restrict)' extern
| |-ParmVarDecl 0x940e1d0 <col:30, col:48> col:48 __lineptr 'char **restrict'
| |-ParmVarDecl 0x940e248 <line:633:30, col:49> col:49 __n 'size_t *restrict'
| |-ParmVarDecl 0x940e2c8 <col:54, col:58> col:58 __delimiter 'int'
| `-ParmVarDecl 0x940e340 <line:634:30, col:47> col:47 __stream 'FILE *restrict'
|-FunctionDecl 0x940e7c0 <line:635:1, line:637:53> line:635:18 getdelim '__ssize_t (char **restrict, size_t *restrict, int, FILE *restrict)' extern
| |-ParmVarDecl 0x940e560 <col:28, col:46> col:46 __lineptr 'char **restrict'
| |-ParmVarDecl 0x940e5d8 <line:636:28, col:47> col:47 __n 'size_t *restrict'
| |-ParmVarDecl 0x940e6a0 <col:52, col:56> col:56 __delimiter 'int'
| `-ParmVarDecl 0x940e718 <line:637:28, col:45> col:45 __stream 'FILE *restrict'
|-FunctionDecl 0x940eaa8 <line:645:1, line:647:52> line:645:18 getline '__ssize_t (char **restrict, size_t *restrict, FILE *restrict)' extern
| |-ParmVarDecl 0x940e898 <col:27, col:45> col:45 __lineptr 'char **restrict'
| |-ParmVarDecl 0x940e910 <line:646:27, col:46> col:46 __n 'size_t *restrict'
| `-ParmVarDecl 0x940e988 <line:647:27, col:44> col:44 __stream 'FILE *restrict'
|-FunctionDecl 0x940ed10 <line:655:1, col:72> col:12 fputs 'int (const char *restrict, FILE *restrict)' extern
| |-ParmVarDecl 0x940eb78 <col:19, col:42> col:42 __s 'const char *restrict'
| `-ParmVarDecl 0x940ebf0 <col:47, col:64> col:64 __stream 'FILE *restrict'
|-FunctionDecl 0x940ee70 <line:661:1, col:33> col:12 puts 'int (const char *)' extern
| `-ParmVarDecl 0x940edd8 <col:18, col:30> col:30 __s 'const char *'
|-FunctionDecl 0x940f048 <line:668:1, col:43> col:12 ungetc 'int (int, FILE *)' extern
| |-ParmVarDecl 0x940ef30 <col:20, col:24> col:24 __c 'int'
| `-ParmVarDecl 0x940efa8 <col:29, col:35> col:35 __stream 'FILE *'
|-FunctionDecl 0x940f408 <line:675:15> col:15 implicit fread 'unsigned long (void *, unsigned long, unsigned long, FILE *)' extern
| |-ParmVarDecl 0x940f500 <<invalid sloc>> <invalid sloc> 'void *'
| |-ParmVarDecl 0x940f568 <<invalid sloc>> <invalid sloc> 'unsigned long'
| |-ParmVarDecl 0x940f5d0 <<invalid sloc>> <invalid sloc> 'unsigned long'
| |-ParmVarDecl 0x940f638 <<invalid sloc>> <invalid sloc> 'FILE *'
| `-BuiltinAttr 0x940f4a8 <<invalid sloc>> Implicit 839
|-FunctionDecl 0x940f6d0 prev 0x940f408 <col:1, line:676:45> line:675:15 fread 'unsigned long (void *, unsigned long, unsigned long, FILE *)' extern
| |-ParmVarDecl 0x940f110 <col:22, col:39> col:39 __ptr 'void *restrict'
| |-ParmVarDecl 0x940f188 <col:46, col:53> col:53 __size 'size_t':'unsigned long'
| |-ParmVarDecl 0x940f200 <line:676:8, col:15> col:15 __n 'size_t':'unsigned long'
| |-ParmVarDecl 0x940f278 <col:20, col:37> col:37 __stream 'FILE *restrict'
| `-BuiltinAttr 0x940f7c0 <<invalid sloc>> Inherited Implicit 839
|-FunctionDecl 0x940fb28 <line:681:15> col:15 implicit fwrite 'unsigned long (const void *, unsigned long, unsigned long, FILE *)' extern
| |-ParmVarDecl 0x940fc20 <<invalid sloc>> <invalid sloc> 'const void *'
| |-ParmVarDecl 0x940fc88 <<invalid sloc>> <invalid sloc> 'unsigned long'
| |-ParmVarDecl 0x940fcf0 <<invalid sloc>> <invalid sloc> 'unsigned long'
| |-ParmVarDecl 0x940fd58 <<invalid sloc>> <invalid sloc> 'FILE *'
| `-BuiltinAttr 0x940fbc8 <<invalid sloc>> Implicit 840
|-FunctionDecl 0x940fde0 prev 0x940fb28 <col:1, line:682:41> line:681:15 fwrite 'unsigned long (const void *, unsigned long, unsigned long, FILE *)' extern
| |-ParmVarDecl 0x940f830 <col:23, col:46> col:46 __ptr 'const void *restrict'
| |-ParmVarDecl 0x940f8a8 <col:53, col:60> col:60 __size 'size_t':'unsigned long'
| |-ParmVarDecl 0x940f920 <line:682:9, col:16> col:16 __n 'size_t':'unsigned long'
| |-ParmVarDecl 0x940f998 <col:21, col:38> col:38 __s 'FILE *restrict'
| `-BuiltinAttr 0x940fed0 <<invalid sloc>> Inherited Implicit 840
|-FunctionDecl 0x9410120 <line:702:1, line:703:47> line:702:15 fread_unlocked 'size_t (void *restrict, size_t, size_t, FILE *restrict)' extern
| |-ParmVarDecl 0x940ff10 <col:31, col:48> col:48 __ptr 'void *restrict'
| |-ParmVarDecl 0x940ff88 <col:55, col:62> col:62 __size 'size_t':'unsigned long'
| |-ParmVarDecl 0x9410000 <line:703:10, col:17> col:17 __n 'size_t':'unsigned long'
| `-ParmVarDecl 0x9410078 <col:22, col:39> col:39 __stream 'FILE *restrict'
|-FunctionDecl 0x9410408 <line:704:1, line:705:48> line:704:15 fwrite_unlocked 'size_t (const void *restrict, size_t, size_t, FILE *restrict)' extern
| |-ParmVarDecl 0x94101f8 <col:32, col:55> col:55 __ptr 'const void *restrict'
| |-ParmVarDecl 0x9410270 <col:62, col:69> col:69 __size 'size_t':'unsigned long'
| |-ParmVarDecl 0x94102e8 <line:705:11, col:18> col:18 __n 'size_t':'unsigned long'
| `-ParmVarDecl 0x9410360 <col:23, col:40> col:40 __stream 'FILE *restrict'
|-FunctionDecl 0x9410740 <line:713:1, col:63> col:12 fseek 'int (FILE *, long, int)' extern
| |-ParmVarDecl 0x94104d8 <col:19, col:25> col:25 __stream 'FILE *'
| |-ParmVarDecl 0x9410558 <col:35, col:44> col:44 __off 'long'
| `-ParmVarDecl 0x94105d8 <col:51, col:55> col:55 __whence 'int'
|-FunctionDecl 0x9410900 <line:718:1, col:38> col:17 ftell 'long (FILE *)' extern
| `-ParmVarDecl 0x9410808 <col:24, col:30> col:30 __stream 'FILE *'
|-FunctionDecl 0x9410a48 <line:723:1, col:35> col:13 rewind 'void (FILE *)' extern
| `-ParmVarDecl 0x94109b8 <col:21, col:27> col:27 __stream 'FILE *'
|-FunctionDecl 0x9410ce0 <line:736:1, col:63> col:12 fseeko 'int (FILE *, __off_t, int)' extern
| |-ParmVarDecl 0x9410b00 <col:20, col:26> col:26 __stream 'FILE *'
| |-ParmVarDecl 0x9410b78 <col:36, col:44> col:44 __off '__off_t':'long'
| `-ParmVarDecl 0x9410bf8 <col:51, col:55> col:55 __whence 'int'
|-FunctionDecl 0x9410e68 <line:741:1, col:38> col:16 ftello '__off_t (FILE *)' extern
| `-ParmVarDecl 0x9410da8 <col:24, col:30> col:30 __stream 'FILE *'
|-FunctionDecl 0x9411130 <line:760:1, col:72> col:12 fgetpos 'int (FILE *restrict, fpos_t *restrict)' extern
| |-ParmVarDecl 0x9410f20 <col:21, col:38> col:38 __stream 'FILE *restrict'
| `-ParmVarDecl 0x9411018 <col:48, col:67> col:67 __pos 'fpos_t *restrict'
|-FunctionDecl 0x94113e0 <line:765:1, col:56> col:12 fsetpos 'int (FILE *, const fpos_t *)' extern
| |-ParmVarDecl 0x94111f0 <col:21, col:27> col:27 __stream 'FILE *'
| `-ParmVarDecl 0x94112c8 <col:37, col:51> col:51 __pos 'const fpos_t *'
|-FunctionDecl 0x9411530 <line:786:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:786:13 clearerr 'void (FILE *)' extern
| |-ParmVarDecl 0x94114a0 <col:23, col:29> col:29 __stream 'FILE *'
| `-NoThrowAttr 0x94115d8 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9411700 </usr/include/stdio.h:788:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:788:12 feof 'int (FILE *)' extern
| |-ParmVarDecl 0x9411640 <col:18, col:24> col:24 __stream 'FILE *'
| `-NoThrowAttr 0x94117a8 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x94118a8 </usr/include/stdio.h:790:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:790:12 ferror 'int (FILE *)' extern
| |-ParmVarDecl 0x9411810 <col:20, col:26> col:26 __stream 'FILE *'
| `-NoThrowAttr 0x9411950 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9411a48 </usr/include/stdio.h:794:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:794:13 clearerr_unlocked 'void (FILE *)' extern
| |-ParmVarDecl 0x94119b8 <col:32, col:38> col:38 __stream 'FILE *'
| `-NoThrowAttr 0x9411af0 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9411bf0 </usr/include/stdio.h:795:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:795:12 feof_unlocked 'int (FILE *)' extern
| |-ParmVarDecl 0x9411b58 <col:27, col:33> col:33 __stream 'FILE *'
| `-NoThrowAttr 0x9411c98 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9411d98 </usr/include/stdio.h:796:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:796:12 ferror_unlocked 'int (FILE *)' extern
| |-ParmVarDecl 0x9411d00 <col:29, col:35> col:35 __stream 'FILE *'
| `-NoThrowAttr 0x9411e40 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9411f78 </usr/include/stdio.h:804:1, col:36> col:13 perror 'void (const char *)' extern
| `-ParmVarDecl 0x9411eb0 <col:21, col:33> col:33 __s 'const char *'
|-FunctionDecl 0x94120c8 <line:809:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:809:12 fileno 'int (FILE *)' extern
| |-ParmVarDecl 0x9412030 <col:20, col:26> col:26 __stream 'FILE *'
| `-NoThrowAttr 0x9412170 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9412270 </usr/include/stdio.h:814:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:814:12 fileno_unlocked 'int (FILE *)' extern
| |-ParmVarDecl 0x94121d8 <col:29, col:35> col:35 __stream 'FILE *'
| `-NoThrowAttr 0x9412318 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9412418 </usr/include/stdio.h:823:1, col:34> col:12 pclose 'int (FILE *)' extern
| `-ParmVarDecl 0x9412380 <col:20, col:26> col:26 __stream 'FILE *'
|-FunctionDecl 0x94125f0 <line:829:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:281:58> /usr/include/stdio.h:829:14 popen 'FILE *(const char *, const char *)' extern
| |-ParmVarDecl 0x94124d8 <col:21, col:33> col:33 __command 'const char *'
| |-ParmVarDecl 0x9412558 <col:44, col:56> col:56 __modes 'const char *'
| `-RestrictAttr 0x94126a0 </usr/include/x86_64-linux-gnu/sys/cdefs.h:281:47> malloc
|-FunctionDecl 0x94137d0 </usr/include/stdio.h:837:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:837:14 ctermid 'char *(char *)' extern
| |-ParmVarDecl 0x9413738 <col:23, col:29> col:29 __s 'char *'
| `-NoThrowAttr 0x9413878 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9413970 </usr/include/stdio.h:867:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:867:13 flockfile 'void (FILE *)' extern
| |-ParmVarDecl 0x94138e0 <col:24, col:30> col:30 __stream 'FILE *'
| `-NoThrowAttr 0x9413a18 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9413b18 </usr/include/stdio.h:871:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:871:12 ftrylockfile 'int (FILE *)' extern
| |-ParmVarDecl 0x9413a80 <col:26, col:32> col:32 __stream 'FILE *'
| `-NoThrowAttr 0x9413bc0 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9413cb8 </usr/include/stdio.h:874:1, /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:54> /usr/include/stdio.h:874:13 funlockfile 'void (FILE *)' extern
| |-ParmVarDecl 0x9413c28 <col:26, col:32> col:32 __stream 'FILE *'
| `-NoThrowAttr 0x9413d60 </usr/include/x86_64-linux-gnu/sys/cdefs.h:79:35>
|-FunctionDecl 0x9413e60 </usr/include/stdio.h:885:1, col:27> col:12 __uflow 'int (FILE *)' extern
| `-ParmVarDecl 0x9413dc8 <col:21, col:26> col:27 'FILE *'
|-FunctionDecl 0x94140b0 <line:886:1, col:35> col:12 __overflow 'int (FILE *, int)' extern
| |-ParmVarDecl 0x9413f18 <col:24, col:29> col:30 'FILE *'
| `-ParmVarDecl 0x9413f98 <col:32> col:35 'int'
`-FunctionDecl 0x94141b0 <a.c:7:1, line:14:1> line:7:5 main 'int ()'
  `-CompoundStmt 0x94144c0 <col:12, line:14:1>
    |-CallExpr 0x9414330 <line:8:3, col:27> 'int'
    | |-ImplicitCastExpr 0x9414318 <col:3> 'int (*)(const char *, ...)' <FunctionToPointerDecay>
    | | `-DeclRefExpr 0x9414250 <col:3> 'int (const char *, ...)' Function 0x93f91e8 'printf' 'int (const char *, ...)'
    | `-ImplicitCastExpr 0x9414370 <line:3:13> 'const char *' <NoOp>
    |   `-ImplicitCastExpr 0x9414358 <col:13> 'char *' <ArrayToPointerDecay>
    |     `-StringLiteral 0x94142a8 <col:13> 'char[14]' lvalue "Hello World!\n"
    |-CallExpr 0x9414438 <<scratch space>:46:1, a.c:12:33> 'int'
    | |-ImplicitCastExpr 0x9414420 <<scratch space>:46:1> 'int (*)(const char *, ...)' <FunctionToPointerDecay>
    | | `-DeclRefExpr 0x9414388 <col:1> 'int (const char *, ...)' Function 0x93f91e8 'printf' 'int (const char *, ...)'
    | `-ImplicitCastExpr 0x9414478 <line:47:1> 'const char *' <NoOp>
    |   `-ImplicitCastExpr 0x9414460 <col:1> 'char *' <ArrayToPointerDecay>
    |     `-StringLiteral 0x94143e8 <col:1> 'char[7]' lvalue "RISC-V"
    `-ReturnStmt 0x94144b0 <a.c:13:3, col:10>
      `-IntegerLiteral 0x9414490 <col:10> 'int' 0