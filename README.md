# 🦊 Scarlet-Shadow

<p align="center">
<img width="315" height="250" alt="5fLuia" src="https://github.com/user-attachments/assets/e471b000-af87-4615-876b-64e6ed14d878"/>
</p>
"Scarlet Shadow - The Inkvasion" is an exciting 2D platformer that plunges you into the dark depths of a cave set in feudal Japan. Battle through dangerous traps, escape the fearsome ink monsters. In this dark and menacing world, every step counts, and only those who act quick and precise will survive.
</br></br>
🎮 You can Download the Game on Itch.io:</br>
https://s4g.itch.io/scarlet-shadow


## 🎯 Skills & Software
- `Godot`
- `GDScript`
- `VFX`

## 🗝️ Key Aspects
- **Combat** and **Movement** for 2D Platformer
- **Dynamic Camera System** for controlling the player view
- **Level Transitions** to always land in the right spot

## 🚩 Personal & Design Goals

In this Project I worked on a 2D Platformer in the style of Hollow Knight. The player character was the main focus and everything he does and around him had to feel really good. Futhermore the player movement had to be tight, so the platforming parts don't feel unfair to the player. I spend a great amount of time on refining the movement and implementing all sorts of tricks like ledge grabs, coyote time and support for easier walljumps. The movement is inspired by games like Hollow Knight, Celest or Super Meatboy but with its own style.
</br></br>


### 🦊 Movement Tester:
<img align="right"  width="500"   alt="Movement Tester" src="https://github.com/user-attachments/assets/38c936e5-005a-4ff2-b3f1-758a2a97f92f" /> 
For my first Godot project, Scarlet Shadow, I built a small movement tester that was inspired by
<a href="https://dawnosaur.itch.io/platformer-movement-demo-2">DawnosaurDev</a> and was aimed at helping to find the best-fitting movement for the player character.

I added all the typical settings, such as coyote time, and made them adjustable. This made it easy to find the best-fitting movement and it was also interesting to see how everyone had a different idea of “perfect” movement.

It’s a small project, but it combines my love for good-feeling gameplay with the “procedural” aspect of changing and experimenting with settings until they match your ideal vision.

https://gizmooe.itch.io/2d-movement-tester
<br clear=all>


### 🦊 Character:
<img align="right" width="350" 
src="https://github.com/user-attachments/assets/68bf552b-17f9-4674-9a56-dfbcca7d851a"/>
The character took a lot of work and was the main focus for me. The image shows all the little checks the character does to give the optimal feel. There are checks for walls infront and behind him, to make wall jumps work as intended and help him stick to walls. Above his head are checks so the character slides around the corners of our tileset so he doesn't get stuck with only a few pixel of his head. Additionaly the character has the ability to do a ledge grab, which helps with tight jumps or when missing a platform.
</br></br>
</br></br>

### 🎥 Camera:
<img align="right" height="300" src="https://github.com/user-attachments/assets/ee5563b6-b4ae-4508-8fbf-ad16ee55efae" />
<img align="right" height="300" src="https://github.com/user-attachments/assets/f3a0ad70-8fe5-4e78-b70a-e59fccae0df2" />
The camera was another big part for the game. A normal camera that just smoothly follows the player was not enough so I added a few interesting features to it. First of all the camera should always have the character a bit off-center to show what is going on ahead of the player, this helps with navigating the level and not getting surprised by obstacles suddenly showing up. Another important part was to have the option to limit the camera movement in certain parts. An example would be the end of a Level, I wanted the camera to stop and not blocking half the screen with just walls. This also helped the level designers with the workload. The last part was a set camera. In certain spots the camera locks into a position, like in the gif on the right. This helps with guiding the player and gives a certain type of dynamic to the game.
</br></br>
</br></br>




### 🚪 Scene Changer:
<img align="right" src="https://github.com/user-attachments/assets/86053b6d-d570-493b-bf38-af0ca45fb817" width="450"/>
As Hollow Knight was a big inspiration I also wanted to have the ability to leave and re-enter a level / scene. I wrote the script and included easy to use presets so our designer can implement the "portals" and see the connections by color instead of looking everything up again.

</br></br></br></br></br></br></br></br></br>


