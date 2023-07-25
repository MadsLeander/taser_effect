# Taser Effect

### About
Taser effect is a script that does what it says, adds a taser effect when the player gets stunned.

Now, I’m aware that there already exists a taser effect script out there, however, this one is different. Instead of looping in a thread to check if the player is stunned every frame, it uses game events. This of course makes the script more optimised (0.0ms at all times).

It also fades out the visual effect than just turning it off in an instant.

These are small changes, but I’ve decided to share this as it does provide improvements over the “old one”.

Update 25.07.2023:

Added a config file for easier usage, and added options for disabling writhe (Insta death from getting stunned) as well options for NPC's to drop weapons. + Added an experimental option for players laying min/max time laying on the ground after getting stunned.

FiveM Forum Post: https://forum.cfx.re/t/release-taser-effect/5017860
