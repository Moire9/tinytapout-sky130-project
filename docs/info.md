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

So instead have my CSE 100 Lab 5. In retrospect, the amount of time that I
spent making it work might be more than the amount of time it would have taken
to do the first of the 3 above. I try not to think about that because I value
my happiness.

TT still has a while before the sky shuttle... I might pick this back up and
actually do what I wanted to when I have any free time at all.

<sub><sup>Apologies, dear teach{er, ing assistant}, for what has devolved into
a rant. Sometimes it's good to out your frustration.</sup></sub>

## How it works

The

## How to test

Text test lalala

## External hardware

4-digit 7-segment display with common cathode. Two external sensors of any kind, active high.
