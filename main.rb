require 'ruby2d'

#Window setup
set width: 500
set height: 500
set title: "Undyne Simulator"
set background: 'black'

#Sound setup
wooshSound = Sound.new('audio/wooosh.wav')
@waowSound = Sound.new('audio/waow.mp3')
@pingSound = Sound.new('audio/ping.mp3')
@damageSound = Sound.new('audio/damage.mp3')
@deathSound = Sound.new('audio/death.mp3')
@inversionSound = Sound.new('audio/invert.mp3')
@healSound = Sound.new('audio/heal.mp3')
@bgm = Music.new('audio/spearofjustice.mp3')
@redSpearSfxThrow = Sound.new('audio/redSpearThrow.mp3')

@bgm.play
@bgm.loop = true

#Image setup
@player = Image.new(
    'sprites/greenHeart.png',
    width: 30, height: 30,
    x: 235, y: 235
)
@shield = Image.new(
    'sprites/shield.png',
    width: 50, height: 30, 
    x: @player.x-10, y: @player.y-35 
)
@turboSpear = Image.new(
    'sprites/turboSpear.png',
    width: 150, height: 150,
    x: 1000, y: 1000
)
@borderVertical = Image.new(
    'sprites/borderVert.png',
    width: 96, height: 128,
    x: @player.x-33, y: 186
)

@borderVertical.remove

@healthBarBG = Rectangle.new(
    x: 430, y: 35,
    width: 60, height: 22,
    color: 'red',
    z: -1
)
@healthBarFG = Rectangle.new(
    x: 430, y: 35,
    width: 60, height: 22,
    color: 'yellow',
    z: 1
)

#Text setup
@hpText = Text.new(
    "HP",
    font: 'fonts/determination.ttf',
    x: 400, y: 0,
    size: 30
)
@timeText = Text.new(
    "TIME",
    font: 'fonts/determination.ttf',
    x: 5,
    size: 30
)
@recordText = Text.new(
    "",
    font: 'fonts/determination.ttf',
    color: 'yellow',
    x: 5, y: 30,
    size: 20
)
lastScoreText = Text.new(
    "",
    font: 'fonts/determination.ttf',
    color: 'gray',
    x: 5, y: 50,
    size: 20
)

#Sprite anim setup
deathAnimGreen = Sprite.new(
    'sprites/deathSheet.png',
    clip_width: 500,
    time: 1000,
    loop: false,
    width: 30, height: 30,
    x: 235, y: 235
)
deathAnimRed = Sprite.new(
    'sprites/deathsheetRed.png',
    clip_width: 500,
    time: 1000,
    loop: false,
    width: 30, height: 30,
    x: 235, y: 235
)
@redSpearAnimLeft = Sprite.new(
    'sprites/redSpearSheet.png',
    clip_width: 17,
    time: 100,
    loop: false,
    width: 50, height: 30,
    x: 240 - (@borderVertical.width / 2) + 3, y: 250 + (@borderVertical.height / 2) - 33
)
@redSpearAnimMid = Sprite.new(
    'sprites/redSpearSheet.png',
    clip_width: 17,
    time: 100,
    loop: false,
    width: 50, height: 30,
    x: 225, y: 250 + (@borderVertical.height / 2) - 33
)
@redSpearAnimRight = Sprite.new(
    'sprites/redSpearSheet.png',
    clip_width: 17,
    time: 100,
    loop: false,
    width: 50, height: 30,
    x: 255 + (@borderVertical.width / 2) - 48, y: 250 + (@borderVertical.height / 2) - 33
)
@redSpearSprite = Image.new(
    'sprites/redSpearAction.png',
    width: 150, height: 150,
    x: 1000, y: 1000
)
@redSpearSprite2 = Image.new(
    'sprites/redSpearAction.png',
    width: 150, height: 150,
    x: 1000, y: 1000
)

#Hide sprites after creation
@redSpearAnimLeft.remove
@redSpearAnimMid.remove
@redSpearAnimRight.remove
deathAnimGreen.remove
deathAnimRed.remove

