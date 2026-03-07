# "一生一芯"工程项目

我的"一生一芯"工程项目的代码仓库，用于备份防止2026.01.20的那种意外再次发生，同时也用于记录我的过程，会写入一些我觉得印象深刻的东西，以及我的思考。

![GitHub 贡献图](https://ghchart.rshah.org/BTRDFDS)

# 思考
人教人教不会，事教人一教就会

所有的删除操作一定要备份，平时没事就推送一手总是没错的

无论如何不要盲从AI，尤其是当它给出的操作是仅靠自己（不问AI或者不STFW）无法撤销的

AI或许可以告诉你这一行为什么是错的，但是怎么找到这一行，还是得靠自己动手去测试

# 我的进度

2026.01.20 今早起床后发现vscode无法打开，报错与日志如下。分析为最新提交的一个git分支文件为空文件导致的。，且所有的git命令都会返回error: object file is empty fatal: loose object  is corrupt 包括git checkout -f master。我的做法是进入.git/objects/中删除对应文件然后切换至master
然后打开log找到最后一次的提交，通过修改.git\refs\heads里面的trace-ysyx的坐标将其中的空文件替换为旧的提交，成功救回来

2026.01.27 完成了E和F阶段的全部必修任务点，开始申请答辩

2026.02.08 昨天完成的预学习的答辩，今天通过整肃git，恢复了包括E4为主的分支，解决了过去分支由于1.20的崩溃导致的部分错误，保证可以获取到全部的git记录，并进一步提交到了GitHub

2026.02.10 在处理子模块的时候，在未进行备份的情况下误删了am-kernels和fceux-am，且由于此时我的github上面的是子模块，也无法恢复。后来对am-kernels和fceux-am进行了重新克隆。不幸中的万幸是我在am-kernels和fceux-am里面的操作非常少，所以很容易恢复，即PA2开始后的在fceux-am里面就没什么操作，在am-kernels里面也仅仅是改动了makefile，所以很方便恢复，而pa2之前的，不幸中的万幸是我在2026.01.20的那次崩坏事件中备份过，就可以直接从备份中恢复出对应的内容。后来我直接删了所有的子模块，从而保证在我万一遇到问题就可以直接从github上获取完整内容.

2026.02.19 在除夕前夜我还没完成VGA，春节中我在B站发现有大佬做了一个安卓的虚拟机vscode整合[codefa]，于是就顺道读起了代码，于是就想好了怎么实现VGA的处理同步。但是一回到家上电脑就发现能运行但是窗口纯黑没有任何图像。我原本在观察dtrace之后发现了大量的vgsctl的读取，怀疑是video.c有问题，但是在跟踪了一大圈后发现不是，其实这些读取是来自update的，于是转到update，并通过打印对应的FB的内存的变化确认了不是gpu.c和测试程序的问题，于是集中到vga_update_screen。然后，通过一系列的检查，在未发现异常的情况下尝试读取sdl_error，结果在vga_update_screen后获得了That operation is not supported的报错，且发现即使是在无论任何情况下都指执行update_screen的情况下也是存在的，并进而定位到是在update_screen里面，但在update_screen里面直接从一开始就进行读取sdl_error的时候发现That operation is not supported从一开始就已经存在了，进而怀疑到了init_screen里面，并且我在update_screen的前面加上了一段强制写入代码，强制在屏幕的左上角插入一个方形，但是也是不显示，从而加深了怀疑，基本确定就是init的问题。随后，我为init_screen里面添加了6处的sdl_error检查，发现在第二条的SDL_CreateWindowAndRenderer之后就已经发生了That operation is not supported，并通过SDL_ClearError();证明了这里是唯一的错误发生地。后经过求证发现，应该是SDL_CreateWindowAndRenderer的默认选项的问题，它默认使用了 SDL_RENDERER_ACCELERATED 而不是SDL_RENDERER_SOFTWARE，从而导致支持的错误，进而触发了That operation is not supported，后我改用SDL_CreateWindow+SDL_CreateRenderer的手动指定才完成了修正

2026.02.20 重建了我的github仓库，从而消除了热力图缺失的问题。新的GitHub仓库为ysyx-workbench-biruide，旧的ysyx-of-biruide已经被删除用以防止热力图重复统计

2026.02.21 npc的时间读取地址我先设置为了0x02000000+0xBFF8=0x0200BFF8，还有它的+4，修改的文件是npc/csrc/D/ysyx_26020046_minirv.cpp和abstract-machine/am/src/riscv/npc/timer.c

2026.02.22 进行了原版、N、S三版的minirv (其中N是单文件版本的，S是使用了sv的),完成cpu-tests的10次测试，结果如下

|  系列   | 第1次 | 第2次 | 第3次 | 第4次 | 第5次 | 第6次 | 第7次 | 第8次 | 第9次 | 第10次 | 平均值 |
| :-----: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :----: | :----: |
| minirv  |  7.8  | 7.498 | 8.75  | 7.733 | 7.084 | 7.841 | 7.752 | 7.288 | 7.866 | 7.887  | 7.7499 |
| minirvN | 7.11  | 7.011 | 6.922 | 6.662 | 7.339 | 6.328 | 6.898 | 6.957 | 6.182 |  6.98  | 6.8389 |
| minirvS | 7.134 | 5.838 | 7.134 | 6.669 | 7.067 | 7.003 | 6.228 | 7.206 | 7.196 | 6.199  | 6.7674 |

我感觉sv确实是更好用很多，打算后文以sv为主

此外，修改了abstract-machine/klib/include/klib.h的__NATIVE_USE_KLIB__

2026.02.23，测试了klib-test 的10次测试，结果如下

| klib-test |  第1次  |  第2次  |  第3次  |  第4次  |  第5次  |  第6次  |  第7次  |  第8次  |  第9次  |  第10次 | 平均值  |
| :-------: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: |
| minirv    | 11.228  |  9.905  |  9.798  | 11.368  | 11.927  | 10.093  | 11.608  | 11.466  |  9.796  | 11.148  | 10.8337 |
| minirvN   |  8.582  |  8.482  |  8.39   |  6.966  |  8.592  |  7.591  |  8.522  |  8.526  |  8.573  |  8.597  |  8.2821 |
| minirvS   |  8.445  |  8.35   |  6.812  |  8.471  |  8.474  |  8.433  |  8.431  |  6.934  |  8.546  |  6.351  |  7.9247 |

我已经完成了拆分，后续的minirv特指minirvS，原先的重命名为了minirvO。

今天对minirv进行了重大的重构，一方面是修改为systemVerilog，另一方面是将cpp驱动进行了模块化处理，将相当多的流程拆分在子函数中，为sdb的实现打下了基础。

2026.03.06 完成了综合对比 TODO

2026.03.07 完成了RT-thread的三端启动