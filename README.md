[PAUSED] Developpement of a zig kernel is paused while the language is unstable. It will resume once the language is more mature and issue 3133 is solved. Zig is a wonderful language, its design is very good IMO and will be ideal for OSdev once bugs on packed structures are solved, and the definitive kernel of my would-be OS will be in zig. The specification of the page transfer protocol is being written and inter-process communication relative to OS tasks like memory management, process management and scheduling, etc, will eventually be "protocolized" in order to make drop-in replacements possible.

# Design Goals

* 64bits only
* nanokernel : Kernel contains only the context switching and the interrupt receiver (no handling)
* kernel-services : separate processes in ring 0 : low-level drivers 
* application-services : processes in ring 3 : page allocator, page transferer, process manager, high-level drivers, etc ...

## Syscall
Page Transfer Protocol, no syscalls necessary in theory (in practice, it's not implemented so this goal may be impossible to reach).
