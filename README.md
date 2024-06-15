## Lab works done over 2 semesters of "System programming" on assembler.

### lab1.asm

This assembly code manipulates specific bits of an 8-bit number stored in the dl register and combines these manipulated bits into the dh register. Here's a step-by-step breakdown:
Each step involves copying dl to al, masking with and to isolate specific bits, shifting bits using shr or shl, and combining results into dh with or.

### lab2.asm

The initial code in C++ iterates through a loop and modifies the array A based on certain conditions using a switch statement. The results are printed at the end.
The program will output the values stored in the array A for both the pure C++ implementation and the mixed C++/assembly implementation.
The output should be the same for both sections, ensuring the assembly code replicates the C++ logic accurately.

### lab3.asm

This assembly code defines and manipulates structures in memory, organizing data for further processing.
The overall function of this code is to initialize a set of Node structures, populate their namex fields with names,
and manipulate their field1 arrays according to specific rules. The process is organized into two main segments (Code1 and Code2),
each handling different aspects of the data manipulation.

### lab4.asm

This C++ program with embedded assembly code performs array manipulation and arithmetic operations on byte arrays.
**BigShowN:** Displays the contents of a byte array.
**Big3Sub:** Performs byte-wise subtraction of two arrays with carry handling, storing the result in a third array.
Carry Handling: Manages carry propagation during the subtraction.
Looping and Indexing: Uses loops and register manipulation to iterate over and process arrays.
This program demonstrates integration between C++ and assembly for low-level byte manipulation, useful in scenarios requiring precise control over data and efficient execution.

### lab5.asm

This program demonstrates basic handling of graphics, text display, and mouse events in an assembly language environment,
providing a foundation for more complex graphical and interactive applications.

### lab6.asm

This assembly program, written for the x86 architecture, is designed to handle multiple tasks with time-slicing, using interrupt vectors to manage the tasks and display information on the screen.
The program can handle keyboard inputs, such as the escape key and a function key, to trigger specific actions.

### lab7.asm

This program is designed to demonstrate drawing graphics using assembly language on a VGA screen.
It sets up the screen, scales the coordinate system, and draws a graph based on mathematical functions.
The drawing process involves calculating the necessary coordinates and plotting pixels accordingly.
