---
layout: post
title:  "PyScript: Python in the browser!"
byline: "Can it really replace JavaScript?"
date:   2022-06-05 10:00:00
author: Sebastian Proost
categories: programming
tags:	python web-development pyscript javascript
cover:  "/assets/images/headers/python_code.jpg"
thumbnail: "/assets/images/thumbnails/python_code.jpg"
github: "https://github.com/4dcu-be/PyScript-Basics"
---

At PyCon 2022, [PyScript] was announced as a way to run Python in the browser and it has made waves in the community 
since. While there are some really cool demos included in the project,  the project is still in early stages of 
development and the documentation is lagging a bit behind. So let's have a look at some common things JavaScript
is used for, and how to do the, in PyScript.

All code from this post can be found on [GitHub]. To see the code in action, head over to [http://4dcu.be/PyScript-Basics/](http://4dcu.be/PyScript-Basics/).

## Getting started

We'll create three files, ```index.html```, ```style.css``` and ```main.py```, the former two  will be the html page 
with a css file for some styling while the latter contains our custom code that will run through PyScript.

Let's start with ```index.html```, we'll define the bare minimum here to load PyScript, our css and Python code.

```html
<html>
    <head>
        <title>PyScript Test</title>

        <link rel="stylesheet" href="./style.css">

        <link rel="stylesheet" href="https://pyscript.net/alpha/pyscript.css" />
        <script defer src="https://pyscript.net/alpha/pyscript.js"></script>

    </head>
    <body>
        <p>PyScript status: <span id="pyscript_status">Not Loaded</span></p>

        <button id="clicks" pys-onClick="increase_counter" class="btn">Count 0</button>
        <button id="toggle" pys-onClick="toggle_text" class="btn">Show Text</button>

        <p id="toggle_text" class="hidden">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus cursus 
          mauris mauris, vel fermentum risus hendrerit tincidunt. Aliquam pulvinar tellus et iaculis vestibulum. In 
          pharetra diam eu lectus dignissim tristique. Phasellus laoreet vulputate urna. Fusce vitae elit sodales, 
          tempus dui in, scelerisque magna.</p>
        
        <br />
        <button id="clicks_class" pys-onClick="test_class.inc" class="btn">Count <strong>0</strong></button>

        <py-script src='./main.py'></py-script>
    </body>
</html>
```

And a little css to be able to hide the text field, and a bit I grabbed from [w3schools] to make the buttons look 
like actual buttons.

```css
body {
    padding: 15px;
}


.hidden {
    display: none;
}

.btn {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 15px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
  }
```

## Connecting it to Python

There are two hooks in the code that PyScript will use to run the code in ```main.py```. At the bottom of the body there
is the tag ```<py-script src='./main.py'></py-script>``` which will specify there is an external file that needs to
be run once the page is loaded. This concept is identical to how you would include a bit of JavaScript code with 
```<script>``` tags.

In the button code you can specify which function needs to be run when the button is clicked. Adding an attribute 
```pys-onClick="increase_counter"``` to the element you want to be clickable. In the code above on button will run the function 
```increase_counter``` (which is included in ```main.py```) every time it is clicked and the other ```toggle_text```.

Apart from that it is important to make sure elements you want the Python code to interact with have an identifier. 
Though this would be the case for adding vanilla JavaScript to a webpage as well. 

## The Python Code

```python
counter = 0

pyscript.write('pyscript_status', 'PyScript Loaded Successfully')

def increase_counter(*ags, **kws):
    global counter
    counter += 1
    button = Element('clicks')
    button.element.innerHTML = f"Count {counter}"

def toggle_text(*ags, **kws):
    text = Element('toggle_text')
    button = Element('toggle')

    if "hidden" in text.element.classList:
        text.remove_class("hidden")
        button.element.innerHTML = "Hide Text"
    else:
        text.add_class("hidden")
        button.element.innerHTML = "Show Text"

class Test():
    def __init__(self) -> None:
        self.counter = 0
        self.text_element = Element('clicks_class')

    def inc(self, *ags, **kws):
        self.counter += 1
        self.text_element.element.innerHTML = f"Count <strong>{self.counter}</strong>"

test_class = Test()
```

Once our html page is loaded, the script above will be run. And the first way to interact with the elements on the
webpage is using ```pyscript.write()```, the first argument specifies to which element (by id) you want to write a bit of
text, defined in the second argument. In this case we'll update the pyscript_status element to read 
 "PyScript Loaded Successfully". This is not only a good example to show the easiest way to interect with the DOM, but
also provides a visual confirmation our code is being executed.

The next bit defines what happens when the count buttons is pressed. Two things are important here, the use of a 
```global``` variable to keep track of the count and how the text is set here. Since we have to keep track of the count
in a variable outside of the function, the global variable ```button = Element('clicks')``` will
create a Python object that links with the DOM element with id "clicks". Now we can change the innerHTML of that element
to read what we want. This has one advantage over ```pyscript.write()```, you can include html into an element this way.
If for instance we wanted to make the number bold we could simpy use the line below:

```python
button.element.innerHTML = f"Count <strong>{counter}</strong>"
```

## Interacting with Class Attributes

The last function in the example is to show how you can interact with the classes assigned to an element. This is
useful to change the appearance of elements on the fly by switching to a class with a different style defined in the 
CSS file or simply hide/show an element as shown here.

Using ```Element()``` the button and text field are selected, next, to check if the text is hidden or not the 
```classList``` of the text is accessed. This list contains all the classes currently linked with the DOM element, to
check if the element has a certain class, a simple check if that class occurs in the list is enough. Here we check if
the element is hidden or not, if it is that class is removed using ```text.remove_class("hidden")``` otherwise we add 
the hidden-class with ```text.add_class("hidden")```. In both cases the button's text is set accordingly.

## Using a Python Class

The global variable in the first example isn't very elegant. Neither is running the ```Element()``` function on each
button click. Using a class we can avoid this! With a test class, you can create a property for the current count and
the elements you want to interact with. Next, we add an ```inc``` function to increase the counter, have a look at how
the arguments are structured, first self, than the args and kwargs PyScript needs. At the end of ```main.py``` we create
an instance of this class called ```test_class```. In the html code we can link the inc function within that instance 
using ```pys-onClick="test_class.inc"```.

While in a small example that doesn't seem to make things easier (it actually is one line of code mode), for more
complex apps this is a much better way to manage the app's state. 

# Conclusion

From the examples here it is clear that also common things vanilla JavaScript is often used for can be done using 
PyScript. It takes a bit of tinkering due to the lack of documentation, but a quick glance at the source code was often
enough to figure things out. However, the requirement of the Python runtime to be fetched add a substantial loading time
to a webpage, so this could be a deal-breaker in a few cases.

Though where you have some logic implemented in Python already, this could speed up turning that code into an app
substantially. A current goto project to test new packages, tools, ... [WinstonCubeSim] I was able to turn into a working
web app, including a few cool extra features (like fetching data from an external API) in an evening or two. Porting
everything to JavaScript would have taken me longer, and now there is only one codebase to maintain for the CLI and
web version. The app is quite niche, but check out [WinstonCubeSimPyScript] if you want to see the results.

# To Downside of PyScript

Despite these being rather simple examples, as PyScript still lacks documentation, I had to dive into the source-code
once or twice to figure things out. This is to be expected at this stage, and will improve over time. Given this project
is in alpha, things are likely to change anyway, so writing docs which will need to be re-written later anyway isn't
very productive for the team. No judgement there, but if you want to dive in prepare to do some extra work.

There are some nice examples included in the PyScript package, though these are somewhat focused on data science. While
I can't wait to test that out further, people hoping to replace some vanilla JavaScript with Python might struggle to
find what they need.

The loading time is substantial. Efficient caching of a website could alleviate this issue, though on first load the
entire Python runtime in WASM needs to be fetched. Unfortunately, the only way to avoid this is if PyScript would be
baked into the browser like JavaScript is. It is a little early, but some day, maybe ... 

# Further Reading

  * [WinstonCubeSimPyScript] : WebApp using PyScript that implements these bits of code to create a UI for an existing library
  * [PyScript] : Official website
  * [Python + pyscript + WebAssembly: Python Web Apps, Running Locally with pyscript](https://www.youtube.com/watch?v=lC2jUeDKv-s) : Tutorial how to get started with PyScript and turn your code into Progressive Web App

[w3schools]: https://www.w3schools.com/css/css3_buttons.asp
[WinstonCubeSimPyScript]: https://github.com/4dcu-be/WinstonCubeSimPyScript
[WinstonCubeSim]: https://github.com/4dcu-be/WinstonCubeSim
[PyScript]: https://pyscript.net/
[GitHub]: https://github.com/4dcu-be/PyScript-Basics
