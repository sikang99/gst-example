#
# Makefile for gstreamer 1.0
#
#-----------------------------------------------------------------------------------------
usage:
	@echo "make [install|video|gst|test|web]"

install i:
	sudo apt install libv4l-dev v4l-utils v4l2ucp
	sudo apt install libgstreamer1.0-dev ges1.0-tools

video v:
	v4l2-ctl --list-devices --list-ctrls --list-formats

#-----------------------------------------------------------------------------------------
SAMPLE=media/small.ogv

GST_LAUNCH=gst-launch-1.0
GST_PLAY=gst-play-1.0
GST_INSPECT=gst-inspect-1.0
GST_DISCOVER=gst-discoverer-1.0

gst x:
	@echo "make (gst) [list|view]"

gst-list xl:
	 $(GST_INSPECT) --print-all
	 #$(GST_INSPECT) --print-plugin-auto-install-info
	 #$(GST_INSPECT) mpegtsmux
gst-view xv:
	$(GST_LAUNCH) playbin uri=v4l2:///dev/video0
#-----------------------------------------------------------------------------------------
test t:
	@echo "make (test) [discover|play|extract|stream|base]"

test-discover td:
	$(GST_DISCOVER) $(SAMPLE)

test-play tp:
	$(GST_PLAY) $(SAMPLE)

test-extract te:
	-rm test.ac3
	gst-launch-1.0 -v filesrc location=$(SAMPLE) ! oggdemux ! vorbisdec ! avenc_ac3 bitrate=64000 ! filesink location=test.ac3
	$(GST_PLAY) test.ac3

test-format tf:
	-rm test.mp4
	gst-launch-1.0 filesrc location=$(SAMPLE) ! oggdemux name=demux \
		qtmux name=mux ! filesink location=test.mp4 \
		demux. ! theoradec ! x264enc ! mux. \
		demux. ! queue max-size-time=5000000000 max-size-buffers=10000 ! vorbisdec ! avenc_aac compliance=-2 ! mux.
	gst-play-1.0 test.mp4

test-stream ts:
	vlc udp://@0.0.0.0:5000 &
	gst-launch-1.0 filesrc location=$(SAMPLE) ! oggdemux name=demux \
		mpegtsmux name=mux alignment=7 ! udpsink host=127.0.0.1 port=5000 buffer-size=10000000 \
 		demux. ! theoradec ! x264enc ! mux. \
 		demux. ! queue max-size-time=5000000000 max-size-buffers=10000 ! vorbisdec ! avenc_aac compliance=-2 ! mux.

test-camera tc:
	#gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw,format=YUYV,width=320,height=240' 
	gst-launch-1.0 videotestsrc ! 'video/x-raw,format=YV12,width=320,height=240' \
		! x264enc pass=qual quantizer=20 tune=zerolatency ! rtph264pay ! udpsink host=127.0.0.1 port=5000 min=max=188

test-recv tr:
	gst-launch-1.0 udpsrc port=5000 ! "application/x-rtp,payload=127" ! rtph264depay ! ffdec_h264 ! xvimagesink sync=false

test-test tt:
	gst-launch-1.0 -v udpsrc port=1234 ! fakesink dump=1
	gst-launch-1.0 -v audiotestsrc ! udpsink host=127.0.0.1 port=1234

test-base tb:
	@echo "make (test-base) [1|2|3]"
tb1:
	$(GST_LAUNCH) -v videotestsrc ! ximagesink
tb2:
	$(GST_LAUNCH) -v videotestsrc ! x264enc !  mpegtsmux ! fakesink silent=false sync=true -v
tb3:
	$(GST_INSPECT) mpegtsmux

#-----------------------------------------------------------------------------------------
web w:
	@echo "make (web) [sample]"

web-sample ws:
	xdg-open http://4youngpadawans.com/gstreamer-real-life-examples/

clean:
	rm -f test.*
#-----------------------------------------------------------------------------------------
git g:
	@echo "make (git) [update|login|tag|status]"

git-update gu:
	git add .gitignore *.md Makefile static/ media/
	#git commit -m "initial commit"
	#git remote remove go.mod sse.go
	#git commit -m "add examples"
	git commit -m "update contents"
	git push

git-login gl:
	git config --global user.email "sikang99@gmail.com"
	git config --global user.name "Stoney Kang"
	git config --global push.default matching
	#git config --global push.default simple
	git config credential.helper store

git-tag gt:
	git tag v0.0.3
	git push --tags

git-status gs:
	git status
	git log --oneline -5
#-----------------------------------------------------------------------------------------

