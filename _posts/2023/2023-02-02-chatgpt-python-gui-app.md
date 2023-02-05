---
layout: post
title:  "Can ChatGPT write a Python GUI app for me?"
byline: ""
date:   2023-02-02 10:00:00
author: Sebastian Proost
categories: programming
tags:	python chatgpt ai 
cover:  "/assets/posts/2023-02-02-chatgpt-python-gui-app/header_chatgpt.jpg"
thumbnail: "/assets/images/thumbnails/chatgpt_gui_app.jpg"
---

Imagine being able to create a fully functioning Python GUI application with just providing instructions. No need to spend 
hours writing and debugging code, you'd just let AI do the heavy lifting for you. In this post, we'll explore the capabilities 
of [ChatGPT] in developing a Python GUI app and discover just how easy it can be to bring your ideas to life.

In this post, we will be creating a simple yet powerful Python GUI application that helps users generate captions for 
images quickly and efficiently. The app will display an image and provide a user interface for the user to write a 
caption for that image, which will then be saved in a corresponding text file. This can greatly speed up the process 
of creating captions for images, which is an essential step in training other AI systems like [Stable Diffusion].

When working on larger projects with an AI like ChatGPT, it's essential to take a **step-by-step** approach. This allows 
the AI to improve on relatively small parts of the project in each iteration, rather than trying to tackle the 
entire project at once. By breaking the project down into smaller, manageable tasks, you can ensure that the AI is 
working on the most important and relevant parts of the project, and you can also more easily identify and correct any e
rrors or issues that may arise. Additionally, this approach allows for more efficient use of resources, as the AI can 
focus on specific tasks rather than trying to handle everything at once.

![Final UI showing an image of a woman with a red shirt and dark curly hair](/assets/posts/2023-02-02-chatgpt-python-gui-app/UI.jpg){:.medium-image}

In this post, we'll be using this step-by-step approach to build our Python GUI application. We'll start by 
understanding the different GUI libraries available, and then we'll proceed to create the app in stages, focusing on 
one task at a time. This approach will not only make the development process more manageable but also will allow us to 
test and improve each part of the app before moving on to the next. By following this approach, we'll be able to create 
a more robust and polished application that meets our needs. 

