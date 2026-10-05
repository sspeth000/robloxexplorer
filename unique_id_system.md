# Unique ID System

## Overview

The Unique ID system identifies a Roblox Instance by describing its exact position in the Instance hierarchy.

Instead of relying on Roblox's `GetDebugId()`, the system generates a structural ID based on the position of an Instance inside its parent's `GetChildren()` list.

The resulting identifier looks like:

`uniqueIDstring[1.94.2]`

For example:

`pathstring:[game.Workspace.Donations.Leaderboard]uniqueIDstring[1.94.2]`

The path tells you **what the object is called and where it is located**, while the Unique ID tells you **where the object occurs within each level of the hierarchy**.

---

## How the ID Is Constructed

Every number in the Unique ID represents the 1-based position of an Instance inside its parent's `GetChildren()` array.

For example, imagine this hierarchy:

```text
game
└── Workspace
    └── Donations
        ├── Part
        ├── Folder
        └── Leaderboard
```

If `Leaderboard` is the third child of `Donations`, its final number would be:

`3`

The system continues upward through the hierarchy.

For example:

```text
game
└── Workspace
    └── Donations
        └── Leaderboard
```

Suppose:

- `Workspace` is child #1 of `game`
- `Donations` is child #94 of `Workspace`
- `Leaderboard` is child #2 of `Donations`

The resulting ID is:

`uniqueIDstring[1.94.2]`

---

## Hierarchical Structure

The ID is read from the top of the hierarchy toward the selected object.

For example:

1. `1` = position of `Workspace` under `game`
2. `94` = position of `Donations` under `Workspace`
3. `2` = position of `Leaderboard` under `Donations`

Therefore:

`1.94.2`

represents:

```text
game
→ child #1
→ child #94
→ child #2
```

The corresponding path might be:

`game.Workspace.Donations.Leaderboard`

Together:

`pathstring:[game.Workspace.Donations.Leaderboard]uniqueIDstring[1.94.2]`

---

## Why `GetChildren()` Is Used

The system uses:

```luau
parent:GetChildren()
```

to obtain the children of the current Instance.

It then searches that list until it finds the selected Instance.

Example:

```luau
for i, child in ipairs(parent:GetChildren()) do
    if child == current then
        index = i
        break
    end
end
```

If the selected object is the fifth child returned by `GetChildren()`, its index is:

`5`

This process is repeated for every parent until the hierarchy reaches `game`.

---

## The ID Generation Algorithm

The core algorithm works like this:

```luau
local function getUniqueID(instance)
    local numbers = {}
    local current = instance

    while current and current ~= game do
        local parent = current.Parent

        if not parent then
            break
        end

        local index = 0

        for i, child in ipairs(parent:GetChildren()) do
            if child == current then
                index = i
                break
            end
        end

        table.insert(numbers, 1, tostring(index))

        current = parent
    end

    return table.concat(numbers, ".")
end
```

### Step 1 — Start at the Selected Instance

If the selected object is:

`game.Workspace.Donations.Leaderboard`

the algorithm starts at:

`Leaderboard`

### Step 2 — Find Its Position

It gets the parent's children:

```luau
local parent = current.Parent
parent:GetChildren()
```

It then searches for the current Instance.

If `Leaderboard` is child #2:

`2`

is recorded.

### Step 3 — Move to the Parent

The algorithm then changes:

```luau
current = parent
```

Now it is examining `Donations`.

It finds where `Donations` occurs inside `Workspace`.

If it is child #94:

`94`

is recorded.

### Step 4 — Continue Upward

The process continues:

```text
Leaderboard → Donations → Workspace → game
```

For example:

```text
2
94
1
```

### Step 5 — Reverse the Numbers

Because the algorithm starts at the selected object and moves upward, the numbers are initially discovered backwards.

`table.insert(numbers, 1, ...)` places each new number at the beginning of the array.

This produces:

```text
1
94
2
```

instead of:

```text
2
94
1
```

### Step 6 — Join the Numbers

Finally:

```luau
table.concat(numbers, ".")
```

converts the array into:

`1.94.2`

---

