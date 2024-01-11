# Godot Spawn Sync
Learning Godot Multiplayer with the help of [BatteryAcidDev](https://www.youtube.com/@BatteryAcidDev) and [DevLogLogan](https://www.youtube.com/@DevLogLogan)
# Video's used
[Godot 4 multiplayer: spawn and sync your 3D characters](https://www.youtube.com/watch?v=AytWpymeVJw&t=1824s)
[Godot 4 - Online Multiplayer FPS From Scratch](https://www.youtube.com/watch?v=n8D3vEx7NAE&t=1993s)

# Branches
Each branch represents a progress point of me implimenting a feature. The order of the branches goes as follows.

## complete-tutorial
Finished the BatteryAcidDev video and slightly tweaked it for FPS instead of Third-Person.

## mouse-input
Using the mouse to look around and syncing the player model across clients. Used DevLogLogan's video for help here.

## shooting
Sending shooting RPCs, damaging players, and respawing them. Logic is taken also from DevLogLogan's video except edited to where
only the server does the raycast checks.

## ragdoll/master
When a player dies it spawns a Ragdoll physics object that is controlled by the server and propagated across clients.
