KoboldKit
=========

Kobold Kit is a game engine built on Sprite Kit. It adds additional features, flexibility, convenience, etc etc…. :)

Links
-----

Website: http://koboldkit.com

Track Progress: https://www.pivotaltracker.com/s/projects/849925

Report Issues: https://github.com/LearnCocos2D/KoboldKit/issues

Discuss: http://koboldkit.uservoice.com (PLEASE refrain from referencing Sprite Kit classes, features, etc, even indirectly until the NDA is lifted)


How to Help
------

Feedback is most important and very welcome!

Try it out, ask questions about things that aren't obvious, make suggestions, report bugs. Focus on aspects in the "recently completed" list.

Let's keep it simple: use the issue tracker for bug reports, suggestions AND questions:
https://github.com/LearnCocos2D/KoboldKit/issues

Overview
------

Nodes are extended via KKNodeController. The controller provides KKNodeModel and KKNodeBehavior classes for nodes.

KKNodeBehavior purpose:
- add game logic (behavior) to any node without subclassing
- should be used whenever custom actions won't suffice (ie internal state, event handling, etc)
- if used well, will result in highly reusable code (library of prebuilt behaviors)

Example: button behavior. Added to any node, turns it into a touch/clickable button like a CCMenu item.
Or: KKRemoveOnContactBehavior. Automatically removes the node when it contacts with another physics body.

Behaviors can also host larger amounts of data and game logic. For example a custom behavior could:
- generate a collision map from a tilemap
- use the collision map to calculate and return a path (pathfinding)
- store the world locations of world actors (enemies, resources, etc)
- provide interface for game AI to find nearest location of resource, or enemy "hotspots" to avoid
- provide interface to check for collisions or other properties (ie type of terrain an such)

KKNodeModel purpose:
- storage for keyed variables (variables by name)
- these variables are automatically coded/copied
- again: no subclassing needed to merely add variables, and coding/copying is automatic

Note: for all intents and purposes the model can be seen as a data storage layer for behaviors (and the node)
with which a node's behaviors can exchange information without having to know about each other.


KKScene purpose:
- act as contact delegate and dispatcher
- act as input delegate and dispatcher

This is just a rough description. More details as things move forward.
