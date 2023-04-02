#!/bin/bash

sourceDir=$(pwd)
destinationZip="$sourceDir/pacman.love"
excludeExtensions=("*.love" "*.gitignore" "*.ps1" "*.md" "*.sh" "*.zip")
excludeFolders=(".vscode" ".git")

if [ -f "$destinationZip" ]; then
    rm "$destinationZip"
fi

filesToArchive=()
while IFS= read -r -d $'\0' file; do
    exclude=0
    for excludeExtension in ${excludeExtensions[@]}; do
        if [[ "$file" == *"$excludeExtension" ]]; then
            exclude=1
            break
        fi
    done

    if [ $exclude -eq 1 ]; then
        continue
    fi

    for excludeFolder in ${excludeFolders[@]}; do
        if [[ "$file" == *"$excludeFolder"* ]]; then
            exclude=1
            break
        fi
    done

    if [ $exclude -eq 1 ]; then
        continue
    fi

    filesToArchive+=("$file")
done < <(find "$sourceDir" -type f -print0)

mkdir "$sourceDir/files"

for file in "${filesToArchive[@]}"; do
    relativePath=$(echo "$file" | sed "s|^$sourceDir||" | sed 's|^/||')
    zipEntry="files/$relativePath"
    zipEntryDir=$(dirname "$zipEntry")
    if [ ! -d "$zipEntryDir" ]; then
        mkdir -p "$zipEntryDir"
    fi
    cp "$file" "$zipEntry"
done

zip -r "$destinationZip" "$sourceDir/files"

rm -r "$sourceDir/files"
