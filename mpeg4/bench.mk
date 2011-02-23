#### mpeg4 ####
DIR:=$(call my-dir)

# Which file we measure the size
get_which_size=mpeg4_bench

# Running commands
run_cmd=${PERFLAB_PATH}/mpeg4_bench -s 1280x720 -i ${PERFLAB_INPUT}/dance_100frame.avi -benchmark -y ${PERFLAB_INPUT}/mpeg4_output/dec_dance_frame_%03d.ppm; ${PERFLAB_PATH}/mpeg4_bench -i ${PERFLAB_INPUT}/mpeg4_output/dec_dance_frame_%03d.ppm -r 30 -s 1280x720 -sameq -g 9 -bf 3 -vcodec mpeg4 -benchmark -an  -y ${PERFLAB_INPUT}/enc_dance_output.avi

ffmpeg_cflags := -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_GNU_SOURCE
ffmpeg_includes :=  src/ src/libavutil src/libavcodec src/libavformat

#####################################
include $(BUILD)/clear.mk
TARGET := libavutil.a
#####################################

target_srcs := mathematics.c rational.c intfloat_readwrite.c crc.c
target_prefix := libavutil

target_local_includes := src/ src/libavutil
target_local_cflags := -DHAVE_AV_CONFIG_H -DBUILD_AVUTIL $(ffmpeg_cflags)

include $(BUILD)/build_library.mk

#####################################
include $(BUILD)/clear.mk
TARGET := libavcodec.a
#####################################

target_srcs := bitstream.c utils.c mem.c allcodecs.c \
      mpegvideo.c jrevdct.c jfdctfst.c jfdctint.c\
      mpegaudio.c ac3enc.c mjpeg.c resample.c resample2.c dsputil.c \
      motion_est.c imgconvert.c imgresample.c \
      mpeg12.c mpegaudiodec.c pcm.c simple_idct.c \
      ratecontrol.c adpcm.c eval.c error_resilience.c \
      fft.c mdct.c raw.c golomb.c cabac.c\
      dpcm.c adx.c faandct.c parser.c g726.c \
      vp3dsp.c h264idct.c rangecoder.c pnm.c h263.c msmpeg4.c h263dec.c \
      opt.c

target_srcs += aasc.c alac.c asv1.c avs.c cinepak.c cook.c cljr.c cyuv.c \
	dvbsubdec.c dvbsub.c dvdsub.c dvdsubenc.c dv.c 8bps.c ffv1.c \
	flac.c flicvideo.c 4xm.c fraps.c h261.c h264.c huffyuv.c \
	idcinvideo.c indeo2.c indeo3.c interplayvideo.c kmvc.c lcl.c \
	loco.c mace.c msrle.c msvideo1.c png.c qdm2.c qdrw.c qpeg.c \
	qtrle.c ra144.c ra288.c roqvideo.c rpza.c rv10.c shorten.c \
	smacker.c smc.c snow.c sonic.c svq1.c truemotion1.c truemotion2.c \
	truespeech.c tta.c tscc.c cscd.c lzo.c nuv.c rtjpeg.c \
	ulti.c vc9.c vcr1.c vmdav.c vorbis.c vp3.c vqavideo.c wmadec.c \
	wnv1.c ws-snd1.c xan.c xl.c bmp.c mmvideo.c zmbv.c


target_prefix := libavcodec

target_local_includes := src/ src/libavutil \
			$(android_root)/external/zlib

target_local_cflags :=  -DHAVE_AV_CONFIG_H
target_local_android_shared_libs :=

include $(BUILD)/build_library.mk

#####################################
include $(BUILD)/clear.mk
TARGET := libavformat.a
#####################################

target_srcs := utils.c cutils.c os_support.c allformats.c \
	mpeg.c mpegts.c mpegtsenc.c ffm.c crc.c img.c img2.c raw.c rm.c \
	avienc.c avidec.c wav.c mmf.c swf.c au.c gif.c mov.c mpjpeg.c dv.c \
	yuv4mpeg.c 4xm.c flvdec.c psxstr.c idroq.c ipmovie.c \
	nut.c wc3movie.c mp3.c westwood.c segafilm.c idcin.c flic.c \
	sierravmd.c matroska.c sol.c electronicarts.c nsvdec.c asf.c \
	ogg2.c oggparsevorbis.c oggparsetheora.c oggparseflac.c daud.c aiff.c \
	voc.c tta.c mm.c avs.c smacker.c nuv.c

# muxers
target_srcs += flvenc.c movenc.c asf-enc.c adtsenc.c

# image formats
target_srcs += pnm.c yuv.c png.c jpeg.c gifdec.c sgi.c framehook.c

# CONFIG_VEDEO4LINUX
target_srcs += grab.c

# CONFIG_VIDEO4LINUX2
target_srcs += v4l2.c

# CONFIG_DV1394
target_srcs += dv1394.c

# CONFIG_AUDIO_OSS
target_srcs += audio.c

# protocols I/O
target_srcs += avio.c aviobuf.c

# CONFIG_PROTOCOLS
target_srcs += file.c

# CONFIG_NETWORK
target_srcs += udp.c tcp.c http.c rtsp.c rtp.c rtpproto.c

target_prefix := libavformat
target_local_cflags := -DHAVE_AV_CONFIG_H $(ffmpeg_cflags)
target_local_includes := $(ffmpeg_includes) \
		$(android_root)/external/zlib

target_local_static_libs := libavutil libavcodec

include $(BUILD)/build_library.mk

#####################################
include $(BUILD)/clear.mk
TARGET := mpeg4_bench
#####################################

target_srcs := ffmpeg.c cmdutils.c

target_prefix :=
target_local_cflags := $(ffmpeg_cflags)

target_local_includes := src/ \
	src/libavutil   \
	src/libavcodec  \
	src/libavformat

target_local_android_static_libs :=
target_local_android_shared_libs := libz libdl
target_local_static_libs := libavformat libavcodec libavutil
target_local_shared_libs :=

include $(BUILD)/build_executable.mk
