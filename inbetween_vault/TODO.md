## Player
- [ ] Add juice to movement animations (scale squishing etc.)
- [x] Allow player to jump to specific spot on wall
	- [x] Add deadzone for jump state checking slide
- [x] Add force to SLIDE state when on wall that the wall is respected (will require change to last_movement_direction or whatever is doing the sprite)
- [x] Add rotary progress bar to hide
- [x] Add cooldown to hide
- [x] Add particles to hide
- [x] Add dash effect on double-tap
- [x] Add dash cool down timer progress bar
- [ ] Add kill state to player
	- [ ] Make panic animation

## Guide
- [x] Draw guide sprite
- [ ] Create guide dialogue system (fixed in place on screen)

## Seeker
- [x] Update polygon to be collision-based
- [x] Add line attack (basic)
- [x] Add particle to collision
- [ ] Add patrol tooling
- [ ] Add 8-direction seeker (Can turn on/off rays)
	- [ ] Needs new sprite (multi-eye)
	- [x] Refactor beam creation to support multiple beams
- [ ] Add target seeker (always knows where you are)
	- [ ] Needs new sprite
- [ ] Add charger (blindly moves towards the last player location, then looks around with a short glance erratically)
	- [ ] Needs new sprite
- [x] Fix bug with detecting the player - seems to be inconsistent

## Level
- [x] Make platform generator
- [ ] Add platform - basic
- [ ] Add platform - see through
- [ ] Add platform - only visible in negative
- [ ] Add platform - activated
	- [ ] Add activation switch
	- [ ] Make pattern and colour based

## General
- [ ] Add sub-pixel movement shader to all sprites

## Juice
- [ ] Make line attack like a forked tongue with a little pause for drama