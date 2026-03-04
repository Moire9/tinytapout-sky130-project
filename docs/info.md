<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# generic CSE 100 lab implementation
To be honest this is not what I wanted to do. My original plan for this
assignment was to implement a simple calculator on one of those generic LCD
modules that all have Hitachi controller clones. The goal was to have the
user input keypresses and they would show up as simple operations on the LCD,
and pressing = would then evaluate what they had typed in and print it to the
right. Like a primitive TI-84. But it was not meant to be. Of the four LCDs
that I own, undertaking this project helped me learn that three of them are
broken, and the only one that isn't has an I2C controller connected to it that
I can't remove. I almost considered turning this into an I2C project, but found
myself facing the prospect of 1) writing a new I2C library for the
microcontroller that I've been using to test the LCDs just for the purpose of
testing this one, because the provided I2C library doesn't support addressless
devices, and 2) porting random C++ code I found somewhere for the undocumented
controller to VERILOG, 3) making I2C actually work (I did find a library
but it didn't have a license attached to it so I can't in good conscience use
it), and 4) ensuring that it actually works properly so I don't accidentally
spend $100 on a small piece of silicon that doesn't do anything (so I would
probably have to convince BELS or a friend to let me borrow an FPGA, and then
adapt the code to the FPGA).

TT still has a while before the sky shuttle... I might pick this back up and
actually do what I wanted to when I have any free time at all.

So what this project actually is is a counter that counts objects passing
before two sensors (see below).

The code is not amazing quality - it's hastily adapated CSE 100 code, I'll be
honest. It has barely scratched the surface of the mind-croggling powers of
openroad. But it's given me a good taste of what I can, and will, be doing. :D

GenAI usage: consulted with some tools for help debugging verilog with limited
success. The `clock_divider` module is something that I wrote filtered through
an LLM because it wasn't working, I ended up copying its output wholesale (did
not fix the problem), later realized it was something completely unrelated
which I quickly fixed but I no longer had my original clock divider code. But
it was almost identical to what is there now, except for minor convention and
naming.

## How it works

The module takes in two inputs, that are to represent active-high presence-
detection sensors (e.g. IR laser interrupted by objects in its path). Assuming
that they are not placed too far apart, the module is capable of determining
whether things that pass in front of the sensors are moving in one direction or
the other. The module keeps a running total of objects that pass before the
sensors, and displays the net number of leftward-passing objects minus the
number of rightwards-passing objects. This is displayed on four seven-segment
display modules with the currently active one selected by one of the output pins.

## How to test

The test script tests the full range of incrementation and decrementation
capabilities. It also logs the 7-segment output at a few points, but it's a bit
hard to interpret.

## External hardware

4-digit 7-segment display with common cathode. Two external sensors of any kind, active high.