@spearHeavy = Image.new(
    'sprites/heavy.png',
    width: 30, height: 30, 
    x: 1000, y:1000
)
@spearLight = Image.new(
    'sprites/light.png',
    width: 30, height: 30, 
    x: 1000, y:1000
)
@spearTurnaround = Image.new(
    'sprites/turnaround.png',
    width: 30, height: 30, 
    x: 1000, y:1000
)
@nextHealer = Image.new(
    'sprites/health.png',
    x: 1000, y:1000
)

#Savefile setup

@saveDataFile = 'saveData.txt'
@saveDataArray = File.readlines(@saveDataFile)
@recordTime = 0

#VAR SETUP
def INITIATE_VARIABLES()
    @godmode = false

    @startTime = Time.now
    @tick = 0

    @heartColour = "green"

    @hp = 20
    @multiplier = 1.0
    @damage = 0
    @healing = 3
    @inRow = 0
    @spearsFired = 0
    @distance = 500

    @hpText.text = "HP: #{@hp}"

    @hasCollided = true
    @turboSpearSent = false
    @healerHasCollided = true
    @hasTurned = false

    @redSpear1IsWindup = false
    @redSpear2IsWindup = false
    @redSpearX = 0
    @redSpearTimerWindup = 0
    @redSpearSprite.remove
    @redSpearTimer = 0

    @isFirstRed = true
    @hasDied = false

    @availablePositions = ["left", "mid", "right"]
    @keysHeld = []
end

# Initiate all variables on first start
INITIATE_VARIABLES()

# Function updateSpeed()
# Changes the heart's "speed" variables depending on keys held.
# This only changes the "speed" variables, and does not move the heart. The heart is moved according to these variables in the update function.

def updateSpeed()
    p @keysHeld

    @x_speed = 0 # Set the 
    @y_speed = 0

    @x_speed -= 2 if @keysHeld.include?('left')
    @x_speed += 2 if @keysHeld.include?('right')
    @y_speed -= 2 if @keysHeld.include?('up')
    @y_speed += 2 if @keysHeld.include?('down')
end

on :key_down do |event| # Called when any key is pressed
    @keysHeld << event.key unless @keysHeld.include?(event.key) # Adds the keys currently being pressed to an array which is used to determine red heart movement in the updateSpeed() function.
    if @heartColour == "red" # Calls the updateSpeed function when the heart is red, allowing for free movement with the arrow keys
        updateSpeed()
    end
    if @keysHeld.include?('left ctrl') && @keysHeld.include?('left shift') && @keysHeld.include?('g') # Cheat code to enable invincibility
        @godmode = true
    end
    if event.key == 'up' # Moves the shield around with the arrow keys while the heart is green 
        if @heartColour == "green" && @shield.rotate != 0
            wooshSound.play

            @shield.rotate = 0
            @shield.x = @player.x-10
            @shield.y = @player.y-35 
        end
    elsif event.key == 'right'
        if @heartColour == "green" && @shield.rotate != 90
            wooshSound.play

            @shield.rotate = 90
            @shield.x = @player.x+25
            @shield.y = @player.y
        end
    elsif event.key == 'down'
        if @heartColour == "green" && @shield.rotate != 180
            wooshSound.play

            @shield.rotate = 180
            @shield.x = @player.x-10
            @shield.y = @player.y+35 
        end
    elsif event.key == 'left'
        if @heartColour == "green" && @shield.rotate != 270
            wooshSound.play

            @shield.rotate = 270
            @shield.x = @player.x-45
            @shield.y = @player.y
        end
    elsif event.key == 'escape'
        close
    end
end

on :key_up do |event| # Called when any key is released
    if @heartColour == "red"
        @keysHeld.delete(event.key)
        updateSpeed()
    end
end

# Function updateMultiplier()
# Updates the "multiplier" variable depending on how long the current game has been running for. 
# Essentially, multiplier determines difficulty/speed in the game.
def updateMultiplier()
    @multiplier = (1 + (@elapsedTime/30))
end

# Function updateMultiplier()
# Updates the player's health with the argument "amount".
# Argument be both negative and positive, changes health respectively.
def updateHP(amount)

    if @godmode == false # Checks if cheat mode is enabled.
        @hp += amount
        @healthBarFG.width += (amount * 3) # Changes the healthbar width according to argument. Multiplied by 3 to match healthbar size in pixels proportionally.

        if amount > 0 # Plays different sounds depending on whether you are healed or take damage.
            @healSound.play
        elsif amount < 0
            @damageSound.play
        end

        if @hp > 20 # Ensures that HP does not exceed the maximum of 20
            @hp = 20
            @healthBarFG.width = (@hp * 3)
        elsif @hp < 0
            @hp = 0
            @healthBarFG.width = 0
        end
    end
    
    @hpText.text = "HP: #{@hp}" # Updates GUI text for health
