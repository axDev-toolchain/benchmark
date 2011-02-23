# This test suite is based on games against the program Viking by
# Magnus Persson.

loadsgf /sdcard/perflab_input/viking1.sgf 23
1 reg_genmove white 
#? [E2]

loadsgf /sdcard/perflab_input/viking1.sgf 65
2 reg_genmove white 
#? [M15|B7]

loadsgf /sdcard/perflab_input/viking1.sgf 187
3 reg_genmove white 
#? [S5]

loadsgf /sdcard/perflab_input/viking1.sgf 189
4 reg_genmove white 
#? [B17|B18]

# Locally S5 is the only move.
loadsgf /sdcard/perflab_input/viking3.sgf 79
5 restricted_genmove white T8 T7 S7 R7 T6 T5 S5 T4 T3 T2 T1 S1 
#? [S5]

# A1 is of course inferior to B3
loadsgf /sdcard/perflab_input/viking3.sgf 93
6 restricted_genmove white B3 A1
#? [B3]

# The position cries out for a move at J13.
loadsgf /sdcard/perflab_input/viking3.sgf 103
7 reg_genmove white
#? [J13]

# K15 leaves too many cutting points.
loadsgf /sdcard/perflab_input/viking3.sgf 113
8 reg_genmove white
#? [K16]

# G19 is a very odd move.
loadsgf /sdcard/perflab_input/viking3.sgf 113
9 restricted_genmove white G19 J17
#? [J17]

