# fizzvm

This is a simple stack virtual machine I made after reading a few articles and getting ideas on the subject, my goal is to try and make my own programming language with a compiler and bytecode interpreter a little like Java that can run my little programs on different platforms. 
I have so far done a basic VM that runs some small programs, I soon I hope to write a simple compiler that I can translate my own high-level language to the assembly code then the assembler will compile to bytecode that can executed on my own virtual machine.
With the current version the project loads a plain text file from the command prompt with an assembly like language then builds a byte array of integers then executes the instructions. My idea is to in future versions separate the assembler compiler and the VM interpreter. At this moment I am just really testing so bear with me. 
There is really no documentation yet, I plan to add this with future updates; however, I have left some examples to get you started and get an idea. If you really get stuck, you can contact me or view the source code.


## Compile and running
For this you need Free Pascal or Lazarus, it should be easy to also work it in Delphi as well.

## Example

**Times table lister.**

```
# Display a times table by the number entered from the user.

.globals [0] count
.globals [1] counter
.globals [2] table

iconst 12
istore count
iconst_1
istore counter

# Load chars
iconst_0
iconst ':'
iconst 'r'
iconst 'e'
iconst 'b'
iconst 'm'
iconst 'u'
iconst 'n'

#Print the chars on the stack until 0 is found
print:
 #Print char to screen
 syscall 3
jnz print

#Get number from input
SysCall 4

#The times table to list
istore table

#Display the times table
loop:
 iload counter
 iload table
 mul
 syscall 2
 iload counter
 inc
 istore counter
 
 iload counter
 iload count
 leq
 jt loop
halt
```
