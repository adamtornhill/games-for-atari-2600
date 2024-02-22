# Games for Atari 2600

This repo contains my versions of the exercises from two books:
1. Making Games for the Atari 2600 by Steven Hugg. 
2. Programming Games for the Atari 2600 by Oscar Toledo G.
 
Both books are  great, and fun to work through. Recommended!

I have modified and tweaked the code, so these versions differ from the (probably) better versions as they  appear in the books. This is simply my way 
of learning by working more actively with the material.

## The Platform

The Atari 2600 is a curious piece of hardware. Orginally designed with early 70ies arcade hits like Pong and Tank in mind, 
later games radically expanded that space. Doing so required a lot of creativity from the programming pioneers: the Atari 2600 is 
heavily constrained with its 128 bytes(!) of RAM, and limitted types of sprites. 

Of course, that lack of RAM is balanced by a full 4k of ROM at your disposal. That's where you need to fit in code + graphics + sounds. 
Oh, almost: there's also plenty of boiler plate to get your 2600 cartridge initialized, so subtract some bytes from those 4k. 
You see, this platform didn't come with an operating system, meaning you're programming directly to the metal (the amazing 6502 CPU + Atari's proprietary TIA chip). 
It's as low-level as it gets.

Further, a particular challenge when coding for the 2600 is that you have to trace and time the electron beam on the TV to output 
graphics. Just saying.
![image](https://github.com/adamtornhill/games-for-atari-2600/assets/5179769/c21062fa-2001-460f-891f-f04226e493ff)

## Motivation

After reading about this platform from 1977 in other books, I got curious about how those constraints force you to re-think programming strategy. 
Perhaps there's a learning experience here which trancends the specific platform? 
Given that I'm at least 40 years late to the party, I'm clearly not doing this for commercial purposes ;)
