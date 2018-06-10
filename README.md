# invaders-game
Arcade game written in ARMv4 assembly code for NXP LPC 2105 microcontroller. The game image is memory mapped and cannon is controled by UART keyboard interruptions.

## Rules

1. Press `Space` to start the game.
2. Kill as much enemies as you can (default: up to 3).
3. Do not waste your bullets (default: 10) or you'll run out of them and lose the game.
4. Every time you hit a enemy, you recover one bullet.
5. Endless time. No limit.
6. Enjoy!

## Controls

Key | Action
--- | ------
`Space` | Shoot cannon
`K` | Move cannon to left
`L` | Move cannon to right
`+` | Increase speed of bullets
`-` | Decrease speed of bullets
`A` | Increase speed of enemies
`Z` | Decrease speed of enemies
`Q` | Exit game


## Screenshots

Game start screen | Initial status
----------------- | ----------------
![Start screen](/Screenshots/01.png) | ![Play screen](/Screenshots/02.png)

Shoot and score | Kill three invaders and win
--------------- | ----------------
![Bullets screen](/Screenshots/03.png) | ![Win screen](/Screenshots/04.png)

Waste ten bullets and lose |
-------------------------- |
![Game over screen](/Screenshots/05.png)  
