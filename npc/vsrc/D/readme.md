## minirv

# ALU 
负责根据控制信号控制ALU, 对数据进行计算

input:cRd 控制写入寄存器的结果,oR1 oR2 寄存器输出值,imm 立即数,snpc 静态接续地址,control 控制信号

output:oRd 计算结果,addr 输出地址

# Reg register
处理寄存器，接收外部的写入并输出值到ALU

input :clk 时钟,wdata 写入数据,waddr 写入地址,wen 使能, cR1 cR2 读出的地址

output:oR1 oR2读出的数据

# IDC Instruction Decode Controller
负责对指令进行解码，并输出到ALU
input :code 指令

output:imm 立即数,r1,r2,rd 寄存器地址,wen 写入使能

# LSU Load-Store Unit
读写控制器，负责对内存进行读写操作，同时更新pc

input:clk 时钟,addr 地址,rd 写入寄存器地址,wdata 写入数据,wen 写入使能

output:addr 输出地址,wdata 写入数据,wen 写入使能,pc 更新后的pc