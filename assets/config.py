import os
from sys import argv

assetsExtensions = [".mp3", ".png"]
exclude = {
      "dirs":["spritesheets"],
      "files":[]
}

firstFile = True
with open(os.path.dirname(__file__) + '/' + argv[1], 'w') as configFile:
    for root, dirs, files in os.walk(os.path.dirname(__file__)):
            pathFolders = root.split("\\")
            if pathFolders[-1] in exclude["dirs"]:
                 continue
             
            for i, fld in enumerate(pathFolders):
                 if fld == "assets":
                    for file in files:
                        if file not in exclude["files"] and os.path.splitext(file)[1] in assetsExtensions:
                            if firstFile is False:
                                 configFile.write("\n")

                            firstFile = False
                            configFile.write("/".join(pathFolders[i:]) + f"/{file}")
                            if len(pathFolders[i+2:]) > 0:
                                configFile.write(f"~{'/'.join(pathFolders[i+2:]) + f'/{os.path.splitext(file)[0]}'}")
                            else:
                                configFile.write(f"~{os.path.splitext(file)[0]}")
                    break

"""
python config.py assetsconfig
"""