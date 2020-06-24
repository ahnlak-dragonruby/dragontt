# scores.rb - part of DragonTT
#
# Handles the loading, saving and rendering of the high score tables.
# There is code in here about which I am ... not proud.



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

    # Fetch in the current table
    scores_load state

    # Add the new score to the list
    state.scores.entries << "%05d:#{name}" % score

    # Sort it in place
    state.scores.entries = state.scores.entries.sort.reverse.take(10)

    # And then save the top ten entries
    $gtk.serialize_state( 'scores.txt', state.scores )

end