DragonTT
========

This is an implementation of the most excellent (if ancient) [Tetris for Terminals](https://github.com/MikeTaylor/tt),
which I spent more time playing at University than I should have done.

It's the first thing I've built in DragonRuby, and the first thing I've done with Ruby for what must be close
to 10 year so, be gentle.

My intention is to put together some notes to make this code a useful reference (if only in terms of how not to
do things in a proper Ruby style) but - and I cannot say this loudly enough - I am *not* a Ruby or DragonRuby expert
so don't take anything I do to be a recommendation :)

All that said, enjoy.

Scoring
-------

Scoring in TT is wonderfully rudimentary. You get points for each piece you drop (ranging from 2 to 5 points depending
on the piece) and points for clearing a line (10 points per line). There is no bonus for dropping. No bonus for clearing
multiple lines at once. 