end


# Function spawnTurbospear()
# Creates the spear that changes heart colour and updates variables accordingly
def spawnTurbospear()
    @turboSpearSent = true
    @turboSpear.add
    @waowSound.play
    @turboTimer = 0
    @turboTimerStart = Time.now
    @turboSpear.x = 700
    @turboSpear.y = -350
end

# Function spawnSpear()
# Function that spawns spears for green heart mode.
def spawnSpear()
    updateMultiplier()
    @orientation = ""
    @hasTurned = false
    $nextSpearDirection = [[235, -35, 0, 3, 180, "north"], [535, 235, -3, 0, 270, "east"], [235, 535, 0, -3, 0, "south"], [-35, 235, 3, 0, 90, "west"]].sample
    if @elapsedTime > 15 # Ensures that "turnaround" spears only spawn after 15 seconds have elapsed.
        @nextSpearType = ["spearHeavy", "spearLight", "spearTurnaround"].sample
        if @spearsFired > rand(10..15) # Calls the spawnTurbospear function after a certain amount of spears have been fired.
            spawnTurbospear()
            @spearsFired = 0
        else
            spawnHealer = rand(1..7) # Randomizes a number to see if the healing bandaid will spawn.
        end
    else
        @nextSpearType = ["spearHeavy", "spearLight"].sample
    end
    @spearsFired += 1
    @orientation = $nextSpearDirection[5]
    if @nextSpearType == "spearHeavy" # Configures the specifications of the current spear being fired.
        @damage = -8 # Damage that will be dealt if spear hits
        @multiplier -= 0.5 # Temporarily change "multiplier" so that spear moves at a specific speed.
        @nextSpear = Image.new(
        'sprites/heavy.png',
        width: 30, height: 30,
        x: $nextSpearDirection[0], y: $nextSpearDirection[1],
        rotate: $nextSpearDirection[4]
        )
    elsif @nextSpearType == "spearLight"
        @damage = -2
        @multiplier += 1
        @nextSpear = Image.new(
        'sprites/light.png',
        width: 30, height: 30,
        x: $nextSpearDirection[0], y: $nextSpearDirection[1],
        rotate: $nextSpearDirection[4]
        )
    elsif @nextSpearType == "spearTurnaround"
        @damage = -5
        @multiplier -= 0.3
        @nextSpear = Image.new(
        'sprites/turnaround.png',
        width: 30, height: 30,
        x: $nextSpearDirection[0], y: $nextSpearDirection[1],
        rotate: $nextSpearDirection[4]
        )
    end
    if spawnHealer == 1 # Spawns healing bandaid if the chances are right.
        @healerHasCollided = false

        @healerDirection = [[235, -35, 0, 3, 180, "north"], [535, 235, -3, 0, 270, "east"], [235, 535, 0, -3, 0, "south"], [-35, 235, 3, 0, 90, "west"]].sample

        @damage = 3
        @nextHealer = Image.new(
        'sprites/health.png',
        width: 50, height: 50,
        x: @healerDirection[0], y: @healerDirection[1],
        rotate: @healerDirection[4]
        )
    end
end

# Function doTurnaround
# Function that handles the "turnaround" that the yellow spear does.
def doTurnaround()
    if @orientation == "north" # Depending on current orientation, the yellow spear inverts its position.
        @nextSpear.y = 375
        @nextSpear.rotate = 0
    elsif @orientation == "east"
        @nextSpear.x = 125
        @nextSpear.rotate = 90
    elsif @orientation == "south"
        @nextSpear.y = 125
        @nextSpear.rotate = 180
    elsif @orientation == "west"
        @nextSpear.x = 375
        @nextSpear.rotate = 270
    end
    newX = @nextSpear.x # Store new position in a new variable
    newY = @nextSpear.y
    newRot = @nextSpear.rotate # Store new rotation in a new variable
    @inversionSound.play
    @nextSpear.remove
    @nextSpear = Image.new('sprites/blackSpear.png', # Create a new black spear where the yellow one turned to, only a visual effect.
    x: newX, y: newY,
    rotate: newRot,
    width: 30, height: 30
    )
    @nextSpear.add
    set background: 'white'
    @hasTurned = true
