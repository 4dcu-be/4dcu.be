---
layout: post
title:  "Kindle + Python = e-Ink Dashboard (part 1)"
byline: "repurposing an old kindle paperwhite 3"
date:   2020-09-27 12:00:00
author: Sebastian Proost
categories: diy
tags:	python kindle dashboard
cover:  "/assets/posts/2020-09-27-PythonKindleDashboard_1/kindle_pw3.jpg"
thumbnail: "/assets/images/thumbnails/kindle_pw3.jpg"
github: "https://github.com/4dcu-be/kual-dashboard"
---

Kindles have amazing e-Ink displays, if we can manage to install Python on one, we could turn an old kindle into a
low-power dashboard! An old Kindle is also considerably cheaper than a new e-Ink display module that can be hooked up to 
a Raspberry Pi. So it makes a lot of sense to repurpose my old Kindle that has issues. Even after replacing the battery, 
it lasts only 2-3 days when being used moderately. That isn't nearly enough during trips where it can't be charged daily. 
While I will buy a new ebook reader sooner or later, I really hate to throw an otherwise fine device away. Especially one that has a great display
that still works perfectly fine. Fortunately, I found a way to repurpose it and breath some new life into this device.

![All parts needed for the serial jailbreak](/assets/posts/2020-09-27-PythonKindleDashboard_1/all_parts.jpg)

## Installing Python on the Kindle

