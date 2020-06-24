# game.rb - part of DragonTT
#
# The Game object handles the running of the actual game, in two fundamental
# functions - update and render. Keeping these logically divorced feels... right

class Game

    # Constants
    BOARD_WIDTH = 10
    BOARD_HEIGHT = 20
    MAX_LEVEL = 16

    # Attributes
    attr_reader :running
    attr_reader :over
    attr_reader :score
    attr_reader :board_origin_x
    attr_reader :board_origin_y

    # Constructor; flags the game as not yet in progress
    def initialize

        @running = false
        @over = false
        @board = Array.new( BOARD_HEIGHT ) { Array.new( BOARD_WIDTH ) { :none } }
        @board_origin_x = $gtk.args.grid.center_x - ( ( BOARD_WIDTH * 32 ) / 2 )
        @board_origin_y = 32

    end

    # Try to spawn a new piece
    def spawn

        # Create a new Tetronimo of a random form
        @current = Tetronimo.new(:random, @board, @board_origin_x, @board_origin_y)

    end

    # Start a new game; clear the board, reset the score and level
    def start state

        # Reset everything.
        (0..BOARD_HEIGHT-1).each do |row| 
            (0..BOARD_WIDTH-1).each do |column|
                @board[row][column] = :none
            end
        end
        @board[0][0] = :ell
        @board[0][9] = :ell

        @level = 1
        @score = 0
        @pieces = 0

        # Spawn the first new piece of the game
        spawn 

        # And set the running flag
        @running = true

    end

    # Reset the game over flag, once we've saved the score
    def reset

        @running = false
        @over = false
    
    end

    # Update the game world, based on time and the user inputs
    def update inputs, state

        # Clear any completed lines from the board. Done here so the user
        # gets a fleeting glimpse of the full lines!
        (0..BOARD_HEIGHT-1).each do |row|

            # Look for any spaces in the row
            spaces = false
            (0..BOARD_WIDTH-1).each do |column|
                if @board[row][column] == :none
                    spaces = true
                end
            end

            # If we didn't find any, move everything above down
            if !spaces

                @score += 10
                (row+1..BOARD_HEIGHT-1).each do |above|
                    (0..BOARD_WIDTH-1).each do |column| 
                        @board[above-1][column] = @board[above][column]
                    end
                end

                # And of course, blank the top row
                (0..BOARD_WIDTH-1).each do |column| 
                    @board[BOARD_HEIGHT-1][column] = :none
                end

            end
        end

        # Check for user input before anything
        if inputs.keyboard.key_down.up || inputs.keyboard.key_down.w
            @current.rotate true
        end

        if inputs.keyboard.key_down.down || inputs.keyboard.key_down.s
            @current.rotate false
        end

        if inputs.keyboard.key_down.left || inputs.keyboard.key_down.a
            @current.shift -1
        end

        if inputs.keyboard.key_down.right || inputs.keyboard.key_down.d
            @current.shift 1
        end

        if inputs.keyboard.key_down.space
            @current.dropping = true
        end

        # See if the piece is currently dropping
        if @current.dropping 

            # Obviously it depends a bit on being able to
            if !@current.descend?

                # Then we've hit bottom. Time to copy this to the board,
                # and then spawn a new piece
                land

            end

        else

            # Then see if it's time for the current piece to drop another row
            if @level == MAX_LEVEL || state.tick_count % ( 50 - ( 3 * @level ) ) == 0

                # Obviously it depends a bit on being able to
                if !@current.descend?

                    # Then we've hit bottom. Time to copy this to the board,
                    # and then spawn a new piece
                    land

                end

            end

        end

    end

    # Handle a Tetronimo landing on the pile
    def land

        # Copy the piece onto the board
        @current.elements.each do |brick|

            # If any element of the Tetronimo is off the board, it's game over
            if brick[0] >= BOARD_HEIGHT
                @over = true
                return
            end

            @board[brick[0]][brick[1]] = @current.type

        end

        # Add the score and the piece count
        @score += @current.value
        @pieces += 1

        if ( @pieces % 15 ) == 0 && @level < MAX_LEVEL
            @level += 1
        end

        # Spawn a new piece then
        spawn

        # Lastly, do a quick check - if this new piece isn't clear, it's game over
        if !@current.clear?
            @over = true
        end

    end

    # Renders the current state of the world, shouldn't do any updating though!
    def render outputs

        # Obviously if we're not even running there isn't much to do
        if !@running || @over
            return
        end

        # Render the board contents first
        (0..BOARD_HEIGHT-1).each do |row| 
            ( 0..BOARD_WIDTH-1).each do |column|
                case @board[row][column]
                when :none
                    # Leave the board blank there
                else
                    # Output the appropriate brick type
                    outputs.primitives << { 
                        x: @board_origin_x + ( column * 32 ),
                        y: @board_origin_y + ( row * 32 ),
                        w: 32,
                        h: 32,
                        path: "sprites/brick_#{ @board[row][column] }.png"
                    }.sprite
                end
            end
        end

        # And then the current Tetronimo
        @current.render outputs

        # Lastly the scores
        outputs.labels << {
            x: 240,
            y: 240,
            text: "%05d" % @score,
            alignment_enum: 0,
            size_enum: 2,
        }
        outputs.labels << {
            x: 240,
            y: 210,
            text: "%02d" % @level,
            alignment_enum: 0,
            size_enum: 2,
        }
                

    end

end