Thanks for using my system

!!! FONT IN THIS PROJECT WORKS ONLY FOR ENGISH LANGUAGE IF YOU WANT USE OTHER LANGUAGES USE DIFFERENT FONT !!!

Font was taken from this site https://caffinate.itch.io/abaddon

!!! IF YOU ADD NEW UI FOR CHEST OR EVERYTHING ADD NODE PUT DISPLAY SCRIPT ON IT THAN EVERY ROW PUT ON ITS OWN NODE (EVEN IF ITS ONLY ONE ROW) OR CODE WOULDN'T WORK !!!
For example go to res://ui/storages/small_chest/SmallChestDisplay.tscn

Project have showcase scene res://showcase/Showcase.tscn

If you want add drop item go to res://PlayerShowcase.gd this code have this fucntion already and you only need to write it

How to add inventory to your project:
0) Drag and drop everything from folder to your project exept showcase folder
1) Put all scripts in preload_scripts and data foulders in Project/ProjectSettings/AutoLoad (Dont change names of scripts or it woundn't work)
2) Make 5 new Actions in Project/ProjectSettings/InputMap
2.1) E (E key)
2.2) EXIT (Escape key)
2.3) WheelUp (Device 0, Wheel Up)
2.4) WheelDown (Device 0, Wheel Down)
2.5) Shift (Shift key)
3) Copy all code from PlayerShowcase.gd to your main player code and delete PlayerShowcase.gd
4) Add to your main scene in game UIHolder.tscn
If everything done right you should have working inventory in your game

How add new item:
1) Do to data folder
2) Open file Items.json (not visible in godot)
3) Add new id and add everything you want to it ( item at least needs to have everything that 0 item have)
4) Add texture to it here res://items/inventory_textures/ and name it item(item_id)_texture.png
5) Dont forger to add name in res://data/language_data/languages.csv
6) If needed add it to existing inventory in res://data/Storages.json

How to make custom cursor
1) Change this file res://ui/inventory_displays/textures/cursor.png or this scene res://ui/inventory_displays/mouse/Mouse.tscn

How to make your own storage:
1) Copy everything from res://storages/small_chest/ChestObj.gd and change sprite_type, storage_type, ui_type to your own
2) In res://storages/small_chest/ChestObj.gd you will see, how you need to put your files
2.1) 'res://storages/%s/sprites/%sSprFrames.tres' % [storage_type,sprite_type] etc
3) Add storage size in res://data/StorageData.gd

How to make new slot type:
0) Textrure of slot is here res://ui/inventory_displays/textures/empty_slot.png
1) Go to res://ui/inventory_slot/InventorySlot.gd
2) Add new type and add functionality in content_manipulation
3) Add hot keys in _on_button_up()

How to add bag:
1) Create item and add to it tags [storage, bag] and property storage type
2) In res://data/Storages.json add inventory if needed
3) Add new storage size in res://data/StorageData.gd if its needed
