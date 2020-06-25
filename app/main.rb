# DragonTT - a DragonRuby GTK port of the most excellent Tetris for Terminals (https://github.com/MikeTaylor/tt)
#            which I spent most of my University career playing (when I wasn't playing Nethack).
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
# Licensed under the MIT license; see LICENSE for more details

$gtk.require 'app/tetronimo.rb'
$gtk.require 'app/game.rb'
$gtk.require 'app/layout.rb'
$gtk.require 'app/scores.rb'

# Initialiser; called at launch, this is where we set up everything for the initial state
def init args

  # Create a Game object which will hold everything about the game.
  args.state.game = Game.new()

  # Add the static background elements to the world
  layout args.grid, args.outputs
  scores_render args.state, args.grid, args.outputs

end

# Main tick handler; this is the thing that is called every frame
def tick args

  # In the very first tick, call our initialiser
  if args.state.tick_count == 0
    init args
  end

  # Now, if the game is running we can update it
  if args.state.game.running 

    # If the game is over, we're just dealing with the score
    if args.state.game.over


      # So, if we have the player name we can just save it and move on
      scores_save args.state, args.state.game.score, "Tetrominion"
      scores_render args.state, args.grid, args.outputs

      # Reset the game to start everything over
      args.state.game.reset

    else

      # Well then just update the game
      args.state.game.update args.inputs, args.state

      # And then we can do whatever rendering we want
      args.state.game.render args.outputs

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

    # And if they press it, start the game
    if args.inputs.keyboard.key_down.space
      args.state.game.start args.state
    end

  end

end

