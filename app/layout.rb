# layout.rb - part of DragonTT
#
# Sets out the basic static elements of the display; kept here just to avoid
# cluttering up main.rb too much

def layout grid, outputs

  # Add the static background elements to the world
  outputs.static_sprites << { 
    x: grid.center_x - ( 384 /2 ),
    y: grid.bottom,
    w: 384,
    h: 672,
    path: "sprites/board.png"
  }

  outputs.static_labels << {
    x: grid.center_x,
    y: grid.top.shift_down( 10 ),
    text: "DragonTT",
    alignment_enum: 1,
    size_enum: 2
  }

  # Instructions, down the left hand side
  outputs.static_labels << {
    x: 240,
    y: 572,
    text: "Controls",
    alignment_enum: 1,
    size_enum: 2,
  }

  outputs.static_labels << {
    x: 240,
    y: 510,
    text: "Left : ",
    alignment_enum: 2,
    size_enum: 2,
  }
  outputs.static_labels << {
    x: 240,
    y: 510,
    text: "a / ←",
    alignment_enum: 0,
    size_enum: 2,
  }

  outputs.static_labels << {
    x: 240,
    y: 480,
    text: "Right : ",
    alignment_enum: 2,
    size_enum: 2,
  }
  outputs.static_labels << {
    x: 240,
    y: 480,
    text: "d / →",
    alignment_enum: 0,
    size_enum: 2,
  }

  outputs.static_labels << {
    x: 240,
    y: 450,
    text: "Rotate (cw) : ",
    alignment_enum: 2,
    size_enum: 2,
  }
  outputs.static_labels << {
    x: 240,
    y: 450,
    text: "w / ↑",
    alignment_enum: 0,
    size_enum: 2,
  }

  outputs.static_labels << {
    x: 240,
    y: 420,
    text: "Rotate (ccw) : ",
    alignment_enum: 2,
    size_enum: 2,
  }
  outputs.static_labels << {
    x: 240,
    y: 420,
    text: "s / ↓",
    alignment_enum: 0,
    size_enum: 2,
  }

  outputs.static_labels << {
    x: 240,
    y: 390,
    text: "Drop : ",
    alignment_enum: 2,
    size_enum: 2,
  }
  outputs.static_labels << {
    x: 240,
    y: 390,
    text: "<SPACE>",
    alignment_enum: 0,
    size_enum: 2,
  }

  # Level and score tags
  outputs.static_labels << {
    x: 240,
    y: 240,
    text: "Score : ",
    alignment_enum: 2,
    size_enum: 2,
  }

  outputs.static_labels << {
    x: 240,
    y: 210,
    text: "Level : ",
    alignment_enum: 2,
    size_enum: 2,
  }

end