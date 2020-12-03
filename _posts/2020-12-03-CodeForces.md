---
layout: post
title:  "CodeForces: Trying on Competitive Coding"
byline: ""
date:   2020-12-03 13:00:00
author: Sebastian Proost
categories: programming
tags:	python 
cover:  "/assets/images/headers/python_code.jpg"
thumbnail: "/assets/images/thumbnails/python_code.jpg"
---

How well do you know your algorithms? If you are a self-taught coder (like me), this might be a gap in your knowledge!
This post is my attempt to get some extra practise under my belt writing algorithms to solve a few coding problems. On
[CodeForces], a site where there are programming competitions, the assignments from previous competitions are all
available as well as the infrastructure to check your solution. So let's use this resource to level up our programming
a little.

## Getting Started

On [CodeForces] all problems have a difficulty ranging from 800 to 3500. The lower the difficulty the easier to problem
is to solve. To get started I recommend picking an easy problem to tackle to get familiar with the platform, how to get
the input, how to submit a solution, ...

I picked problem 119A titled "[Epic Game]", with the lowest difficulty of 800, to dip my toes in the water. The goal is 
to write a problem solve this issue:

---
Simon and Antisimon play a game. Initially each player receives one fixed positive integer that doesn't change 
throughout the game. Simon receives number *a* and Antisimon receives number *b*. They also have a heap of *n* stones. The 
players take turns to make a move and Simon starts. During a move a player should take from the heap the number of 
stones equal to the greatest common divisor of the fixed number he has received and the number of stones left in the 
heap. A player loses when he cannot take the required number of stones (i. e. the heap has __strictly__ less stones 
left than one needs to take).

Your task is to determine by the given *a*, *b* and *n* who wins the game.

**Input**
The only string contains space-separated integers *a*, *b* and *n* (1≤*a*,*b*,*n*≤100) — the fixed numbers Simon and 
Antisimon have received correspondingly and the initial number of stones in the pile.

**Output**
If Simon wins, print "0" (without the quotes), otherwise print "1" (without the quotes).

---

The first solution I came up with is very straight forward, the inner loop alternates between both players, adjusting
*n* as described above. This is repeated (outer loop) until a player wins a game, in that case the winner is printed
and the loop broken.

There is some spice in how the input is read from standard input; ```input().split()``` will grab a line from STDIN and
split it at whitespaces. the ```map``` function will apply the ```int``` on all parts turning the input from string into
integer numbers. Using ```*``` a list can be passed as arguments to a function. As all challenges will get the data
from STDIN, it pays off to know a few of these tricks to quickly and without too much code pull in that data.

```python
import math


def solve(a, b, n):
    while True:
        for ix, value in enumerate([a, b]):
            gdc = math.gcd(value, n)
            if gdc <= n != 0:
                n -= gdc
            else:
                print(1 if ix == 0 else 0)
                return


if __name__ == "__main__":
    solve(*map(int, input().split()))
```

