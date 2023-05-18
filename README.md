# Retro Pacman

Pacman is a classic arcade game where the player controls a character to eat all the food on a map while avoiding ghosts. This repository contains an implementation of the Pacman game in Lua with the Love2D framework, which can be played on desktop (Linux and Windows).

## Play in browser

[game](https://yoaquinjs.github.io/pacman/)

## Installation

To install the game on your local machine, follow these steps:

1. Clone the repository:
<div style="font-size: 12px">

```
git clone https://github.com/YoAquinJs/pacman.git
```

</div>

2. Navigate to the project directory:
<div style="font-size: 12px">

```
cd pacman
```

</div>

3. Build the game:
- For Windows:
    * enable execution for PowerShell scripts
    * run the build script in the root folder:
    
<div style="font-size: 12px">

```
./build.ps1
```

</div>

- For Linux:
    * enable execution for bash script running 
    * run the build script in the root folder:

<div style="font-size: 12px">

```
chmod +x build.sh
./build.sh
```

</div>

## Usage

To play the game, use the arrow keys on your keyboard to move the Pacman character. The objective of the game is to eat all the food on the map without getting caught by the ghosts. If you run into a ghost, you will lose a life. You can eat power pellets to temporarily make the ghosts vulnerable and eat them. The game ends when you lose all your lives. The game keeps a local highscores file, only saving the top 5 scores.

### User Customization

You can customize many aspects of the game through config files which contain information for many game mechanics:

- **Map Data**: the game uses a `mapdata` file for the grid information, such as wall allocation, corridors, tunnels, UI, etc. For accessibility and visualization purposes, a Python script converts a `map.png` image into the `mapdata` file. Follow the docs for modifying the map.

- **Levels Data**: the game uses a `leveldata` file for specifying game variables such as velocities, shiftings of game mode over time, etc. Follow the docs for modifying level data.

- **Game Data**: the game uses a `gamedata` file for specifying game constants such as lifes, screen size, etc. Follow the docs for modifying game data.

## Purpose

The game is part of my school's robotic fair project featuring a game arcade including Pacman and other RetroPie games

## Contributing

We welcome contributions to the Pacman repository! If you notice a bug in the game or have an idea for a feature that could improve it, please submit an issue on GitHub.


## License

This project is licensed under the MIT License. See the LICENSE file for more information.
