---
layout: post
title:  "GameBoy Zero Builds"
byline: ""
date: 2021-01-31 12:00:00
author: Sebastian Proost
categories: diy games
tags:	gameboy retrogaming raspberry-pi
cover:  "/assets/posts/2021-01-31-Gameboy-Zero/mkII.jpg"
thumbnail: "/assets/images/thumbnails/gbz_mkII.jpg"
gallery_items:
  - image: "/assets/posts/2021-01-31-Gameboy-Zero/mkII.jpg"
    gallery_image: "/assets/images/gallery/gbz_mkII.jpg"
    description: "New GameBoy Zero based on Kite's Circuit Sword Lite"  
  - image: "/assets/posts/2021-01-31-Gameboy-Zero/mkII_back.jpg"
    gallery_image: "/assets/images/gallery/gbz_mkII_back.jpg"
    description: "New GameBoy Zero based on Kite's Circuit Sword Lite"
---

About a year ago I build a GameBoy Zero (a Raspberry Pi Zero in a gameboy shell) and this weekend I finished a second
one. You can see some picture of the first one (black case) and the new one (transparant, blue shell) below. While I 
thought about doing a proper build log, there are others who did a much better job at documenting how to build one than
I would have. So if you are interested in building on of there for yourself, have a look at the link at the bottom, 
otherwise enjoy the pictures.

## New Build

![New GameBoy Zero based on Kite's Circuit Sword Lite](/assets/posts/2021-01-31-Gameboy-Zero/mkII.jpg)

![Backside has buttons with button membranes, big improvement over the clicky buttons from the previous build](/assets/posts/2021-01-31-Gameboy-Zero/mkII_back.jpg)

This is the second GameBoy Zero I've built. This one is based on Kite's Circuit Sword Lite, which has a few advantages
over the Super-AIO board he released earlier. There is a PCB to have buttons on the back that use the same membranes as
the ABXY buttons on the front, much better than the "clicky" ones I used in the previous build. Furthermore, I used all 
available 3D printed parts, ensured wires were the right length, and only added a few dabs of hot glue strategically. 
So the inside part is very clean, as it should be, since it is visible through the translucent case. Very happy how 
this one turned out.

## Old Build

![GameBoy Zero based on Kite's Super AIO board](/assets/posts/2021-01-31-Gameboy-Zero/mkI.jpg)

![Two clicky shoulder buttons on the back, they are functional, but I would recommend to go for a solution with membrane buttons](/assets/posts/2021-01-31-Gameboy-Zero/mkI_back.jpg)

First build, looks great on the outside, but the inside is a little messy. There were a few issues with the soldering 
(my iron broke completing the last few connections and probably wasn't running at the correct temperature for most of 
this project), and as I didn't use as many 3D Printed parts as I should have, a lot of hot glue is used to keep things 
in place. The shoulder buttons however aren't great and make playing some GBA and SNES games annoying (and loud as they 
are "clicky"). It is still a great device for playing games that don't rely on the shoulder buttons (much).

## Links

Here is an overview of resources I used for my builds. Note that depending on the board you use, and the options you want,
you might need to check additional websites. 

  * [SudoMod forum](https://www.sudomod.com/forum/): Here you can find a ton of information... Start here! In the 
    Buy/Sell section you'll also find threads to order the boards you need.
  * [Arron Morris' Build](https://www.youtube.com/playlist?list=PLhG82WTD_pxLJjDrb0UpIAFgRRK_CbOB2): You can see how
he build his. While using a different board, a lot of the steps are the same for the Super-AIO and Circuit Sword Lite.
  * [Retro Ghost's Build](https://www.youtube.com/playlist?list=PLDrHbgEPUBbAccWP-X5YRft1sgdaoUCxd): Step-by-step
instructions how Retro Ghost build his GBZ using a Circuit Sword Lite.
  * [Kite's GitHub Repo](https://github.com/kiteretro/Circuit-Sword-Lite/wiki) - For the Circuit Sword Lite: Official
  instructions how to set up the electronics. The Circuit Sword Lite comes as a kit with all electronics you need.
  * [Kite's GitHub Repo](https://github.com/kiteretro/Super-AIO) - For the Super-AIO board: this one is now a little
    obsolete. Though, the archived manual contains a lot of information still worth having a look at.
