import os
from sys import argv
from PIL import Image

image = Image.open(f"map.png")

width, height = image.size

tileTypes = {
    #       R    G    B
    0   : (000, 000, 000), #EMPTY
    1   : (000, 000, 255), #WALL
    2   : (000, 100, 255), #BLOCK
    3   : (255, 255, 255), #BISCUIT
    4   : (150, 150, 150), #PILL
    5   : (000, 255, 000), #TUNNEL
    6   : (100, 100, 100), #WALKABLE
    "M" : (255, 255, 000), #PACMAN
    "B" : (255, 000, 000), #BLINKY
    "b" : (150, 000, 000), #BLINKYSCATTER
    "I" : (000, 255, 255), #INKY
    "i" : (000, 150, 150), #INKYSCATTER
    "P" : (255, 000, 255), #PINKY
    "p" : (150, 000, 150), #PINKYSCATTER
    "C" : (255, 150, 000), #CLYDE
    "c" : (150, 100, 000), #CLYDESCATTER
    "!" : ( 40,  40,  40), #LIVESCOUNTER
    "@" : ( 60,  60,  60), #LEVELCOUNTER
    "#" : ( 80,  80,  80), #HIGHSCORELABEL
    "$" : (120, 120, 120), #HIGHSCOREVALUE
    "%" : (140, 140, 140), #NAMETAG
    "^" : (160, 160, 160), #SCORECOUNTER
    "*" : (180, 180, 180), #GAMEOVERLABEL
    "(" : (200, 200, 200), #GAMEOVERLABEL
    ")" : ( 50,  50, 200), #PROPSPAWN
    "-" : (000, 150, 000)  #TUNNELHALLWAY
}

with open(os.path.dirname(__file__) + '/' + argv[1], 'w') as mapFile:
    for y in range(height):
        for x in range(width):
            pixel = image.getpixel((x, y))
            
            for key, value in tileTypes.items():
                if pixel[0] == value[0] and pixel[1] == value[1] and pixel[2] == value[2]:
                    mapFile.write(str(key))
                    break

        if y < height-1:
            mapFile.write("\n")

"""
python map.py mapdata
"""