[The full conversation]({% link _pages/chatgpt_clipapp_full.md %}) is available, as only key points
are highlighted here. The final code resulting from this experiment can be found on the [ClipApp GitHub page](https://github.com/sepro/ClipApp).

## Getting Started

Before we dive into creating our Python GUI application, it's important to first understand the different options 
available for building a GUI in Python. There are several popular libraries for building a GUI in Python, such as 
Tkinter, PyQt, wxPython, and Kivy, to name a few. Each of these libraries has its own set of features and capabilities, 
and it's important to choose the right one for your specific needs. Furthermore, by prompting ChatGPT to describe to us
which libraries exist, we get a glimpse of which libraries the AI has seen often during training and will have knowledge
about.

So we'll start general and ask : "I'm making a GUI application in python, can you pick a good library for a small program and show me code to start off with?"

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**ChatGPT**: There are several libraries you can use to create a GUI application in Python, but some of the most popular ones are Tkinter, PyQt, and wxPython.

Tkinter is a built-in library in Python for creating simple GUI applications. It is a good choice for small programs and beginners. Here is an example of creating a simple window using Tkinter:
```python
import tkinter as tk

root = tk.Tk()
root.mainloop()
```

PyQt is another popular library that is widely used for creating more advanced GUI applications. It is a set of Python bindings for the Qt library. Here is an example of creating a simple window using PyQt:
```python
import sys
from PyQt5.QtWidgets import QApplication, QWidget

app = QApplication(sys.argv)
window = QWidget()
window.show()
sys.exit(app.exec_())
```

wxPython is another popular library for creating GUI applications in Python. It is a set of Python bindings for the wxWidgets library. Here is an example of creating a simple window using wxPython:
```python
import wx

app = wx.App()
frame = wx.Frame(None, title='Hello World')
frame.Show()
app.MainLoop()
```

It's worth noting that PyQt and wxPython are larger libraries and more complex than Tkinter.
You can choose the one that best fits your needs based on your skills and the requirements of your project.

</div>

So this shows ChatGPT knows a bit about Tkinter, PyQt and wxPython. Given that Tkinter is a built-in library we'll
continue with that one, as I hope to build a standalone app at the end eliminating additional libraries will make that 
final step a little easier.

### First let ChatGPT write code for the layout

Step one will be to get some code that puts the necessary elements on the screen. What they'll do can be added later.
So first describe the desired layout and see if ChatGPT can generate something using the Tkinter library.

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**You**: Let's continue with Tkinter, I need in the middle of the screen a widget that can display an image with an editable text box underneath. Right of the text box an 'Ok' and 'Cancel' button. Left and right of the image buttons to navigate.

**ChatGPT**: You can accomplish this layout using a combination of Tkinter's built-in widgets such as the ```Label```, ```Entry```, ```Button```, and ```Frame``` widgets.

Here is an example of how you can create this layout:
```python
import tkinter as tk
from tkinter import PhotoImage

root = tk.Tk()
root.geometry("500x500")

# Creating Frame
middle_frame = tk.Frame(root)
middle_frame.pack(pady=50)

#Creating Image
image = PhotoImage(file = "path_to_image")
image_label = tk.Label(middle_frame, image=image)
image_label.grid(row=0, column=0, padx=50)

#Creating Text Box
text_box = tk.Entry(middle_frame)
text_box.grid(row=1, column=0, padx=50)

#Creating Ok button
ok_button = tk.Button(middle_frame, text="OK", command=lambda:print("OK button pressed"))
ok_button.grid(row=1, column=1)

#Creating Cancel button
cancel_button = tk.Button(middle_frame, text="Cancel", command=lambda:print("Cancel button pressed"))
cancel_button.grid(row=1, column=2)

#Creating navigate button
previous_button = tk.Button(middle_frame, text="Previous", command=lambda:print("previous button pressed"))
previous_button.grid(row=0, column=1)

next_button = tk.Button(middle_frame, text="Next", command=lambda:print("next button pressed"))
next_button.grid(row=0, column=2)

root.mainloop()
```

In this example, the ```middle_frame``` is created and added to the root window. The ```image_label``` is created to display the image, and it's added to the ```middle_frame```. The ```text_box``` is created to allow the user to enter text, and it's added to the ```middle_frame```. The ```ok_button``` and ```cancel_button``` are created and added to the ```middle_frame```.
The ```previous_button``` and ```next_button``` are created and added to the ```middle_frame```.
The ```grid``` method is used to position the widgets within the frame.
The ```padx``` and ```pady``` options are used to add some padding around the widgets.

The ```file = "path_to_image"``` should be replaced with the path of the image you want to display.

The ```lambda:print("OK button pressed")``` and ```lambda:print("Cancel button pressed")``` is a simple callback function to check if the button is pressed.

You can customize the layout and functionality to suit your needs.

</div>

While the initial code may serve as a starting point, there are a few elements that need to be adjusted to better suit 
the needs of our application. For example, the image may be too small to effectively display the images the app is 
intended for. Additionally, a menu bar is not currently included in the code, which would be a useful feature for 
navigation and organization. To address these issues, we will make a few quick adjustments to the code and then provide 
the updated version to ChatGPT. Specifically, we'll ask ChatGPT to add a menu bar with a "File" item, which includes 
two options: "Open" and "Exit". 

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**You**: I updated the code, can you add a menu bar with a button file and a dropdown with an Open button and Exit button. The exit button needs to close the app

```python
if __name__ == '__main__':
    import tkinter as tk
    from tkinter import PhotoImage

    root = tk.Tk()
    root.geometry("1000x900")

    # Creating Frame
    middle_frame = tk.Frame(root)
    middle_frame.pack(pady=50)

    # Creating Image
    image = PhotoImage(file="./img/empty_file.png")
    image_label = tk.Label(middle_frame, image=image)
    image_label.grid(row=0, column=1, padx=50)

    # Creating Text Box
    text_box = tk.Entry(middle_frame)
    text_box.grid(row=1, column=0, padx=50)

    # Creating Ok button
    ok_button = tk.Button(middle_frame, text="OK", command=lambda: print("OK button pressed"))
    ok_button.grid(row=1, column=1)

    # Creating Cancel button
    cancel_button = tk.Button(middle_frame, text="Cancel", command=lambda: print("Cancel button pressed"))
    cancel_button.grid(row=1, column=2)

    # Creating navigate button
    previous_button = tk.Button(middle_frame, text="Previous", command=lambda: print("previous button pressed"))
    previous_button.grid(row=0, column=0)

    next_button = tk.Button(middle_frame, text="Next", command=lambda: print("next button pressed"))
    next_button.grid(row=0, column=2)

    root.mainloop()
```

**ChatGPT**: You can add a menu bar in Tkinter by creating an instance of the ```Menu``` widget and adding it to the 
root window. You can then create instances of the ```Menu``` widget for each menu option and add them to the main menu. 
To create a dropdown menu, you can create instances of the ```Menu``` widget and add them to the main menu using the 
```add_cascade``` method. Here is an example of how you can add a menu bar with a "File" menu that has an "Open" 
button and an "Exit" button:

```python
import tkinter as tk
from tkinter import PhotoImage

root = tk.Tk()
root.geometry("1000x900")

# Creating Frame
middle_frame = tk.Frame(root)
middle_frame.pack(pady=50)

# Creating Image
image = PhotoImage(file="./img/empty_file.png")
image_label = tk.Label(middle_frame, image=image)
image_label.grid(row=0, column=1, padx=50)

# Creating Text Box
text_box = tk.Entry(middle_frame)
text_box.grid(row=1, column=0, padx=50)

# Creating Ok button
ok_button = tk.Button(middle_frame, text="OK", command=lambda: print("OK button pressed"))
ok_button.grid(row=1, column=1)

# Creating Cancel button
cancel_button = tk.Button(middle_frame, text="Cancel", command=lambda: print("Cancel button pressed"))
cancel_button.grid(row=1, column=2)

# Creating navigate button
previous_button = tk.Button(middle_frame, text="Previous", command=lambda: print("previous button pressed"))
previous_button.grid(row=0, column=0)

next_button = tk.Button(middle_frame, text="Next", command=lambda: print("next button pressed"))
next_button.grid(row=0, column=2)

# Creating main menu
menubar = tk.Menu(root)
root.config(menu=menubar)

# Creating File menu
file_menu = tk.Menu(menubar, tearoff=0)
menubar.add_cascade(label="File", menu=file_menu)
file_menu.add_command(label="Open", command=lambda: print("Open button pressed"))
file_menu.add_command(label="Exit", command=root.destroy)

root.mainloop()
```

In this example, the ```menubar``` is created and added to the root window. The ```file_menu``` is created and added to the main menu using the ```add_cascade``` method. The ```Open``` button and ```Exit``` button are created and added to the ```file_menu``` using the ```add_command``` method. The ```command``` option is used to specify the function that should be called when the button is pressed. In this case, when the ```Exit``` button is pressed the ```root.destroy()``` function is called which will close the app.

You can customize the menu and the functionality to suit your needs.

</div>

With a little back and forth you can specify the behaviour of each element. Using a single prompt to get code for a
single element works best, then iterate until all items work as intended.

## Refactoring the code

After completing the Open folder functionality, it became apparent the code was growing too large and needed 
refactoring. ChatGPT actually seems up to that task when prompted to do so. Using a simple instruction to refactor the
code into a Class and make it more modular it did so, providing a much better base to continue development of the app.

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**You**: can you refactor the code as a Class, ClipApp, to avoid the use of global variables and allow the app to become more modular?

**ChatGPT**: Yes, you can refactor the code as a class to avoid the use of global variables and make the app more modular. Here is an example of how you can refactor the code to a class, ```ClipApp```:

```python
import tkinter as tk
from tkinter import PhotoImage
from tkinter import filedialog
import os

class ClipApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.geometry("1000x900")
        self.image_files = []

        # Creating Frame
        middle_frame = tk.Frame(self.root)
        middle_frame.pack(pady=50)

        # Creating Image
        image = PhotoImage(file="./img/empty_file.png")
        self.image_label = tk.Label(middle_frame, image=image)
        self.image_label.grid(row=0, column=1, padx=50)

        # Creating navigate button
        previous_button = tk.Button(middle_frame, text="Previous", command=lambda: print("previous button pressed"))
        previous_button.grid(row=0, column=0)

        next_button = tk.Button(middle_frame, text="Next", command=lambda: print("next button pressed"))
        next_button.grid(row=0, column=2)

        # Creating Text Box
        text_box = tk.Entry(middle_frame)
        text_box.grid(row=1, column=0, padx=50)

        # Creating Ok button
        ok_button = tk.Button(middle_frame, text="OK", command=lambda: print("OK button pressed"))
        ok_button.grid(row=1, column=1)

        # Creating Cancel button
        cancel_button = tk.Button(middle_frame, text="Cancel", command=lambda: print("Cancel button pressed"))
        cancel_button.grid(row=1, column=2)

        # Creating main menu
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        # Creating File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar
```

**You**: continue

**ChatGPT**: continue
menubar.add_cascade(label="File", menu=file_menu)
file_menu.add_command(label="Open", command=self.select_folder)
file_menu.add_command(label="Exit", command=self.root.destroy)

```python
def select_folder(self):
    folder_path = filedialog.askdirectory()
    print(f"Selected folder: {folder_path}")
    self.image_files = self.get_image_files(folder_path)
    print(self.image_files)

def get_image_files(self, folder_path):
    image_files = []
    for file in os.listdir(folder_path):
        if file.endswith(".jpg") or file.endswith(".jpeg") or file.endswith(".png") or file.endswith(".gif") or file.endswith(".bmp"):
            image_files.append(os.path.join(folder_path, file))
    return image_files


if __name__ == '__main__':
    app = ClipApp()
    app.root.mainloop()
```

In this refactored code, I've created a class `ClipApp` that contains all the code for the application. The `__init__` method initializes the Tkinter root, sets the default geometry and creates the GUI layout, including the image label, text box, buttons, and menu bar. The `select_folder()` method is now a method of the `ClipApp` class and it no longer uses global variables. Instead, it updates the `image_files` attribute of the `ClipApp` instance. The `get_image_files()` method is also now a method of the `ClipApp` class and it takes the folder path as an argument.
This way, by creating an instance of the ClipApp class you can use the same code in different parts of your program, it also allows for a more organized and readable code.

</div>

Again, the majority of the work was carried out by ChatGPT, though before proceeding a few tweaks would be nice. So 
again, the updated code was fed back along with a question how modularity could be improved. ChatGPT provided some 
reasonable suggestions, and when asked to implement them it did so marvelously. It happens ChatGPT stops in the middle
of a block of code, simply asking to continue will make ChatGPT complete the code.

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**You**: Here is the code with your changes and a few tweaks. Can you suggest further improvements to make it more modular?

```python
import tkinter as tk
from tkinter import PhotoImage
from tkinter import filedialog
import os


def get_image_files(folder_path):
    image_files = []
    for file in os.listdir(folder_path):
        if file.endswith(".jpg") or file.endswith(".jpeg") or file.endswith(".png") or file.endswith(
                ".gif") or file.endswith(".bmp"):
            image_files.append(os.path.join(folder_path, file))
    return image_files


class ClipApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.geometry("1000x900")
        self.image_files = []

        # Creating Frame
        middle_frame = tk.Frame(self.root)
        middle_frame.pack(pady=50)

        # Creating Image
        image = PhotoImage(file="./img/empty_file.png")
        self.image_label = tk.Label(middle_frame, image=image)
        self.image_label.grid(row=0, column=1, padx=50)

        # Creating navigate button
        previous_button = tk.Button(middle_frame, text="Previous", command=lambda: print("previous button pressed"))
        previous_button.grid(row=0, column=0)

        next_button = tk.Button(middle_frame, text="Next", command=lambda: print("next button pressed"))
        next_button.grid(row=0, column=2)

        # Creating Text Box
        text_box = tk.Entry(middle_frame)
        text_box.grid(row=1, column=0, padx=50)

        # Creating Ok button
        ok_button = tk.Button(middle_frame, text="OK", command=lambda: print("OK button pressed"))
        ok_button.grid(row=1, column=1)

        # Creating Cancel button
        cancel_button = tk.Button(middle_frame, text="Cancel", command=lambda: print("Cancel button pressed"))
        cancel_button.grid(row=1, column=2)

        # Creating main menu
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        # Creating File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Open", command=self.select_folder)
        file_menu.add_command(label="Exit", command=self.root.destroy)

    def select_folder(self):
        folder_path = filedialog.askdirectory()
        print(f"Selected folder: {folder_path}")
        self.image_files = get_image_files(folder_path)
        print(self.image_files)


if __name__ == '__main__':
    app = ClipApp()
    app.root.mainloop()
```

**ChatGPT**: Here are a few suggestions for further improvements to make the code more modular:You can extract the GUI layout code into its own method, such as ```create_layout()```, to make the ```__init__``` method less cluttered and easier to read.You can create methods to handle the behavior of the buttons, such as ```previous_button_handler()```, ```next_button_handler()```, ```ok_button_handler()```, and ```cancel_button_handler()```, instead of using lambda functions in the button creation. This way you can more easily modify the behavior of the buttons in the future.You can create a method to handle the navigation of the images, such as ```navigate_images(direction)```, and call this method from the button handlers. This way you can easily add new navigation functionality without modifying the button handlers.You can move the functionality of the 'Open' button to a separate class that manage the images, this way you can further improve the modularity of the code.

Overall, by breaking down the code into smaller, more specific methods and classes, you can make the code more modular and easier to understand and maintain.

**You**: make those changes to the code provided

**ChatGPT**: Here is an example of how you can make the changes I suggested to the code you provided:
```python
import tkinter as tk
from tkinter import PhotoImage
from tkinter import filedialog
import os


class ImagesHandler:
    def __init__(self):
        self.image_files = []
        self.current_image_index = -1

    def get_image_files(self, folder_path):
        image_files = []
        for file in os.listdir(folder_path):
            if file.endswith(".jpg") or file.endswith(".jpeg") or file.endswith(".png") or file.endswith(".gif") or file.endswith(".bmp"):
                image_files.append(os.path.join(folder_path, file))
        return image_files

    def select_folder(self):
        folder_path = filedialog.askdirectory()
        print(f"Selected folder: {folder_path}")
        self.image_files = self.get_image_files(folder_path)
        self.current_image_index = 0
        return self.image_files

    def navigate_images(self, direction):
        if direction == "previous":
            self.current_image_index -= 1
        elif direction == "next":
            self.current_image_index += 1
        if self.current_image_index &lt; 0:
            self.current_image_index = len(self.image_files) - 1
        elif self.current_image_
```

**You**: continue

**ChatGPT**: Sure, here is the continuation of the code:
```python
    def navigate_images(self, direction):
        if direction == "previous":
            self.current_image_index -= 1
        elif direction == "next":
            self.current_image_index += 1
        if self.current_image_index &lt; 0:
            self.current_image_index = len(self.image_files) - 1
        elif self.current_image_index >= len(self.image_files):
            self.current_image_index = 0
        return self.image_files[self.current_image_index]

class ClipApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.geometry("1000x900")
        self.image_handler = ImagesHandler()

        self.create_layout()
        self.create_menu()

    def create_layout(self):
        # Creating Frame
        middle_frame = tk.Frame(self.root)
        middle_frame.pack(pady=50)

        # Creating Image
        image = PhotoImage(file="./img/empty_file.png")
        self.image_label = tk.Label(middle_frame, image=image)
        self.image_label.grid(row=0, column=1, padx=50)

        # Creating navigate button
        previous_button = tk.Button(middle_frame, text="Previous", command=self.previous_button_handler)
        previous_button.grid(row=0, column=0)

        next_button = tk.Button(middle_frame, text="Next", command=self.next_button_handler)
        next_button.grid(row=0, column=2)

        # Creating Text Box
        text_box = tk.Entry(middle_frame)
        text_box.grid(row=1, column=0, padx=50)

        # Creating Ok button
        ok_button = tk.Button(middle_frame, text="OK", command=self.ok_button_handler)
        ok_button.grid(row=1, column=1)

        # Creating Cancel button
        cancel_button = tk.Button(middle_frame, text="Cancel", command=self.cancel_button_handler)
        cancel_button.grid(row=1, column=2)

    def create_menu(self):
        # Creating main menu
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        # Creating File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Open", command=self.image_handler.select_folder)
        file_menu.add_command(label="Exit", command=self.root.destroy)

    def previous
```

**You**: continue

**ChatGPT**: Sure, here is the continuation of the code:
```python
    def previous_button_handler(self):
        previous_image = self.image_handler.navigate_images("previous")
        self.update_image(previous_image)
        print("previous button pressed")

    def next_button_handler(self):
        next_image = self.image_handler.navigate_images("next")
        self.update_image(next_image)
        print("next button pressed")

    def ok_button_handler(self):
        print("OK button pressed")

    def cancel_button_handler(self):
        print("Cancel button pressed")

    def update_image(self, image_path):
        # code to update the image in the GUI
        pass

if __name__ == '__main__':
    app = ClipApp()
    app.root.mainloop()
```

In the update_image method you can add the code to update the image to the one passed as a parameter.
In this way, you can use the same method to update the image when navigating between images and when changing the folder.

This way you can keep the code more readable, and if you need to change the way the images are handled you can simply 
modify the ImagesHandler class without affecting the rest of the code.

</div>

The implementation of that ```ImagesHandler``` class is quite elegant. This also allows the code to be split in multiple
files, which was done manually. Now, we iterate more on the functionality, adding a ```TextHandler``` class and getting
all buttons to function. In case you aren't satisfied with the output, simply ask for another response, or indicate
what is wrong with the answer and ask ChatGPT to correct itself.

## Adding docstrings and type annotations

Once the app was functional, I wanted to see if ChatGPT could be used to add documentation and type annotation to the
functions it had produced. It worked like a charm! While AI writing code is impressive, that is the part of the job
I don't mind doing, writing documentation however is far less satisfying, being able to (partially) delegate this to
AI is an incredible time-saver.

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**You**: Take the first function and add type annotation and a docstring

**ChatGPT**: Here is the updated function with type annotations and a docstring:
```python
def image_to_text_path(image_path: str) -> str:
    """
    Given an image path, return the corresponding text file path by replacing the extension with '.txt'
    :param image_path: The file path of the image
    :return: The file path of the text file with the same name
    """
    path, ext = os.path.splitext(image_path)
    return path + ".txt"
```

The type annotations indicate that the function takes a single argument, ```image_path``` which is a string, and it returns a string.
The docstring gives a brief explanation of what the function does, the inputs and the expected output.
It is a good practice to add docstring and type annotations to your functions, it will help you and other developers to understand the code better and avoid errors.

</div>

Similarly, I had ChatGPT write a first draft for the README.md, this was a little rough around the edges, but a solid
start to get the ball rolling for a human.

## Compiling the app

Python code can be a little tricky to deploy, though the Nuitka project aims to compile Python code into stand-alone
executables. This project would be a great candidate as the final program could more easily be shared with others
annotating images for fine-tuning Stable Diffusion. Here ChatGPT provided correct instructions how to get Nuitka up and
running. However, it did omit the argument ```--enable-plugin=tk-inter``` for compiling the app correctly.

```commandline
nuitka --standalone --windows-disable-console --enable-plugin=tk-inter --onefile app.py
```

## Adding unit-tests 

The last challenge for ChatGPT is to create a small test suite for the ```ImagesHandler``` and ```TextHandler``` 
classes. So the code for these classes is simply copied in along with the question to add unit-tests using the Pytest
library. It took a few re-rolls, and you might need to explicitly mention ChatGPT should include fixtures to be less 
redundant, but for simple functions with a well-defined single purpose (which you really should be aiming for when
writing code) ChatGPT can come up with a reasonable set of tests. 

<div style="height:250px;overflow-y:scroll;padding: 5px;padding-right:15px;margin-left:15px;background-color:rgb(247,247,247)" markdown="1">

**You**: write unit tests for the code below

import os


class TextHandler:
    def __init__(self, text_path:str):
        """
        Initialize a TextHandler instance with a text file path
        :param text_path: the path to the text file
        """
        self.text_path = text_path
        self.original_text: str = ""
        self.load_text()

    def load_text(self) -> None:
        """
        Load the text from the file, if the file doesn't exist, it will create an empty one.
        """
        if os.path.exists(self.text_path):
            with open(self.text_path, "r") as f:
                self.original_text = f.read()
        else:
            with open(self.text_path, "w") as f:
                pass

    def save_text(self, new_text: str) -> None:
        """
        Save a new text to the file
        :param new_text: the text to be written to the file
        """
        self.original_text = new_text
        with open(self.text_path, "w") as f:
            f.write(new_text)

**ChatGPT**: Sure, here are some example unit tests for the TextHandler class using the ```pytest``` library:python
```python
import os
import pytest
from text_handler import TextHandler

def test_init():
    text_path = 'tests/test_text.txt'
    text_handler = TextHandler(text_path)
    assert text_handler.text_path == text_path
    assert text_handler.original_text == ""

def test_load_text(tmpdir):
    text_path = tmpdir.join('test_text.txt')
    text_path.write("test text")
    text_handler = TextHandler(text_path)
    text_handler.load_text()
    assert text_handler.original_text == "test text"

def test_save_text(tmpdir):
    text_path = tmpdir.join('test_text.txt')
    text_handler = TextHandler(text_path)
    text_handler.save_text("new text")
    assert text_path.read() == "new text"
    assert text_handler.original_text == "new text"
```

In the above example, I've used ```tmpdir``` fixture from pytest to create temporary files. This allows to create test 
files without polluting the file system and also cleaning them up automatically after the test.

In the ```test_init``` function, we test that the instance is correctly initialized with the text_path and the 
original_text is empty string.

In the ```test_load_text``` function, we create a temporary text file, write some text to it, create a TextHandler 
instance and load the text. Then we assert that the original_text attribute is the same as the text written to the file.

In the ```test_save_text``` function, we create a temporary text file, create a TextHandler instance, save a new 
text to the file and assert that the text in the file is the same as the new text and the original_text attribute is 
also the same as the new text.

</div>

## Final Thoughts

Overall, including ChatGPT in the workflow for building a Python GUI application has proven to be a highly effective and 
efficient strategy. However, it's important to keep in mind that a step-by-step approach is necessary in order to 
create larger applications. Having a human in the loop to make sure the structure is solid and the code works is still
necessary. Though having an AI co-pilot that can do simple tasks this quickly is a huge boon. Simply let ChatGPT take 
care of the tedious tasks, so you can focus on the big picture.

The ability to use ChatGPT to add documentation in the form 
of docstrings and type annotations is an amazing feature that can save a lot of time and effort. It makes the process 
of documenting code much faster, more efficient, and more pleasant.

Given it is still early days, and ChatGPT has just been released a few weeks ago, this is a technology to keep track of.
This has the potential to transform many jobs across various fields. Being able to work with it can be a great asset in
the near future!

[ChatGPT]: https://chat.openai.com/
[Stable Diffusion]: https://stability.ai/
