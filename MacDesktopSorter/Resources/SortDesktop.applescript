-- Desktop Date Sorter
-- Finder is queried only twice: once for the item metadata and once to apply positions.
-- Positions already present on the desktop are reused, which also preserves multi-display layouts.

set descendingOrder to __DESCENDING__
set sortCriterion to "__CRITERION__"
set grouping to "__GROUPING__"

tell application "Finder"
    set desktopItems to every item of desktop
    set itemCount to count of desktopItems

    if itemCount is 0 then return 0

    if sortCriterion is "creationDate" then
        set sortValues to creation date of every item of desktop
    else if sortCriterion is "modificationDate" then
        set sortValues to modification date of every item of desktop
    else if sortCriterion is "name" then
        set sortValues to name of every item of desktop
    else if sortCriterion is "kind" then
        set sortValues to kind of every item of desktop
    else
        set sortValues to size of every item of desktop
    end if
    set desktopPositions to desktop position of every item of desktop
    set folderValues to {}
    repeat with desktopItem in desktopItems
        set end of folderValues to ((class of desktopItem) is folder)
    end repeat
end tell

-- Sort item indexes by creation date. A stable insertion sort makes equal dates predictable.
set itemIndexes to {}
repeat with i from 1 to itemCount
    set end of itemIndexes to i
end repeat

repeat with i from 2 to itemCount
    set currentIndex to item i of itemIndexes
    set currentValue to item currentIndex of sortValues
    set currentFolder to item currentIndex of folderValues
    set j to i - 1

    repeat while j ≥ 1
        set compareIndex to item j of itemIndexes
        set compareValue to item compareIndex of sortValues
        set compareFolder to item compareIndex of folderValues
        set shouldMove to false

        if grouping is "foldersFirst" and currentFolder and not compareFolder then
            set shouldMove to true
        else if grouping is "filesFirst" and (not currentFolder) and compareFolder then
            set shouldMove to true
        else if grouping is "none" or (currentFolder is compareFolder) then
            if descendingOrder then
                if compareValue < currentValue then set shouldMove to true
            else
                if compareValue > currentValue then set shouldMove to true
            end if
        end if

        if shouldMove then
            set item (j + 1) of itemIndexes to compareIndex
            set j to j - 1
        else
            exit repeat
        end if
    end repeat

    set item (j + 1) of itemIndexes to currentIndex
end repeat

-- Sort the existing slots in Finder's natural desktop order: right-to-left, then top-to-bottom.
set positionIndexes to {}
repeat with i from 1 to itemCount
    set end of positionIndexes to i
end repeat

repeat with i from 2 to itemCount
    set currentIndex to item i of positionIndexes
    set currentPosition to item currentIndex of desktopPositions
    set currentX to item 1 of currentPosition
    set currentY to item 2 of currentPosition
    set j to i - 1

    repeat while j ≥ 1
        set compareIndex to item j of positionIndexes
        set comparePosition to item compareIndex of desktopPositions
        set compareX to item 1 of comparePosition
        set compareY to item 2 of comparePosition
        set shouldMove to false

        if compareX < currentX then
            set shouldMove to true
        else if compareX = currentX then
            if compareY > currentY then set shouldMove to true
        end if

        if shouldMove then
            set item (j + 1) of positionIndexes to compareIndex
            set j to j - 1
        else
            exit repeat
        end if
    end repeat

    set item (j + 1) of positionIndexes to currentIndex
end repeat

tell application "Finder"
    repeat with i from 1 to itemCount
        set sourceIndex to item i of itemIndexes
        set positionIndex to item i of positionIndexes
        try
            set desktop position of item sourceIndex of desktopItems to item positionIndex of desktopPositions
        end try
    end repeat
end tell

return itemCount
