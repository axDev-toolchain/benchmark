### Description for gnugo benchmark ###
DIR := $(call my-dir)

##### target = gnugo_bench ######
include $(BUILD)/clear.mk
TARGET := gnugo_bench

# Which file we measure the size
get_which_size=gnugo_bench

# Running commands
run_cmd=${PERFLAB_PATH}/gnugo_bench --quiet --mode gtp --gtp-input ${PERFLAB_INPUT}/viking.tst

target_srcs= \
  utils/getopt1.c \
  utils/getopt.c \
  utils/gg_utils.c \
  utils/random.c \
  utils/winsocket.c \
  engine/aftermath.c \
  engine/board.c \
  engine/boardlib.c \
  engine/breakin.c \
  engine/cache.c \
  engine/clock.c \
  engine/combination.c \
  engine/dragon.c \
  engine/endgame.c \
  engine/filllib.c \
  engine/fuseki.c \
  engine/genmove.c \
  engine/globals.c \
  engine/handicap.c \
  engine/hash.c \
  engine/influence.c \
  engine/interface.c \
  engine/matchpat.c \
  engine/montecarlo.c \
  engine/movelist.c \
  engine/move_reasons.c \
  engine/optics.c \
  engine/oracle.c \
  engine/owl.c \
  engine/persistent.c \
  engine/printutils.c \
  engine/readconnect.c \
  engine/reading.c \
  engine/semeai.c \
  engine/sgfdecide.c \
  engine/sgffile.c \
  engine/shapes.c \
  engine/showbord.c \
  engine/surround.c \
  engine/unconditional.c \
  engine/utils.c \
  engine/value_moves.c \
  engine/worm.c \
  sgf/sgf_utils.c \
  sgf/sgfnode.c \
  sgf/sgftree.c \
  interface/main.c \
  interface/play_gmp.c \
  interface/gmp.c \
  interface/play_solo.c \
  interface/play_test.c \
  interface/play_gtp.c \
  interface/gtp.c \
  interface/play_ascii.c \
  patterns/transform.c \
  patterns/oraclepat.c \
  patterns/apatterns.c \
  patterns/connections.c \
  patterns/dpatterns.c \
  patterns/influence.c \
  patterns/handipat.c \
  patterns/aa_attackpat.c \
  patterns/helpers.c \
  patterns/fuseki13.c \
  patterns/conn.c \
  patterns/fuseki9.c \
  patterns/owl_vital_apat.c \
  patterns/endgame.c \
  patterns/fusekipat.c \
  patterns/eyes.c \
  patterns/barriers.c \
  patterns/owl_attackpat.c \
  patterns/josekidb.c \
  patterns/owl_defendpat.c \
  patterns/patterns.c \
  patterns/fuseki19.c \
  patterns/mcpat.c

target_local_includes := src src/sgf src/utils src/patterns src/engine
target_local_cflags := -DHAVE_CONFIG_H

include $(BUILD)/build_executable.mk