end

# Function changeHeart()
# Changes heart depending on argument "colour"
# Argument is of type string
def changeHeart(colour)
    @keysHeld = []
    @player.remove
    @turboSpear.remove
    @turboSpear.x = 1000
    @turboSpear.y = 1000
    @turboSpearSent = false # Updates variables relating to the "turboSpear", since this function is called when the turboSpear is supposed to disappear.

    @pingSound.play

    if colour == "green" # Updates heart and several variables depending on argument
        
        @redSpearTimer = 0
        @redSpearTimerStart = Time.now
        @spearsFired = 0
        @heartColour = "green"
        @player = Image.new(
        'sprites/greenHeart.png',
        width: 30, height: 30,
        x: 235, y: 235
        )
        @borderVertical.remove # Removes the white border that confines the red heart
        @redSpearSprite2.remove
        @redSpearSprite.remove
        @player.add
        @shield.add
    elsif colour == "red"
        @damage = -3
        @redSpearSprite2.remove
        @redSpearSprite.remove
        @redSpearsFired = 0
        @nr1HasCollided = true
        @nr2HasCollided = true
        @redSpear1IsWindup = true
        @redSpearTimerStart = Time.now
        @redSpearTimerWindupStart = Time.now
        @redSpearTimerWindup = 1
        @heartColour = "red"
        @player = Image.new(
        'sprites/redHeart.png',
        width: 30, height: 30,
        x: 235, y: 235
        )
        @borderVertical.add
        @player.add
        @shield.remove
    end
end

# Function fireRedSpear()
# Creates the spears that fire when the heart is red
# Argument "pos" is always an integer that determines where the spear will spawn (left, right, or middle)
def fireRedSpear(pos)
    @redSpearSprite = Image.new(
    'sprites/redSpearAction.png',
    width: 40, height: 30,
    x: pos + 5, y: 250 + (@borderVertical.height / 2) - 25
)
    @redSpearSprite.add
end

def fireRedSpear2(pos)
    @redSpearSprite2 = Image.new(
    'sprites/redSpearAction.png',
    width: 40, height: 30,
    x: pos + 5, y: 250 + (@borderVertical.height / 2) - 25
)
    @redSpearSprite2.add
end

# Function spawnRedSpear()
# Sets up variables relating to the spears that fire when the heart is red.
def spawnRedSpear(count)
    @availablePositions = ["left", "mid", "right"]
    @redSpearAnimLeft.remove
    @redSpearAnimMid.remove
    @redSpearAnimRight.remove
    @redSpearSprite.remove
    @redSpearSprite2.remove
    
    firstRedSpear = rand(0..2)
    redSpearPos1 = @availablePositions[firstRedSpear]
    @availablePositions.delete_at(firstRedSpear)

    if count == 2
        secondRedSpear = rand(0..1)
        redSpearPos2 = @availablePositions[secondRedSpear]
        @availablePositions.delete_at(secondRedSpear)
    end

    @redSpearSprite2.remove
    @redSpearSprite.remove

    @waowSound.play
    if redSpearPos1 == "left"
        @redSpearAnimLeft.add
        @redSpearAnimLeft.play do
            @redSpearAnimLeft.remove
            @redSpear1IsWindup = true
            @redSpearTimerWindup = 0
            @redSpearTimerWindupStart = Time.now
            @redSpearX = @redSpearAnimLeft.x
            fireRedSpear(@redSpearX)
        end
    elsif redSpearPos1 == "mid"
        @redSpearAnimMid.add
        @redSpearAnimMid.play do
            @redSpearAnimMid.remove
            @redSpear1IsWindup = true
            @redSpearTimerWindup = 0
            @redSpearTimerWindupStart = Time.now
            @redSpearX = @redSpearAnimMid.x
            fireRedSpear(@redSpearX)
        end
    elsif redSpearPos1 == "right"
        @redSpearAnimRight.add
        @redSpearAnimRight.play do
            @redSpearAnimRight.remove
            @redSpear1IsWindup = true
            @redSpearTimerWindup = 0
            @redSpearTimerWindupStart = Time.now
            @redSpearX = @redSpearAnimRight.x
            fireRedSpear(@redSpearX)
        end
    end

    if redSpearPos2 == "left"
        @waowSound.play

        @nr2HasCollided = false
        @redSpearAnimLeft.add
        @redSpearAnimLeft.play do
            @redSpearAnimLeft.remove
            @redSpear2IsWindup = true
            @redSpear2TimerWindupStart = Time.now
            @redSpearX2 = @redSpearAnimLeft.x
            fireRedSpear2(@redSpearX2)
        end
    elsif redSpearPos2 == "mid"
        @waowSound.play

        @nr2HasCollided = false
        @redSpearAnimMid.add
        @redSpearAnimMid.play do
            @redSpearAnimMid.remove
            @redSpear2IsWindup = true
            @redSpear2TimerWindupStart = Time.now
            @redSpearX2 = @redSpearAnimMid.x
            fireRedSpear2(@redSpearX2)
        end
    elsif redSpearPos2 == "right"
        @waowSound.play

        @nr2HasCollided = false
        @redSpearAnimRight.add
        @redSpearAnimRight.play do
            @redSpearAnimRight.remove
            @redSpear2IsWindup = true
            @redSpear2TimerWindupStart = Time.now
            @redSpearX2 = @redSpearAnimRight.x
            fireRedSpear2(@redSpearX2)
        end
    end
    