As you can't install additional software on a stock kindle, you have to jailbreak it first. This will void your
warranty, so in case you want to try and do so it is at your own risk. There are two main ways to do this:

  * Upgrade to a specific firmware that can be broken and use a software jailbreak (your current version needs to 
  be older than the firmware that can be broken). Details can be found [here](https://www.mobileread.com/forums/showthread.php?t=320564) 
  and [here](https://www.mobileread.com/forums/showthread.php?t=313086).
  * Open the kindle, solder wires to the serial port, connect to it using a computer and log into the device to
  apply a jailbreak. Use [this guide](https://www.mobileread.com/forums/showthread.php?t=267541), if you want to give this method a shot.

For the serial jailbreak, apart from a soldering iron and a few wires, you'll also need a USB to Serial stick. There
are plenty of these to be found on Amazon, eBay, ... but make sure you have a model that supports **1.8 V** as this is what
the Kindle requires. 

![USB to serial stick that support 1.8, 3.3 and 5V](/assets/posts/2020-09-27-PythonKindleDashboard_1/usb_to_serial.jpg)

As my firmware version was too new for the software jailbreak I stared with the serial/hardware jailbreak. After connecting it to my computer it wouldn't 
accept the root password (potentially because I had done the software jailbreak before and lost it updating to the
latest version in an attempt to solve the battery issue). So I couldn't jailbreak my device that way either. However, 
while you are connected via a serial port to the kindle and have a usb cable connected you can boot it in 
**recovery mode** (hit enter at the right time during the boot), and from there you can **export the partition table**. At that point
the kindle will show up as a usb storage device on your computer and you will be able to copy any firmware binary to the root of the kindle 
and from the command line force the installation, effectively downgrading your kindle (You can't copy the old firmware 
first, as it will be removed when rebooting the device). Now the software jailbreak can be used.

![Wires soldered in place](/assets/posts/2020-09-27-PythonKindleDashboard_1/soldering.jpg)

Once you have successfully jailbroken the Kindle, install [KUAL](https://www.mobileread.com/forums/showthread.php?t=203326). 
This is a launcher that allows other packages to be started from a menu. Next, install the MobileRead Package Installer
aka. [MRPI](https://www.mobileread.com/forums/showthread.php?t=251143), which will simplify the next step. Finally,
we'll need Python 3.8, which you can find [here](https://www.mobileread.com/forums/showthread.php?t=225030). Drop the
binaries in the right folder, from KUAL start MRPI and they will be installed.

![Success, Python is installing](/assets/posts/2020-09-27-PythonKindleDashboard_1/python_installing.jpg)

## Creating a KUAL extension

Python is installed and KUAL provides us with a way to start our script. Let's start to build a KUAL extension. Here
we'll just discuss the boilerplate code, the dashboard python script will be discussed in the next post. The file 
structure of our extension can be seen below, the folder `dashboard` will need to be copied to the `extensions` folder 
on the kindle.


```text
│   .gitignore
│   README.md
│
└───dashboard
    │   config.xml
    │   menu.json
    │
    ├───bin
    │       run.py
    │       start.sh
    │       start_once.sh
    │
    └───cache
```

There are two files which are essential for the KUAL extension `config.xml` and `menu.json`, these you can see below. 
They are mostly self-explanatory, however make sure the id in the config file matches the name of your extension's 
folder (in this case dashboard). In `menu.json` you can define where you want buttons to start your script in KUAL's
menu (here they are in the main menu). As the dashboard script (`start.sh`) goes into an infinite loop, requiring the kindle to 
be restarted to stop it, for debugging/testing purposes there is also a version included that will run only one loop to
test if everything is in order (`start_once.sh`).

`run.py` is a placeholder that will be discussed in the next post, this is the python script that will get the data 
online and turn it into something we can display on the Kindle.

**config.xml**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<extension>
    <information>
        <name>Dashboard 4DCu.be</name>
        <version>0.1</version>
        <author>4DCu.be - Sebastian Proost</author>
        <id>dashboard</id>
    </information>
    <menus>
        <menu type="json" dynamic="true">menu.json</menu>
    </menus>
</extension>
```

**menu.json**
```json
{
    "items": [
    {
        "name": "Dashboard 4DCu.be",
        "priority": -999,
        "exitmenu": false,
        "refresh": false,
        "status": false,
        "action": "./bin/start.sh"
    }, {
        "name": "Dashboard 4DCu.be (Debug)",
        "priority": -998,
        "exitmenu": false,
		"refresh": false,
		"status": false,
        "action": "./bin/start_once.sh"
    }
    ]
}
```

For the actual dashboard all files are in the `bin` folder, where there is a shell script, `start.sh`, that will run the python
script, put the system into a deep sleep and repeat once it wakes up. Note that this script will run forever and the kindle
needs to be restarted to kill it. While this is fine for a dashboard, for debugging/testing this is a little annoying,
therefore a script `start_once.sh` is included, which will run the script once and stop.

**bin/start.sh**
```bash
#!/bin/sh

cd "$(dirname "$0")"

/usr/sbin/eips -c
/usr/sbin/eips 15  4 'Starting 4DCu.be Dashboard'

while true
do
    # Make sure there is enough time to reconnect to the wifi
    sleep 30
    # Refresh Dashboard
    python3 /mnt/base-us/extensions/dashboard/bin/run.py
    sleep 5

    echo "" > /sys/class/rtc/rtc1/wakealarm
    # Following line contains the sleep time in seconds
    echo "+3600" > /sys/class/rtc/rtc1/wakealarm
    # Following line will put device into deep sleep until the alarm above is triggered
    echo mem > /sys/power/state
done
```

With these scripts in place everything is set up to start working on the Python code that will grab some data and 
display it on the screen. However, that will be discussed in the next post, for now you look at the picture below that
shows KUAL with our own freshly created buttons, that will soon run some Python code to do our bidding.

![KUAL is all set up to start our code](/assets/posts/2020-09-27-PythonKindleDashboard_1/kual_menu.jpg)

## Conclusion

While not without issues, it was possible to jailbreak the Kindle Paperwhite 3, install Python and run custom code on
it. This means everything is ready to start hacking together a few scripts to actually turn the kindle into a dashboard.
Stay tuned as this will come up in the [next post]({% post_url 2020/2020-10-04-PythonKindleDashboard_2 %}).

