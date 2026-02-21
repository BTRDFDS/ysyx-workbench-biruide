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