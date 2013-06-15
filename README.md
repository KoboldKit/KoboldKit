KoboldKit
=========

Kobold Kit is a game engine built on Sprite Kit. It adds additional features, flexibility and convenience.

Status
======

Work in progress. Needs testing.

Task Tracker: https://www.pivotaltracker.com/s/projects/849925

Overview
========

Nodes are extended via KKNodeController. The controller provides KKNodeModel and KKNodeBehavior classes for nodes.

KKNodeBehavior purpose:
- add game logic (behavior) to any node without subclassing
- should be used whenever custom actions won't suffice (ie internal state, event handling, etc)
- if used well, will result in highly reusable code (goal is to have a library of prebuilt behaviors)

Example: button behavior. Added to any node, turns it into a touch/clickable button like a CCMenu item.

KKNodeModel purpose:
- storage for keyed variables (variables by name)
- these variables are automatically coded/copied
- again: no subclassing just to add variables, and coding/copying is automatic

Subclasses of models are intended to host larger amounts of data and business logic. For example a custom model could do:
- generate a collision map from a tilemap
- use the collision map to calculate and return a path (pathfinding)
- store the world locations of world actors (enemies, resources, etc)
- provide interface for game AI to find nearest location of resource, or enemy "hotspots" to avoid
- provide interface to check for collisions or other properties (ie type of terrain an such)

Again the idea is to be able to re-use the same model for another tilemap, perhaps even another project.


KKScene purpose:
- act as contact delegate and dispatcher
- act as input delegate and dispatcher


This is just a rough description. More details as things move forward.

PS: documentation use appledoc (html & docset), check this preview: http://cl.ly/image/3d3f2P0w2C1y
