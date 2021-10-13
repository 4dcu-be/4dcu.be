---
layout: post
title:  "Lights, Camera, GitHub, Actions: My Favorite GitHub Actions"
byline: ""
date:   2021-10-15 06:00:00
author: Sebastian Proost
categories: programming
tags:	python javascript github black unittest ci automation yaml
cover:  "/assets/posts/2021-10-15-GitHub-Actions/github_logo.png"
thumbnail: "/assets/images/thumbnails/github_actions_header.jpg"
---

[GitHub Actions] allow you to automate some workflows directly on GitHub when code is pushed, at regular intervals or
triggered manually. While it takes a bit of setup, the advantages are well worth the time required to get
acquainted with this advanced feature of GitHub.

In this post I'll outline a few of my favorite workflows to pull in new data periodically, format code, run unittests, 
... Links to different repos will be included to see the actions in, ..., well, action.

## Autoblack - Python code formatting

The package [black] is the de facto standard for formatting python code. Not only will it point out inconsistencies and 
mistakes in the code-style, black will correct them. So before committing code in a repo, it is a good idea to run
black to make sure the style is A-OK. However, I tend to forget to run it ... and while you could set up a pre-commit
hook (which needs to be configured on each developer's system) it is even better to let GitHub run black on all 
code, and if there are mistakes, fix them and re-commit. No need to install pre-commit hooks locally, or even to 
remember to run black yourself. 

There are plenty of examples out on GitHub how to do this, for a comprehensive overview check out the collection
of workflows from [cclaus' autoback repository](https://github.com/cclauss/autoblack). The version I'm using (shown
below) is based off this with little or no modifications. I'm currently including this every



[GitHub Actions]: https://github.com/features/actions
[black]: https://github.com/psf/black
