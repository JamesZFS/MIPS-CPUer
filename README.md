# MIPS-CPUer
An implementation of MIPS32 based on Thinpad. (The big project of Computer Organization course)

## 主要文件及目录说明

我们的项目源文件根目录是 `cod19grp16/`

- assets/：用于demo的监控程序bin文件、图片数据等文件；
- demo/：用于demo的软件源码目录
  - fpn.cpp：定点小数系统的C代码，用汇编实现的时候参考的这份代码；
  - kernel/：源自mipslab的监控程序文件夹，内有许多改动和新增；
    - kern/
      - cv.S：汇编实现的图形处理库，含绘制点、矩形、图片的函数；
      - fpn.S：汇编实现的定点小数系统，支持加减乘除和开根号；
      - init.S：修改了部分逻辑的监控程序入口；
      - threebody.S：汇编实现的三体运动demo程序，内含距离、引力计算、逐帧计算更新函数、模拟绘制主循环等。原理示意的C代码请参见实验报告；
  - term/：源自mipslab的term程序文件夹，内有一些小改动；
- sim-waves/：仿真的波形配置；
- thinpad_top.srcs/：硬件设计的源码目录
  - sim_1/new/tb.sv：仿真testbench源码；
  - sources_1/new/：主要的硬件设计源文件目录
    - defs.v：全局宏定义；
    - dvi.v：DVI信号生成器；
    - mips.v：MIPS32流水线模块，实例化了大部分CPU流水线的模块并连线；
    - mmu.v：内存管理单元；
    - thinpad_top.v：顶层设计源文件，内实例化了mips, mmu, blockram, dvi 等；
    - modules/：流水线各模块源文件目录
      - 内含 control, inst_decoder, memory …… 等各模块的源代码，注释丰富，读者可以自行查看；
- thinpad_top.runs/impl_1/thinpad_top.bit：比特流文件，可烧进板子。



## 部署与运行

1. 在 Vivado 软件上，点击 Generate Bitstream 即可生成比特流文件，或是直接用我们事先编译好的`thinpad_top.runs/impl_1/thinpad_top.bit` 烧进 thinpad；
2. 将assets目录下的三个 kernelx.bin 选一个烧进 Flash 的0地址；（三个bin对应三种三体运动模拟参数）
3. 将`assets/welcome.bin` 图片烧进 Flash 的 0x400000 地址处，`assets/blackhole.bin` 烧进 0x475300 地址处；
4. 可能需要重新烧一次bit文件；
5. 长按板子上最右边的 button（大约1s），启动“**恢复出厂设置**”功能，硬件会自动将Flash存储的内容拷贝到BaseRAM和ExtRAM里，监控程序就跑起来了。可看到led灯和数码管显示变得比较规律；
6. 用 python3 运行 `demo/term/term.py`  （注意要用我们提供的term，勿用mipslab原有的term），连接上板子；
7. 可以用g命令测试一下几个我们编写的单元测试，入口地址可以在 `demo/kernel/` 文件夹下运行 `make all` 看到；
8. 可以运行我们的demo程序，方法是在term里输入 p ，然后回车，这时候可以看到板子接的dvi显示上出现三体运动画面，amazing！
9. 暂停尚不支持，可以通过点击恢复出厂设置按钮来完成。