end

# Function respawn()
# Function that resets the game and respawns the player.
def respawn()
    sleep(2)
    changeHeart("green")
    @recordText.text = @recordTime
    INITIATE_VARIABLES()
    @healthBarBG.add
    @healthBarFG.width = 60
    @player.add
    @shield.add
    @bgm.play
    @hasDied = false

    @startTime = Time.now
    updateHP(0)
    updateMultiplier()
end

# Checks the saved high score, and applies it to the on screen text. This only runs once.
if @saveDataArray[0].to_f > 0
    @recordTime = @saveDataArray[0].to_f
    @recordText.text = @recordTime
end

update do # Called 60 times per second
    if @hp <= 0 # Handles what happens when player dies, updates variables accordingly.
        if @elapsedTime > @saveDataArray[0].to_f
            @recordTime = @elapsedTime

            SAVE_HIGHSCORE()
        end 
        if !@hasDied
            @bgm.stop
            @deathSound.play
            if @heartColour == "green" # Plays specific death animations depending on heart colour
                deathAnimGreen.add
            elsif @heartColour == "red"
                deathAnimRed.add
                deathAnimRed.x = @player.x
                deathAnimRed.y = @player.y
            end
            @hasDied = true
        end        

        hp = 0

        @redSpearsFired = 0
        @spearsFired = 0

        @shield.remove #?
        @player.remove
        @healthBarBG.remove
        @redSpearSprite.remove
        @redSpearSprite2.remove
        @hpText.text = ""
        @timeText.text = ""
        @recordText.text = ""

        if @heartColour == "green"
            deathAnimGreen.play do
                deathAnimGreen.remove
                respawn()
            end
        elsif @heartColour == "red"
            deathAnimRed.play do
                deathAnimRed.remove
                respawn()
            end
        end
    end


    if !@hasDied # Handles what happens when the game is running and the player is alive
        @elapsedTime = Time.now - @startTime #Update time passed since game start
        @timeText.text = "#{@elapsedTime}"
        @tick += 1

        if @heartColour == "red" # Handles what happens when the heart colour is red
            updateSpeed()
            @player.x += @x_speed # Applies movement to the red heart by incrementing its position
            @player.y += @y_speed
            if @player.x > (250 + (@borderVertical.width / 2) - @player.width) # Makes sure that the player is confined to the white border
                @player.x = (250 + (@borderVertical.width / 2) - @player.width - 1)
            elsif @player.x < (250 - (@borderVertical.width / 2))
                @player.x = (250 - (@borderVertical.width / 2) + 1)
            end
            if @player.y < (250 - (@borderVertical.height / 2))
                @player.y = (250 - (@borderVertical.height / 2) + 1)
            elsif @player.y > (250 + (@borderVertical.height / 2) - @player.height) 
                @player.y = (250 + (@borderVertical.height / 2) - @player.width - 1)
            end

            if @nr1HasCollided # Runs if the first spear hasn't been fired
                @redSpearTimer = Time.now - @redSpearTimerStart # Timer until next spear spawns
                if @redSpearTimer > (1.5 - @multiplier)
                    @redSpearTimer = 0
                    
                    @nr1HasCollided = false # Spear 1 has been fired, makes sure this if-statement doesn't run again until the spear has disappeared.
                    @redSpearsFired += 1
                    if @isFirstRed == false && @nr2HasCollided == true && @turboSpearSent == false # If 5 spears have been sent, 2 spears are spawned. Else 1 spear.
                        @nr2HasCollided = false # Spear 2 has been fired. 

                        spawnRedSpear(2) # Spawn 2 spears
                    elsif @isFirstRed
                        spawnRedSpear(1) # Spawn 1 spear
                    end
                end
            elsif @nr1HasCollided == false # Active when the first spear has been fired
                # Collision
                if @redSpearSprite.contains?(@player.x + 15, @player.y + 15) # If the spear hits the player
                    @redSpearSprite.y = 1000
                    @redSpearSprite.x = 1000
                    @redSpearSprite.remove
                    @nr1HasCollided = true
                    updateHP(@damage)

                    updateMultiplier()
                elsif @redSpearSprite.y < (250 - (@borderVertical.height / 2)) # If the spear hits the end of the border
                    @redSpearTimerStart = Time.now
                    @redSpearSprite.y = 1000
                    @redSpearSprite.x = 1000
                    @redSpearSprite.remove
                    @nr1HasCollided = true

                    updateMultiplier()
                end

                if @redSpear1IsWindup == false # If the first spear's windup is over, fire the spear
                    @redSpearSprite.y -= (@multiplier * 3)
                else
                    @redSpearTimerWindup = Time.now - @redSpearTimerWindupStart # Update the elapsed time on the first spear's windup
                    if @redSpearTimerWindup > (0.7 - (@multiplier/10))
                        @redSpear1IsWindup = false
                        @redSpearSfxThrow.play
                    end
                end
            end
            
            if @nr2HasCollided == false # Same as the above, but for the second spear. 
                # Collision
                if @redSpearSprite2.contains?(@player.x + 15, @player.y + 15)
                    @redSpearSprite2.y = 1000
                    @redSpearSprite2.x = 1000
                    @redSpearSprite2.remove
                    @nr2HasCollided = true
                    updateHP(@damage)

                    updateMultiplier()
                elsif @redSpearSprite2.y < (250 - (@borderVertical.height / 2))
                    @redSpearSprite2.y = 1000
                    @redSpearSprite2.x = 1000
                    @redSpearSprite2.remove
                    @nr2HasCollided = true

                    updateMultiplier()
                end
                
                # Movement/windup
                if @redSpear2IsWindup == false
                    @redSpearSprite2.y -= (2 + @multiplier)
                else
                    @redSpear2TimerWindup = Time.now - @redSpear2TimerWindupStart
                    if @redSpear2TimerWindup > (1.5 - @multiplier + (rand(0.1..0.5)))
                        @redSpear2IsWindup = false
                        @redSpearSfxThrow.play
                    end
                end
            end

            if @redSpearsFired > 3
                @isFirstRed = false
            end
            if @redSpearsFired == rand(7..15) # Spawns the spear that changes heart colour after a certain random amount 
                spawnTurbospear()
                @redSpearsFired = 16
            end

            if @turboSpearSent # Moves the spear that changes heart colour, also handles collission
                @turboTimer = Time.now - @turboTimerStart
                if @turboTimer >= 2

                    p @turboSpear.x
                    p @turboSpear.y
                    @turboSpear.x -= 10
                    @turboSpear.y += 10
                end
                if @turboSpear.contains?(@borderVertical.x + 15, @borderVertical.y + 15) && @heartColour == "red" # Collided
                    changeHeart("green")
                    @hasCollided = true


                    updateMultiplier()
                end
            end
        end
        
        if @heartColour == "green" # Handles what happens when the heart colour is green
            if @inRow == 3 # If the player blocks 3 spears in a row, heal player by 2 units of HP
                updateHP(2)
                @inRow = 0
            end

            if @turboSpearSent # Handles what happens when the spear that changes heart colour has been spawned
                @turboTimer = Time.now - @turboTimerStart # Timer
                if @turboTimer >= 2 # If the timer is higher than 2 seconds, move the spear
                    @turboSpear.x -= 10
                    @turboSpear.y += 10
                end
                if @turboSpear.contains?(@player.x + 15, @player.y + 15) && @heartColour == "green" # Collision
                    changeHeart("red")
                    @hasCollided = true
                    @nr1HasCollided = true
                    @nr2HasCollided = true
                    @turboSpearSent = false

                    updateMultiplier()
                end
            end

            if @tick % rand(30..60) == 0 && @hasCollided == true && @turboSpearSent == false # Spawns spear if the conditions are met
                spawnSpear()
                @hasCollided = false
            elsif @hasCollided == false && @turboSpearSent == false # Called when a spear has been spawned
                if @healerHasCollided == false # Moves the healing bandaid if it has been spawned
                    @nextHealer.x += (@healerDirection[2] * (@multiplier + 1.1))
                    @nextHealer.y += (@healerDirection[3] * (@multiplier + 1.1))
                end
                if @nextSpearType != "spearTurnaround" # Moves spears that are not the turnaround spear
                    @nextSpear.x += ($nextSpearDirection[2] * @multiplier)
                    @nextSpear.y += ($nextSpearDirection[3] * @multiplier)
                elsif @nextSpearType == "spearTurnaround" # Handles movement for the turnaround spear
                    
                    #if (@player.x - @nextSpear.x) > 150 && $nextSpearDirection[1] == 235 && $nextSpearDirection[0] <= 0 || (@nextSpear.x - @player.x) < 150 && $nextSpearDirection[1] == 235 && $nextSpearDirection[0] >= 500 || (@player.y - @nextSpear.y) > 150 && $nextSpearDirection[0] == 235 && $nextSpearDirection[1] <= 0 || (@nextSpear.y - @player.y) > 150 && $nextSpearDirection[0] == 235 && $nextSpearDirection[1] >= 500
                    if !@hasTurned # Before it has turned
                        dx = @player.x - @nextSpear.x 
                        dy = @player.y - @nextSpear.y
                        @distance = Math.sqrt(dx * dx + dy * dy)
                    end

                    if @distance > 150 # Before it turns
                        @nextSpear.x += ($nextSpearDirection[2] * @multiplier)
                        @nextSpear.y += ($nextSpearDirection[3] * @multiplier)
                    else
                        if @hasTurned == false # Turn
                            doTurnaround()
                        elsif @hasTurned == true # Move after turn
                            @nextSpear.x += (-$nextSpearDirection[2] * @multiplier)
                            @nextSpear.y += (-$nextSpearDirection[3] * @multiplier)
                        end
                    end

                end
                if @nextSpear.contains?(@shield.x + 15, @shield.y + 15) # Collission with shield
                    @inRow += 1
                    @hasCollided = true
                    @nextSpear.remove
                    @nextSpear.x = 1000
                    @pingSound.play
                    set background: 'black'

                    updateMultiplier()
                elsif @nextSpear.contains?(@player.x + 15, @player.y + 15) # Collision with player
                    @inRow = 0
                    @hasCollided = true
                    @nextSpear.remove
                    @nextSpear.x = 1000
                    updateHP(@damage)

                    updateMultiplier()
                    set background: 'black'
                end
                if @nextHealer.contains?(@shield.x + 15, @shield.y + 15) # Healer collission (shield)
                    @healerHasCollided = true
                    @nextHealer.remove
                    @nextHealer.x = 1000
                    @nextHealer.y = 1000
                    @pingSound.play
                elsif @nextHealer.contains?(@player.x + 15, @player.y + 15) # Healer collission (player)
                    @healerHasCollided = true
                    @nextHealer.remove
                    @nextHealer.x = 1000
                    @nextHealer.y = 1000
                    updateHP(@healing)
                end
            end
        end
    end
end


# Removes the previous highscore and replaces it with the current highscore.
def SAVE_HIGHSCORE()
    f = File.open(@saveDataFile)
    File.write(@saveDataFile, @recordTime.to_s)
    f.close
end

# Removes highscore and replaces it with 0
def RESET_HIGHSCORE()
    f = File.open(@saveDataFile)
    File.write(@saveDataFile, "0")
    f.close
end

show