If you save this code to a ```.py``` file, you can submit it on the platform. As CodeForces supports solutions is a 
number of programming languages you'll have to specify that **Python 3.7.2** is used here. Or you can select 
**PyPy 3.6 (7.2.0)**, [PyPy] is a faster version of Python, and as there is a limit to how long your code can run 
before failing, this could be an advantage (though it really doesn't matter much here).

I also noted that my code here has some later verbose sections, at the bottom of the post you can find my attempt to
write is as short as possible.

## The Next Problem

Moving up to a more difficult problem "[Skier]", where you have to track the movements of a skier and determine how
fast he can complete a certain path. When going along a stretch they visited before he can move faster than going
somewhere for the first time. You can read the full problem description below:

---

Skier rides on a snowy field. Its movements can be described by a string of characters 'S', 'N', 'W', 'E' (which 
correspond to 1 meter movement in the south, north, west or east direction respectively).

It is known that if he moves along a previously unvisited segment of a path (i.e. this segment of the path is visited 
the first time), then the time of such movement is 5 seconds. If he rolls along previously visited segment of a path 
(i.e., this segment of the path has been covered by his path before), then it takes 1 second.

Find the skier's time to roll all the path.

**Input**

The first line contains an integer *t* (1≤*t*≤10<sup>4</sup>) — the number of test cases in the input. Then *t* test cases follow.

Each set is given by one nonempty string of the characters 'S', 'N', 'W', 'E'. The length of the string does not exceed 
10<sup>5</sup> characters.

The sum of the lengths of *t* given lines over all test cases in the input does not exceed 10<sup>5</sup>.

**Output**

For each test case, print the desired path time in seconds.

---

So my initial idea was to convert the current move into start and stop coordinates. If those have been visited before
(or in reverse order) increase the time by one, otherwise add those coordinates to the list of visited stretches and increase
the time by five.

```python
def solve(path):
    x,y,count = 0,0,0
    visited = []

    for p in path:
        new_x = x + 1 if p == "E" else x - 1 if p == "W" else x
        new_y = y + 1 if p == "N" else y - 1 if p == "S" else y

        if (x, y, new_x, new_y) in visited or (new_x, new_y, x, y) in visited:
            count += 1
        else:
            count += 5
            visited.append((x, y, new_x, new_y))

        x, y = new_x, new_y

    return count


if __name__ == "__main__":
    for _ in range(int(input())):
        path = input()
        print(solve(path))
```

While this solution is correct, CodeForces will not accept this as it takes to long to complete... Looking up in a list 
if the upcoming section was visited before is a very slow step. I didn't pay attention that the maximum input can be
10<sup>5</sup> steps, so **I didn't pick the correct data structure**. A dictionary is the better choice if you need to look 
things up fast and frequently. So read the instructions carefully before getting started. Especially if you plan to 
join a real competition where incorrect submissions will cost you points. Not to mention you lose time having to 
re-implement your solution.

```python
from collections import defaultdict


def solve(path):
    x, y, c = 0, 0, 0
    s = defaultdict(lambda: 5)

    for p in path:
        nx = x + 1 if p == "E" else x - 1 if p == "W" else x
        ny = y + 1 if p == "N" else y - 1 if p == "S" else y

        c += min(s[(x, y, nx, ny)], s[(nx, ny, x, y)])
        s[(x, y, nx, ny)] = 1

        x, y = nx, ny

    return c


for _ in range(int(input())):
    print(solve(input()))
```

Here a ```defaultdict``` is used which will return a value of five each time an element is accessed which hasn't been set 
yet. So, here we determine the current (x, y) and next (nx, ny) coordinates of the skier, grab the smallest value for that
section and the reverse from the dictionary, increase the counter by that value. Set the value for that path in the 
dictionary to one and update the current coordinates.

## Getting Stuck

After solving a few more problems with a difficulty ranging from 800-1600, I got stuck on "[Two Buttons]". While I 
found a solution which included a recursive, depth-first search, I couldn't get it to work fast enough. Even after
adding every optimization I could think of ... nothing ... still way to slow. So I took a look at some of the valid 
solutions which were remarkably simple! There was a trick necessary that I'm certain everyone with a CS degree will
have encountered during their studies. While it is super inefficient to find the optimal path from start to finish as
I was doing, it is simple to find the solution when going the opposite direction from stop till start. Now the solution,
is trivial and can be written in a few lines of code.

```python
def solve(n, m):
    count = 0
    while n != m:
        count += 1
        if m < n or m % 2 == 1:
            m += 1
        else:
            m = m // 2

    return count


print(solve(*map(int, input().split())))
```


## Bonus: Code Golf

Code Golf is implementing code as short as possible. While this is not a requirement for CodeForces, I did attempt to
shorten the code for [Epic Game] here...

```python
import math
s=lambda a,b,n,i:s(b,a,n-math.gcd(a,n),i+1)if n!=0else i%2
print(s(*map(int,input().split()),1))
```

... and here is an abridged version for [Two Buttons]. While correct it fails on one of the tests because it hits the 
recursion limit (the number of times a function can call itself, the limit is 1000).

```python
s=lambda n,m,c:c if n==m else s(n,m+1,c+1) if (m<n or m%2==1) else s(n,m//2,c+1)
print(s(*map(int, input().split()), 0))
```

This is very much against the Zen of Python that code should be readable, which this isn't! So don't use this when 
writing code for projects that need to be maintained, it will come back and haunt someone (most likely you).

## Conclusion

Apart from having a few excuses to play with recursion, use lambdas and the ```map``` function to write short (albeit not
very readable code), I've learned the most getting stuck! The common advice to approach a problem from a different
angle here could quite literally be applied. This is a trick I will keep in mind when attempting to solve more 
difficult code challenges.

[CodeForces]: http://codeforces.com/
[Epic Game]: https://codeforces.com/problemset/problem/119/A
[Skier]: https://codeforces.com/problemset/problem/1351/C
[Two Buttons]: https://codeforces.com/problemset/problem/520/B
[PyPy]: https://www.pypy.org/
