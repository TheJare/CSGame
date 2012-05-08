# CoffeeScript Game test
(C) Copyright 2012 by Javier Arevalo

## Summary

Little game-engine-graphics-thing in CoffeeScript, to help me learn this language.

## The code

### utils.coffee
Bunch of common utility functions

### vec2.coffee
A simple 2D vector & matrix library

### gameobject.coffee
A simple GameObject library.
Create a GoContainer, add Go instances to it, call tick(seconds) and render(context)
Subclass Go to create your own gameobjects.

### game.coffee
Not really a game at the moment, just a small graphics experiment with colored rotating circles.

### index.html
The page that contains the canvas and runs the code.
It uses jQuery, probably for not a lot - I just include it by default everywhere.

## Build instructions

Note that the Makefile uses nodeJS to run the CoffeeScript compiler, and 'uglifyjs' for minification.
You can install both uglify-js and coffee-script as nodejs packages using npm. Go to http://nodejs.org/ to install Node and npm.
