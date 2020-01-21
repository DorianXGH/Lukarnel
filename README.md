# Design Goals

64bits only
nanokernel : Kernel contains only the scheduler and the interrupt receiver (no handling)
kernel-services : separate processes in ring 0 : low-level drivers 
application-services : processes in ring 3 : page allocator, page transferer, process manager, high-level drivers, etc ...

## Syscall
Unique, general purpose syscall "Send". int 0x81, rax : pid of receiver, rbx : 1st page adress, rcx : number of pages. Returns a success code : 0 success, 1 transferer full
Sends the pages to the receiver process.

Each process has a special page setup for the system to tell wich pages were added. It works as a queue. To acknowledge the transfer, put the entry to 0 (better use SSE to make it atomic). In case no free entry could be found to signal an added page : transfer back to the requesting process


### How it works
The interrupt receiver receives the "Send" data, adds a page containing the requested transfer to the page transferer, raises a flag in the scheduler to execute the transferer next and put the page thus transfered's adress in the transfer queue.