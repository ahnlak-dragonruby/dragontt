# piece.rb - part of DragonTT
#
# A sprite class for handling whole pieces; oddly we don't use these in game because
# it's easier to work on a brick-by-brick basis, but we use it for some fancy display
# between games because it's a shame to have the graphics otherwise.
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
# Licensed under the MIT license; see LICENSE for more details

class Piece

    attr_sprite

    # Create a new sprite, pick a piece, position it at the top somewhere
    def initialize

        # Need to pick a piece to be
        case rand(7)
        when 0
            @path = 'sprites/piece4_ell.png'
            @w = 64
            @h = 96
        when 1
            @path = 'sprites/piece4_ellback.png'
            @w = 64
            @h = 96
        when 2
            @path = 'sprites/piece4_ess.png'
            @w = 64
            @h = 96
        when 3
            @path = 'sprites/piece4_essback.png'
            @w = 64
            @h = 96
        when 4
            @path = 'sprites/piece4_long.png'
            @w = 32
            @h = 128
        when 5
            @path = 'sprites/piece4_square.png'
            @w = 64
            @h = 64
        when 6
            @path = 'sprites/piece4_tee.png'
            @w = 96
            @h = 64
        end

        # And pick a place for it to be
        @x = rand(1280)
        @y = 720

        # Pick a spin
        @rotation = 2 - rand(5)

        # Fade it out a little
        @a = 128

    end

    # Update the location every tick
    def update

        @y -= 2
        @angle = ( @angle+@rotation ) % 360

    end

end

