# Changelog

## v0.2.0

- Update plant textures so they look a whole lot better
- Add hover over tooltips to main menu
- Add ambience music (unique for day, night and when it's raining)
- Add a ton of sound effects (almost 50!)
- Improve the look of options screen and the main menu buttons
- Add 32 bit versions both for linux and windows
- Move the clock label out of clock to improve readability (by a lot)

*Bug fixes:*

- Remove some plant lights - current godot 2d light engine is too unoptimized and hard to work with
- Fix spelling errors in Journal
- Fix some graphics on the main menu title picture
- Fix the "Brew x different potions" achivement (was 20, but only 15 potions exist)
- Make the weeds sprite easier to spot by adding more
- Remove the outline from the save icon, it was the only one that had an outline
- Fix journal buttons sometimes being clickable even when not open
- Make sure shoveling a plant doesn't count as a harvest for the "Harvest x plants" achivements
- Make sure baskets show up when loading a save
- Fix items flying in from the screen corner when clearing cauldron

## v0.1.3

Add plant breaking animation
Add moveable baskets in the basement
Add potion shelves in the basement
Update basaement background and cauldron texture
Add effect when using luck potion
Make dried out fields easier to understand
Implement rain
Fix growth potion growth rates
Add clear cauldron button
Add a button to quickly brew previous potion
Update how-to-play with more info
Add category titles in the journal
Add a fallback font to user inputs and the journal - now supports CJK
Move save file location out of weird godot/app_userdata directory
Make fields blend better with the grass around
Fix various small bugs
