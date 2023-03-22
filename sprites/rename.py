import os
from sys import argv

fileExtension = ".png"
spriteType = {
    # r:right l:left u:up d:down  f:frightened e:eaten  B:blue W:white  t:thin k:thick Ch:sharpcorner Cs:softcorner Ci:innercorner Co:outercorner Uou:continuous  dh:death
    "font"   : ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","slash"),
    "blinky" : ("r1","r2","l1","l2","u1","u2","d1","d2"),
    "inky"   : ("r1","r2","l1","l2","u1","u2","d1","d2"),
    "pinky"  : ("r1","r2","l1","l2","u1","u2","d1","d2"),
    "clyde"  : ("r1","r2","l1","l2","u1","u2","d1","d2"),
    "ghosts" : ("fB1","fB2","fW1","fW2","er","el","eu","ed"),
    "pacman" : ("r1","r2","l1","l2","u1","u2","d1","d2","fill","dh1","dh2","dh3","dh4","dh5","dh6","dh7","dh8","dh9","dh10","dh11"),
    "walls"  : ("tUouB","tCsB","tChB","tkB","kUouB","kCiB","kCoB","tUouW","tCsW","tChW","tkW","kUouW","kCiW","kCoW", "block"),
    "props"  : ("dot","pill","cherry","strawberry","orange","apple","melon","galaxian","bell","key"),
} 

if len(argv) > 1:
    directory =  os.path.dirname(__file__) + "\\" + argv[1]

    for filename in os.listdir(directory):
        if filename.endswith(fileExtension):
            fileNumber = int(filename[len(argv[1]):].translate(str.maketrans("", "", fileExtension))) - 1
            os.rename(os.path.join(directory, filename), os.path.join(directory, spriteType[argv[1]][fileNumber] + fileExtension))
else:
    for key in spriteType.keys():
        dir = os.path.dirname(__file__) + "\\" + key
        if not os.path.exists(dir):
            os.makedirs(dir)

"""
python rename.py font
python rename.py blinky
python rename.py inky
python rename.py pinky
python rename.py clyde
python rename.py ghosts
python rename.py pacman
python rename.py walls
python rename.py props
"""