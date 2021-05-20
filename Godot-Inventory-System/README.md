# Godot-Inventory-System
Thanks for using my system

!!! FONT IN THIS PROJECT WORKS ONLY FOR ENGISH LANGUAGE IF YOU WANT USE OTHER LANGUAGES USE DIFFERENT FONT !!!

Font was taken from this site https://caffinate.itch.io/abaddon

!!! IF YOU ADD NEW UI FOR CHEST OR EVERYTHING ADD NODE PUT DISPLAY SCRIPT ON IT THAN EVERY ROW PUT ON ITS OWN NODE (EVEN IF ITS ONLY ONE ROW) OR CODE WOULDN'T WORK !!!

For example go to res://ui/storages/small_chest/SmallChestDisplay.tscn

Project have showcase scene res://showcase/Showcase.tscn

If you want add drop item go to res://PlayerShowcase.gd this code have this fucntion already and you only need to write it

How to add inventory to your project:
1) Drag and drop everything from folder to your project exept showcase folder
2) Put all scripts in preload_scripts in data foulders in Project/ProjectSettings/AutoLoad (Dont change names of scripts or it woundn't work)
3) Make 5 new Actions in Project/ProjectSettings/InputMap: E (E key), EXIT (Escape key), WheelUp (Device 0, Wheel Up), WheelDown (Device 0, Wheel Down), Shift (Shift key)
4) Copy all code from PlayerShowcase.gd to your main player code and delete PlayerShowcase.gd
5) Add to your main scene in game CanvasLayer node: Add to CanvasLayer node res://ui/inventory/Inventory.tscn
6) Add to your main scene in game CanvasLayer node (2 layer) and it needs to be highter that previous node: Add to CanvasLayer node res://ui/mouse/Mouse.tscn
If everything done right you should have working inventory in your game

How add new item:
1) Do to data folder
2) Open file Items.json (not visible in godot)
3) Add new id and add everything you want to it ( item needs to have everything that "0" item have)
4) Add texture to it in res://items/inventory_sprites/
5) Dont forger to add name

How add name to item:
1) If you want more localisation files in your game add them in res://data/language_data/"your language"/"what you want to add" and change this res://data/LanguageData.gd code
2) Do to res://data/language_data/
3) Open folder with language you want to use and open items folder
4) Open description.json
5) Add name and description and everything you want
6) If you want to change look of description go to res://ui/mouse/Description.tscn and change it

How to make custom cursor
1) Change this file res://ui/mouse/cursor.png or this scene res://ui/mouse/Mouse.tscn

How to make your own storage:
1) Don't forger to change code of player detection in res://storages/small_chest/ChestObj.gd to your needs
2) Copy everything from res://storages/small_chest/ChestObj.gd and change sprite_type, storage_type, ui_type and inventory_id to your own: Add in res://data/storages.json id of storage that you wrote in your storage
3) In res://storages/small_chest/ChestObj.gd you will see, how you need to put your files: 'res://storages/%s/sprites/%sSprFrames.tres' % [storage_type,sprite_type] etc
4) In res://ui/storages/StorageDisplay.gd you will see how put ui of chests: "res://ui/storages/%s/%s.tscn" % [current_storage.storage_type,current_storage.ui_type] etc

How to make new slot type:
1) Textrure of slot is here res://ui/inventory/empty_cell.png
2) Go to res://ui/inventory/InventorySlotDisplay.gd
3) Add new type and add functionality in content_manipulation
4) Add hot keys in _on_button_up()
