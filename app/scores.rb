# scores.rb - part of DragonTT
#
# Handles the loading, saving and rendering of the high score tables.
# There is code in here about which I am ... not proud.
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
# Licensed under the MIT license; see LICENSE for more details


# Loads up the high score table, and renders it down the right hand side.
def scores_render state, grid, outputs

    # This is all semi-static content, so will go into static primitives.
    # The trouble is, we do need to update it occasionally, so sometimes
    # we need to remove it.

    # This is the line I'm not proud of; remove any static labels from the 
    # right of center. There are better ways to manage this...
    outputs.static_labels.reject! { |label| label.x > grid.center_x }

    # Load up the current high score table, if there is one.
    scores_load state

    # And now the high score stuff on the right hand side
    outputs.static_labels << {
        x: grid.right.shift_left( 240 ),
        y: 572,
        text: "High Scores",
        alignment_enum: 1,
        size_enum: 2,
    }

    # Work through the score table
    state.scores.entries.each_with_index do | entry, index |

        details = entry.split(':')

        outputs.static_labels << {
            x: grid.right.shift_left( 400 ),
            y: 510 - ( 30 * index ),
            text: "#{index}: #{details[1]}",
            alignment_enum: 0,
            size_enum: 2,
        }
        outputs.static_labels << {
            x: grid.right.shift_left( 160 ),
            y: 510 - ( 30 * index ),
            text: "#{details[0]}",
            alignment_enum: 0,
            size_enum: 2,
        }

    end


end

# Simple routine to load the scores
def scores_load state

    # Fetch in the current table
    scores = $gtk.deserialize_state( 'scores.txt' )

    if !scores

        # None found, so let's just assume a default empty array. To get
        # things to serialize properly, I seem to need it to be an entity.
        scores = $gtk.args.state.new_entity(:scores) do |e|
            e.entries = []
        end

    end

    # Stick it in the state, for ease
    state.scores = scores

end

# Saves the new high score
def scores_save state, score, name

    # Gotta have *a* name
    if name.length == 0
        name = "anon"
    end

    # Fetch in the current table
    scores_load state

    # Add the new score to the list
    state.scores.entries << "%05d:#{name}" % score

    # Sort it in place
    state.scores.entries = state.scores.entries.sort.reverse.take(10)

    # And then save the top ten entries
    $gtk.serialize_state( 'scores.txt', state.scores )

end

# Render an entry box asking for the user's name in the high score table
def scores_entry_render state, grid, outputs

    # Draw a nice box to work in, which needs to be a primitive to overwrite
    # the static elements
    outputs.primitives << {
        x: grid.center_x - 200,
        y: grid.center_y - 100,
        w: 400,
        h: 300,
        r: 255,
        g: 255,
        b: 255,
    }.solid
    outputs.primitives << {
        x: grid.center_x - 200,
        y: grid.center_y - 100,
        w: 400,
        h: 300,
        r: 0,
        g: 0,
        b: 0,
    }.border
    outputs.primitives << {
        x: grid.center_x - 199,
        y: grid.center_y - 99,
        w: 398,
        h: 298,
        r: 50,
        g: 50,
        b: 50,
    }.border

    # Drop in some appropriate prompting
    outputs.labels << {
        x: grid.center_x,
        y: grid.center_y + 150,
        text: "Enter Name",
        alignment_enum: 1,
        size_enum: 2,
    }

    # And then the text already entered, blanks and a cursor
    (0..9).each do |col|

        # Render out a letter if we have one
        if state.player_name.length >= col
            outputs.labels << {
                x: grid.center_x - 150 + ( col * 30 ),
                y: grid.center_y + 25,
                text: state.player_name[col],
                size_enum: 2,
            }
        end

        # Underline each letter
        outputs.lines << {
            x: grid.center_x - 150 + ( col * 30 ),
            y: grid.center_y,
            x2: grid.center_x - 150 + ( col * 30 ) + 15,
            y2: grid.center_y,
            r: 50,
            g: 50,
            b: 50,
        }

    end

    # The cursor is the last thing on the name front
    outputs.labels << {
        x: grid.center_x - 150 + ( state.player_name.length * 30 ),
        y: grid.center_y + 25,
        text: "-",
        size_enum: 2,
        a: 128,
    }

    # And lastly, the Big Friendly Button
    outputs.borders << {
        x: grid.center_x - 50,
        y: grid.center_y - 75,
        w: 100,
        h: 50,
        r: 0,
        g: 0,
        b: 0,
    }
    outputs.borders << {
        x: grid.center_x - 49,
        y: grid.center_y - 74,
        w: 98,
        h: 48,
        r: 50,
        g: 50,
        b: 50,
    }
    outputs.borders << {
        x: grid.center_x - 48,
        y: grid.center_y - 73,
        w: 96,
        h: 46,
        r: 100,
        g: 100,
        b: 100,
    }
    outputs.labels << {
        x: grid.center_x,
        y: grid.center_y - 35,
        text: "Ok",
        alignment_enum: 1,
        size_enum: 2,
    }

end
