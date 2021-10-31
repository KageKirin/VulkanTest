

ffmpeg_call = ffmpeg -y -i $(1)	# base call
ffmpeg_call += -bf 0			# no B-frames (unsupported)
ffmpeg_call += -g 32			# GOP length (interval between I-frames)
ffmpeg_call += -vcodec libx264	# use x264 as codec
ffmpeg_call += -coder 0			# disable CABAC for baseline profile
ffmpeg_call += -refs 16			# use all 16 reference frames
ffmpeg_call += -flags +loop		# disable loop filter (+loop to enable)
ffmpeg_call += -wpredp 0		# disable weighted prediction
ffmpeg_call += -pass 1			# 1 pass
ffmpeg_call += -pix_fmt yuv420p	# baseline

# disabled
#ffmpeg_call += -flags2 -fastpskip	# disable fast P skips
#ffmpeg_call += -crf 10 # constant rate factor
#ffmpeg_call += -cqp 10 # constant quantizer mode
#ffmpeg_call += -flags2 +mixed_refs	# support mixed refs




encode_video = $(ffmpeg_call) $(2)

encode_gif = $(ffmpeg_call) \
		 -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
		 $(2)

encode_gif2 = ffmpeg -i $(1) -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" $(2)

encode_static = ffmpeg -y -i $(1) -c:v libx264 -pix_fmt yuv420p -preset slow -bf 0 -crf 10 -r 30 -vframes 1 $(2)


define encode
echo "source $(1)"
echo "target $(2)"
cp $(1) $(2)
endef



samples/mktest.h264: samples/fox.mp4
	$(call encode_video, $<, $@)

samples/sonic.h264: samples/sonic.mp4
	$(call encode_video, $<, $@)

samples/illusion.h264: samples/illusion.mp4
	$(call encode_video, $<, $@)

samples/primefactors.h264: samples/primefactors.mp4
	$(call encode_video, $<, $@)

samples/simonebiles.h264: samples/simonebiles.mp4
	$(call encode_video, $<, $@)

samples/dots.h264: samples/dots.mp4
	$(call encode_video, $<, $@)

samples/spinning.h264: samples/spinning.mp4
	$(call encode_video, $<, $@)

samples/empenada.h264: samples/empenada.mp4
	$(call encode_video, $<, $@)

samples/flowmap.h264: samples/flowmap.mp4
	$(call encode_video, $<, $@)

samples/jellyfish.h264: samples/jellyfish.mp4
	$(call encode_video, $<, $@)

samples/shoteffect.h264: samples/shoteffect.mp4
	$(call encode_video, $<, $@)

samples/thunderstorm.h264: samples/thunderstorm.mp4
	$(call encode_video, $<, $@)

samples/thunderstorm2.h264: samples/thunderstorm2.mp4
	$(call encode_video, $<, $@)

samples/tree.h264: samples/tree.mp4
	$(call encode_video, $<, $@)

samples/mozilla_story.h264: samples/mozilla_story.mp4
	$(call encode_video, $<, $@)

samples/ganges.h264: samples/ganges.mkv
	$(call encode_video, $<, $@)

samples/credits.h264: samples/credits.mkv
	$(call encode_video, $<, $@)

samples/benq.h264: samples/benq.mp4
	$(call encode_video, $<, $@)

samples/uhp.h264: samples/uhp.mp4
	$(call encode_video, $<, $@)

samples/gifsfps.h264: samples/gifsfps.mp4
	$(call encode_video, $<, $@)

samples/gradient.h264: samples/gradient.webm
	$(call encode_video, $<, $@)

samples/cam_10fps.h264: samples/cam_10fps.gif
	$(call encode_gif, $<, $@)

samples/cam_60fps.h264: samples/cam_60fps.gif
	$(call encode_gif, $<, $@)

samples/cam_intro.h264: samples/cam_intro.gif
	$(call encode_gif, $<, $@)

samples/cam_mb.h264: samples/cam_mb.gif
	$(call encode_gif, $<, $@)

gifsamples: \
	samples/cam_10fps.h264 \
	samples/cam_60fps.h264 \
	samples/cam_intro.h264 \
	samples/cam_mb.h264 \
	@echo "created gifsamples"

samples: gifsamples \
	samples/sonic.h264 \
	samples/illusion.h264 \
	samples/gradient.h264 \
	samples/primefactors.h264 \
	samples/simonebiles.h264 \
	samples/dots.h264 \
	samples/spinning.h264 \
	samples/empenada.h264 \
	samples/flowmap.h264 \
	samples/jellyfish.h264 \
	samples/shoteffect.h264 \
	samples/thunderstorm.h264 \
	samples/thunderstorm2.h264 \
	samples/ganges.h264 \
	samples/credits.h264 \
	samples/benq.h264 \
	samples/uhp.h264 \
	samples/tree.h264 \
	samples/mozilla_story.h264
	@echo "created all samples"
