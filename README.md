# fizzvm

This is a simple stack virtual machine after reading a few articles on the internet, my idea is to make my own programming language with a compiler and bytecode interpreter a little like Java so I can run on different platforms. I have so far done a basic VM that runs pretty well, I soon will write a simple compiler that I can translate my own syntax to the assembly code that will with my VM.
Now the VM loads a text file with an assembly like language and builds a byte array of integers then executes the instructions. Plan to separate the assembler code and the VM interpreter soon I just really testing so bear with me. 
I know there no documentation now I plan to add that with future versions. But feel free to test out some of the examples I included.

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
