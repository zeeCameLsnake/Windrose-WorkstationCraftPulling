# Workstation Craft Pulling

A Quality of Life (QoL) mod for Windrose that treats workstation output inventories just like regular storage chests! 

Normally, the game allows you to pull materials directly from nearby chests within a Bonfire's radius to craft items without having the materials in your personal inventory. However, materials resting in the **output slots** of other workstations (e.g., Coal sitting in a Kiln) were ignored. 

This mod integrates the output slots of all nearby workstations into the Bonfire's material network. You can now craft ingots in your Furnace using the coal sitting in your Kiln across the camp!

## Features
- **Seamless Craft Pulling:** Automatically pulls materials from any workstation's output slot within the Bonfire's radius.
- **Dynamic Updates:** Scans your base continuously to ensure newly built or moved workstations are instantly integrated into the local Bonfire network.
- **Multiplayer Ready:** Fully compatible with Singleplayer, Co-Op, and Dedicated Servers.

## Installation
*Requires UE4SS to be installed in your Windrose directory.*

1. Download the mod and extract the `WorkstationCraftPulling` folder.
2. Place the `WorkstationCraftPulling` folder into your `\Windrose\R5\Binaries\Win64\ue4ss\Mods\` directory.
3. Make sure the `enabled.txt` file is present inside the mod's root folder.
4. Launch the game!

## Multiplayer Installation

### Co-op (Host Game)
For co-op sessions, the installation is different for the host and the joining friends:
- **Joining Players (Clients) and Host:** Install the mod (and UE4SS) into your normal game directory as described in the main installation steps above.
- **Host only:** The host must install a *second copy* of the mod files (along with UE4SS) into the game's local server directory. This structure should typically look like this: `[YourDrive]:\SteamLibrary\steamapps\common\Windrose\R5\Builds\WindowsServer\R5\Binaries\Win64\ue4ss\Mods\WorkstationCraftPulling\`

### Dedicated Server
The installation process for dedicated servers can vary depending on your server provider and operating system. Generally, you need to ensure UE4SS is installed on the server and place the `WorkstationCraftPulling` folder into your server's UE4SS Mods directory:
`[ServerRoot]\R5\Binaries\Win64\ue4ss\Mods\WorkstationCraftPulling\`

## Known Issues & Workarounds
- **Visual Double-Counting at Current Station:** 
  When you open the crafting UI of a workstation that has materials in its *own* output slot, those materials will visually appear to be doubled in the material count. This happens because the game's native UI counts the local output, and then adds the Bonfire's network (which now also includes this local output thanks to the mod).
  
  **Note:** This is purely a visual bug. The game's server backend is secure and will **not** allow you to craft or duplicate items that don't physically exist. 

  **Workaround for "Craft Max" Slider:** 
  Because of this visual double-counting, pulling the slider all the way to "Max" will let you select a quantity that is higher than physically possible (the number stays green). However, if you click the Craft button with this inflated number, **nothing will happen** because the server/engine rejects it. You either have to slide it back down to the *actual* amount of materials you own, OR simply pull the intermediate items from the output slot into your personal inventory first. The UI will instantly correct itself, and you can slide to max and craft without issues!

## Technical Details (For Modders)
The mod runs a lightweight Lua loop that iterates through all `R5CraftStation` instances and calculates their distance to nearby `R5BuildingBlock_BuildingCenter` (Bonfires) using the Bonfire's native `HearthVolume` radius. It then safely injects the station's `InventoryView` pointers into the Bonfire's internal `InventoryAggregatorComponent` TArray, utilizing memory address checks (`GetAddress()`) to prevent array duplication.

Enjoy uninterrupted crafting!
