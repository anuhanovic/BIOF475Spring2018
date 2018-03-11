### Here is the "Hello, World" programme in Python, R and a couple more programming languages.

### ALGOL
```
BEGIN DISPLAY("HELLO WORLD!") END.
```
### AspectJ
```
// HelloWorld.java
public class HelloWorld {
    public static void say(String message) {
        System.out.println(message);
    }

    public static void sayToPerson(String message, String name) {
        System.out.println(name + ", " + message);
    }
}

// MannersAspect.java
public aspect MannersAspect {
    pointcut callSayMessage() : call(public static void HelloWorld.say*(..));
    before() : callSayMessage() {
        System.out.println("Good day!");
    }
    after() : callSayMessage() {
        System.out.println("Thank you!");
    }
}
```
### AppleScript
```
say "Hello, world!"
```
### Assembly language
```
    global  _main
    extern  _printf

    section .text
_main:
    push    message
    call    _printf
    add     esp, 4
    ret
message:
    db  'Hello, World', 10, 0
```
### Bash (Unix Shell)
```
#!/bin/bash
echo "Hello World!"
```
### BASIC
```
10 PRINT "Hello, World!"
20 END
```
### C
```
#include <stdio.h>

int main(void)
{
    printf("hello, world\n");
}
```
### C++
```
#include <iostream>

int main()
{
    std::cout << "Hello, world!\n";
    return 0;
}
```
### C#
```
using System;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Hello, world!");
    }
}
```
### Caml (Ocaml)
```
print_endline "Hello, world!";;
```
### Clojure (ClojureScript)
```
(println "Hello world!")
```
### COBOL
```
 IDENTIFICATION DIVISION.
 PROGRAM-ID. hello-world.
 PROCEDURE DIVISION.
     DISPLAY "Hello, world!"
     .
```
### CoffeeScript
```
console.log "Hello, World!"
```
### Dart
```
main() {
  print('Hello World!');
}
```
### dBase (FoxPro)
```
 ? "Hello World"
```
### Delphi (Object Pascal)
```
procedure TForm1.ShowAMessage;
begin
  ShowMessage('Hello World!');
end;
```
### Eiffel
```
class
    HELLO_WORLD
create
    make
feature
    make
        do
            print ("Hello, world!%N")
        end
end
```
### Erlang
```
 -module(hello).
 -export([hello_world/0]).

 hello_world() -> io:fwrite("hello, world\n").
```
### Elixir
```
IO.puts "Hello World!"
```
### F#
```
open System
Console.WriteLine("Hello World!")
```
### Fortran
```
program helloworld
     print *, "Hello world!"
end program helloworld
```
### Go
```
package main

import "fmt"

func main() {
    fmt.Println("Hello, World")
}
```
### Groovy (Ruby)
```
println "Hello World"
```
### Haskell
```
module Main where

main :: IO ()
main = putStrLn "Hello, World!"
```
### IBM RPG
```
dcl-s wait char(1);

dsply ( 'Hello World!') ' ' wait;

*inlr = *on;
```
### Java
```
class HelloWorldApp {
    public static void main(String[] args) {
        System.out.println("Hello World!"); // Prints the string to the console.
    }
}
```
### JavaScript (ECMAScript)
```
console.log("Hello World!");
```
### LaTeX
```
\documentclass[a4paper]{article}
\begin{document}
Hello world!
\end{document}
```
### Lisp
```
(print "Hello world")
```
### Logo
```
TO HELLO
        PRINT [Hello world]
        END
```
### Lua
```
print("Hello World!")
```
### Machine code
```
b8    21 0a 00 00   #moving "!\n" into eax
a3    0c 10 00 06   #moving eax into first memory location
b8    6f 72 6c 64   #moving "orld" into eax
a3    08 10 00 06   #moving eax into next memory location
b8    6f 2c 20 57   #moving "o, W" into eax
a3    04 10 00 06   #moving eax into next memory location
b8    48 65 6c 6c   #moving "Hell" into eax
a3    00 10 00 06   #moving eax into next memory location
b9    00 10 00 06   #moving pointer to start of memory location into ecx
ba    10 00 00 00   #moving string size into edx
bb    01 00 00 00   #moving "stdout" number to ebx
b8    04 00 00 00   #moving "print out" syscall number to eax
cd    80            #calling the linux kernel to execute our print to stdout
b8    01 00 00 00   #moving "sys_exit" call number to eax
cd    80            #executing it via linux sys_call
```
### Mathematica (Wolfram Language)
```
CloudDeploy["Hello, World"]
```
### MATLAB
```
classdef hello
    methods
        function greet(this)
            disp('Hello, World')
        end
    end
end
```
### ML
```
print "Hello world!\n";
```
### Node.js
```
console.log("Hello World!");
```
### Objective-C
```
main()
{
  puts("Hello World!");
  return 0;
}
```
### Pascal
```
program HelloWorld(output);
begin
  Write('Hello, world!')
end.
```
### Perl
```
print "Hello, World!\n";
```
### PHP
```
<?php echo "Hello, World";
```
### PowerShell
```
Write-Host "Hello, World!"
```
### Python2
```
print "Hello World"
```
### Python3
```
print("Hello World")
```
### R
```
cat("Hello world\n")
```
### RPG
```
dcl-s wait char(1);

dsply ( 'Hello World!') ' ' wait;

*inlr = *on;
```
### Ruby
```
puts 'Hello World!'
```
### Rust
```
fn main() {
    println!("Hello, world!");
}
```
### Scala
```
 object HelloWorld extends App {
   println("Hello, World!")
 }
```
### Stata
```
display "Hello, world"
```
### Scheme
```
(let ((hello0 (lambda() (display "Hello world") (newline))))
  (hello0))
```
### Scratch
```
say Hello, World!
```
### Self
```
'Hello, World!' print.
```
### Smalltalk
```
Transcript show: 'Hello World!'.
```
### Swift
```
println("Hello, world!")
```
### Tcl
```
puts "Hello World!"
```
### TypeScript
```
console.log("Hello World!");
```
