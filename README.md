# Mac Desktop Sorter

A lightweight macOS menu bar app that arranges Desktop icons through Finder.

## Features

- Sort by creation date, modification date, name, kind, or size.
- Toggle ascending and descending order from the active sorting row.
- Prioritize folders, files, or images while keeping the selected sort order within that group.
- Built-in quick profiles for recent work, active work, and archive layouts.
- Optional launch at login on macOS 13 or later.
- Shows progress in the menu bar while Finder is arranging icons.

The app never reads or modifies file contents. It only reads file metadata and asks Finder to update the visual position of Desktop icons.

## Build and run

1. Open `MacDesktopSorter.xcodeproj` in Xcode 15 or later.
2. In **Signing & Capabilities**, select your development team if Xcode asks you to.
3. Select **My Mac** and click Run.
4. Click the arrow icon in the menu bar.

Before sorting, right-click an empty area of the Desktop and choose **Sort By > None**. Finder's automatic arrangement can otherwise override the app's icon positions.

## Permission

On first use, macOS asks for permission to control Finder. Choose **Allow**. If you previously denied it, enable it in:

`System Settings > Privacy & Security > Automation > Mac Desktop Sorter > Finder`

The app does not require Accessibility or Full Disk Access.

## Known limitations

- Finder owns the Desktop presentation. Custom arrangements require one Finder automation request for each icon that needs to move, so a large initial rearrangement can take a few seconds.
- On multiple displays, existing icon slots are preserved. The app does not move icons between displays or infer display geometry.
- External volumes shown on the Desktop may not accept a position update; they are skipped without interrupting the remaining items.
