# tetronimo.rb - part of DragonTT
#
# This defines a class to handle the definition and rendering of individual pieces.
# Apologies in advance to anyone who actually knows Ruby for the terrible programming
# techniques I'm about to demonstrate.
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
# Licensed under the MIT license; see LICENSE for more details

class Tetronimo

    attr_reader :type
    attr_reader :value
    attr_accessor :dropping

    # Shape definitions, common to all Tetronimos
    @@pieces = {
        :ell =>     [[[ 0, 0], [ 1, 0], [ 2, 0], [ 2, 1]],
                     [[ 0, 1], [ 1,-1], [ 1, 0], [ 1, 1]],
                     [[ 0,-1], [ 0, 0], [ 1, 0], [ 2, 0]],
                     [[ 1,-1], [ 1, 0], [ 1, 1], [ 2,-1]]],
        :ellback => [[[ 0, 0], [ 1, 0], [ 2,-1], [ 2, 0]],
                     [[ 1,-1], [ 1, 0], [ 1, 1], [ 2, 1]],
                     [[ 0, 0], [ 0, 1], [ 1, 0], [ 2, 0]],
                     [[ 0,-1], [ 1,-1], [ 1, 0], [ 1, 1]]],
        :ess =>     [[[ 0, 0], [ 0, 1], [ 1,-1], [ 1, 0]],
                     [[ 0,-1], [ 1,-1], [ 1, 0], [ 2, 0]],
                     [[ 0, 0], [ 0, 1], [ 1,-1], [ 1, 0]],
                     [[ 0,-1], [ 1,-1], [ 1, 0], [ 2, 0]]],
        :essback => [[[ 0,-1], [ 0, 0], [ 1, 0], [ 1, 1]],
                     [[ 0, 0], [ 1,-1], [ 1, 0], [ 2,-1]],
                     [[ 0,-1], [ 0, 0], [ 1, 0], [ 1, 1]],
                     [[ 0, 0], [ 1,-1], [ 1, 0], [ 2,-1]]],
        :long =>    [[[ 0, 0], [ 1, 0], [ 2, 0], [ 3, 0]],
                     [[ 1,-1], [ 1, 0], [ 1, 1], [ 1, 2]],
                     [[ 0, 0], [ 1, 0], [ 2, 0], [ 3, 0]],
                     [[ 1,-1], [ 1, 0], [ 1, 1], [ 1, 2]]],
        :square =>  [[[ 0, 0], [ 0, 1], [ 1, 0], [ 1, 1]],
                     [[ 0, 0], [ 0, 1], [ 1, 0], [ 1, 1]],
                     [[ 0, 0], [ 0, 1], [ 1, 0], [ 1, 1]],
                     [[ 0, 0], [ 0, 1], [ 1, 0], [ 1, 1]]],
        :tee =>     [[[ 1,-1], [ 1, 0], [ 1, 1], [ 2, 0]],
                     [[ 0, 0], [ 1, 0], [ 1, 1], [ 2, 0]],
                     [[ 0, 0], [ 1,-1], [ 1, 0], [ 1, 1]],
                     [[ 0, 0], [ 1,-1], [ 1, 0], [ 2, 0]]],
    }

    @@points = {
        :ell     => 3,
        :ellback => 3,
        :ess     => 5,
        :essback => 5,
        :long    => 2,
        :square  => 4, 
        :tee     => 1,
    }

    # Inspect, because debugging is ... hard
    def inspect

        "Tetronimo: type: #{@type}, value: #{@value}, rotation: #{@rotation}, grid_row: #{@grid_row}, grid_col: #{@grid_col}"

    end

    # constructor
    def initialize type, board, board_origin_x, board_origin_y

        # If a random type has been requested, pick a random one
        if type == :random
            case rand(7)
            when 0
                @type = :ell
            when 1
                @type = :ellback
            when 2
                @type = :ess
            when 3
                @type = :essback
            when 4
                @type = :long
            when 5
                @type = :square
            when 6
                @type = :tee
            end
        else
            @type = type
        end

        @bricks = @@pieces[@type]
        @value = @@points[@type]

        # Place it somewhere sensible
        @rotation = rand(4)
        @grid_row = 20
        @grid_col = 5

        # Save the details of the board
        @board = board
        @board_origin_x = board_origin_x
        @board_origin_y = board_origin_y

        @dropping = false

    end

    # Move the piece down a line
    def descend?

        if clear? @grid_col, @grid_row-1, @rotation
            @grid_row -= 1
            return true
        end

        return false

    end

    # Shift one column to the left (negative) or the right (positive)
    def shift? direction

        if clear? @grid_col + direction, @grid_row, @rotation
            @grid_col += direction
            return true
        end

        return false

    end

    # Spin the piece in place
    def rotate? clockwise

        if clockwise
            newrot = ( @rotation + 1 ) % 4
        else
            newrot = ( @rotation + 3 ) % 4
        end

        if clear? @grid_col, @grid_row, newrot
            @rotation = newrot
            return true
        end

        return false

    end

    # Check to see if the provided position would cause a clash on the grid
    def clear? col = nil, row = nil, spin = nil

        # If any of our arguments are missing, default to the current values
        if col == nil
            col = @grid_col
        end
        if row == nil
            row = @grid_row
        end
        if spin == nil
            spin = @rotation
        end

        # So, if the piece in it's current orientation was at col, row
        # would it hit an element in the board (or drop off the board)?
        @bricks[spin].each do |brick|

            # Side bounds matter even if we're off the top of the board
            if (row+brick[0]) < 0 ||
               (col+brick[1]) < 0 || (col+brick[1]) >= Game::BOARD_WIDTH
                return false
            end

            # If we're on the board, check the contents 
            if (row+brick[0]) < Game::BOARD_HEIGHT && @board[row+brick[0]][col+brick[1]] != :none
                return false
            end

        end

        # Everything is fine then. Yes, it's a return. I'm a C coder.
        return true

    end

    # Returns an array of elements that represent the Tetronimo position
    def elements

        # We'll build up an array of co-ordinates
        pieces = []

        # And work through the current bricks
        @bricks[@rotation].each do |brick|

            # Apply the current grid position to this bricks
            pieces.append( [ @grid_row + brick[0], @grid_col + brick[1] ] )

        end

        return pieces

    end

    # Render ourselves; this is done with individual bricks now, so we can easily
    # manage position and rotation in relation to the board
    def render outputs

        # Work through each brick in the current brick orientation
        @bricks[@rotation].each do |brick|

            outputs.primitives << {
                x: @board_origin_x + ( ( @grid_col + brick[1] ) * 32 ),
                y: @board_origin_y + ( ( @grid_row + brick[0] ) * 32 ),
                w: 32,
                h: 32,
                path: "sprites/brick_#{@type.to_s}.png"
            }.sprite

       end

    end

end