## Why This Is Different From `GetDebugId()`

Roblox's:

```luau
instance:GetDebugId()
```

returns a Roblox-generated debugging identifier.

The structural Unique ID does not use that system.

Instead, it is calculated entirely from the Instance hierarchy.

```text
GetDebugId()
    ↓
Roblox-generated identifier

Structural Unique ID
    ↓
Hierarchy positions
```

This makes the structural ID easier to understand and reproduce.

---

## Important: The ID Is Structural, Not Permanently Unique

Despite the name "Unique ID", this system does **not** create a permanent UUID.

It is better described as a **hierarchical address**.

For example:

`1.94.2`

means:

```text
child 1 → child 94 → child 2
```

It identifies an Instance based on its current position in the hierarchy.

If the hierarchy changes, the ID can change.

---

## What Can Cause an ID to Change?

### Adding an Instance

Suppose:

```text
Donations
├── Part
├── Folder
└── Leaderboard
```

and `Leaderboard` is child #3.

Its ID ends in:

`.3`

If another Instance is inserted before it:

```text
Donations
├── Part
├── NewObject
├── Folder
└── Leaderboard
```

`Leaderboard` may now be child #4.

Its ID becomes:

`.4`

### Removing an Instance

If an Instance before the target is removed, the target's index can shift.

For example:

`1.94.4`

could become:

`1.94.3`

if one of the preceding children is removed.

### Moving an Instance

Moving an Instance to another parent changes its hierarchy completely.

For example:

`game.Workspace.FolderA.Part`

could become:

`game.Workspace.FolderB.Part`

The structural ID would therefore be recalculated based on the new hierarchy.

---

## Duplicate Names Are Not a Problem

Two Instances can have the same name:

```text
Workspace
├── Part
└── Folder
    └── Part
```

The paths are different:

```text
game.Workspace.Part
game.Workspace.Folder.Part
```

The structural IDs are also based on their actual Instance objects and positions.

The algorithm compares the Instance itself:

```luau
if child == current then
```

rather than comparing:

```luau
child.Name == current.Name
```

This is important because two objects can have identical names while being completely different Instances.

---

## Why the System Can Be Useful for an Inspector

The structural ID provides a compact way to describe an object's location.

Instead of only displaying:

`Part`

the inspector can display:

`pathstring:[game.Workspace.Folder.Part]uniqueIDstring[1.5.2]`

This gives two pieces of information:

### Path

`game.Workspace.Folder.Part`

Human-readable hierarchy.

### Unique ID

`1.5.2`

Structural position inside the hierarchy.

Together they provide a much more precise reference to the selected Instance.

---

## Complete Identifier Format

The complete identifier is generated with:

```luau
local function getIdentifier(instance)
    local path = getPath(instance)
    local uniqueID = getUniqueID(instance)

    return "pathstring:[" .. path .. "]uniqueIDstring[" .. uniqueID .. "]"
end
```

The final format is:

`pathstring:[PATH]uniqueIDstring[ID]`

For example:

`pathstring:[game.Workspace.Donations.Leaderboard]uniqueIDstring[1.94.2]`

---

## Summary

The Unique ID system works by converting an Instance's hierarchy into a sequence of child indexes.

For example:

```text
game
└── Workspace          # 1
    └── Donations      # 94
        └── Leaderboard # 2
```

becomes:

`1.94.2`

The system:

1. Starts at the selected Instance.
2. Finds its parent.
3. Gets the parent's children with `GetChildren()`.
4. Finds the selected Instance's position in that list.
5. Records the 1-based index.
6. Moves to the parent.
7. Repeats until reaching `game`.
8. Places each index at the beginning of the list.
9. Joins the indexes using `.`.
10. Produces the final structural ID.

Example:

`pathstring:[game.Workspace.Donations.Leaderboard]uniqueIDstring[1.94.2]`

The important distinction is that this is **not a permanent Roblox-generated UUID**. It is a deterministic hierarchical address based on the current Instance structure. It will remain the same while the relevant hierarchy and child ordering remain unchanged, but it can change when Instances are inserted, removed, reordered, or moved.
