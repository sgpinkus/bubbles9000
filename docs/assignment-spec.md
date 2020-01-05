# Overview

  * Must include a neural network nad training phase for the NN
  * Game specification criteria. Your game should:
  * Be developed in C++ using OpenGL (the Cinder library is highly recommended)
  * Be a continuous 2D or 3D 2-player game
  * Have between 3 and 4 possible input controls for each player
  * Implement a bot that triggers those input controls for one player, trained on a neural network.
  * The bot should be difficult to beat for a new player.

# Game Design

  * We should tak Slime Valley Ball as the leve of complexity required. We need not implement Slime Valley ball.

# Alt 1 - 2 Player Asteroids
First basic iteration. Certain things can be evolved in next phases.

  * The agent has four inputs shoot, EMP, turn, accelaration.
  - The world is or is not a Torus. You bounce off wall or the dont exist.
  * Players get points for shooting asteroids.
  * Players have infinite shots.
  * Players also have an EMP. Players have infinite EMPs
  * Players can shoot/EMP each other.
  * Getting shot reduces life.
  * When life reaches zero you die.

# Alt 2 - Player Bubble Busters

  * As above but we have static bubbles that grow back after being blown up.
  * You bounce off bubbles and walls

# Initial Issues / Factors

  * Its not clear how one would train this.
    - Review the OL tut in lec 9 - is there anything about evolution?
  * Game will require intersection calculation for shooting and bumpig into things

# Approach

**Step one**
Implement this in processing for one player. Processing because the compile/test/update loop time for Cinder/VS is severe.

  1. Ballons and walls
  2. Grid and collision detection
  3. Observer and removal - death.
  4. One player with full controls and score.

## Progress Notes.

1. Done easy.

2. How to do it. Two alternatives. A flat grid or a quadtree. Lets try flatgrid.

  * Will will be square. squares at the edge will be cut off so wont actully be square.
  * No object may be >= grid square width.
  * nHood query looks in the 8 neighbourhood plus self.
      optimization is ((3*w)/W)**2 - overhead. so if W > 10*w should see ~10 improve.
  * Actual collision will be based on BB interection
  * Every object in the worlds must have a BB

**Objects**

Object is the base class for all entities:

  location
  velocity
  BB
  weight

Also object are observable. This is primaarily use to tell the grid the object is dead and should be removed.

**Collision Detection**
Before objects are moved, they are checked for collision. Collision will effect the objects velocity.

  * If object are totally ordered, collisions can be done just once for each pair.
  * Doing it without to start.
