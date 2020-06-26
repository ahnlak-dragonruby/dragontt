# DragonTT - a DragonRuby GTK port of the most excellent Tetris for Terminals (https://github.com/MikeTaylor/tt)
#            which I spent most of my University career playing (when I wasn't playing Nethack).
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
# Licensed under the MIT license; see LICENSE for more details

$gtk.require 'app/tetronimo.rb'
$gtk.require 'app/game.rb'
$gtk.require 'app/layout.rb'
$gtk.require 'app/scores.rb'
$gtk.require 'app/piece.rb'

# Initialiser; called at launch, this is where we set up everything for the initial state
def init args

  # Create a Game object which will hold everything about the game.
  args.state.game = Game.new()

  # Add the static background elements to the world
  layout args.grid, args.outputs
  scores_render args.state, args.grid, args.outputs

  # And set some state defaults
  args.state.player_name = 'Player'
  args.state.pieces = []

end

# Main tick handler; this is the thing that is called every frame
def tick args

  # In the very first tick, call our initialiser
  if args.state.tick_count == 0
    init args
  end

  # Set the background properly to white - seem to have to do this every frame
  args.outputs.background_color = [ 255, 255, 255, 255 ]

  # Now, if the game is running we can update it
  if args.state.game.running 

    # If the game is over, we're just dealing with the score
    if args.state.game.over

      # If we're in uientry mode, just render the entry box
      if args.state.uientry

        # Handle user input hitting enter
        if args.inputs.keyboard.key_down.enter
          args.state.uientry = false
        end

        # Also handle a click on the button?
        if args.inputs.mouse.click && 
           args.inputs.mouse.x.between?( args.grid.center_x - 50, args.grid.center_x + 50 ) &&
           args.inputs.mouse.y.between?( args.grid.center_y - 75, args.grid.center_y - 25 )
           args.state.uientry = false
        end

        # Might be a letter being added?
        if args.inputs.keyboard.key_down.raw_key >= 32 &&
           args.inputs.keyboard.key_down.raw_key <= 126 &&
           args.state.player_name.length < 10
          # Grr, have to capitalise things ourselves...
          if args.inputs.keyboard.key_down.shift
            args.state.player_name << args.inputs.keyboard.key_down.raw_key - 32
          else
            args.state.player_name << args.inputs.keyboard.key_down.raw_key
          end
        end

        if args.inputs.keyboard.key_down.backspace && args.state.player_name.length > 0
          if args.state.player_name.length == 1
            args.state.player_name = ""
          else
            args.state.player_name = args.state.player_name[0..args.state.player_name.length-2]
          end
        end

        # And then render the entry box
        scores_entry_render args.state, args.grid, args.outputs

      else

        # So, if we have the player name we can just save it and move on
        scores_save args.state, args.state.game.score, args.state.player_name
        scores_render args.state, args.grid, args.outputs

        # Reset the game to start everything over
        args.state.game.reset

      end

    else

      # Well then just update the game
      args.state.game.update args.inputs, args.state

      # And then we can do whatever rendering we want
      args.state.game.render args.outputs

      # See if the game has just ended, in which case set some flags
      if args.state.game.over
        args.state.uientry = true
      end

    end

  else

    # Prompt the user to press <space> to start
    args.outputs.labels << {
      x: args.grid.center_x,
      y: 360,
      text: "Press <SPACE> to start",
      alignment_enum: 1,
      size_enum: 2,
      r: 64,
      g: 0,
      b: 64,
      a: 64 + ( 128 - ( 4 * ( args.state.tick_count % 64 ) ) ).abs
    }

    # Every second, see if we should spawn more pieces drifting down
    if ( args.tick_count % 60 ) == 0 && args.state.pieces.length < 10
      args.state.pieces << Piece.new()
    end

    # Work through all those pieces, dropping, spinning and rendering
    args.state.pieces.each do |piece|
      piece.update
      args.outputs.primitives << piece.sprite
    end

    # Remove any that have fallen off the bottom
    args.state.pieces.reject! { |piece| piece.y < 0 }

    # And if they press it, start the game
    if args.inputs.keyboard.key_down.space
      args.state.game.start args.state
    end

  end

end

