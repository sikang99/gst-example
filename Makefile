#
# Makefile for gstreamer 1.0
#
PORT=5000
SAMPLE=media/small.ogv

GST_PLAY=gst-play-1.0
GST_LAUNCH=gst-launch-1.0
GST_INSPECT=gst-inspect-1.0
GST_DISCOVER=gst-discoverer-1.0
GST_DEVICE=gst-device-monitor-1.0
#-----------------------------------------------------------------------------------------
usage:
	@echo "make [pkg|video|gst|test|web]"
#-----------------------------------------------------------------------------------------
edit-history eh:
	vi HISTORY.md
#-----------------------------------------------------------------------------------------
package pkg p:
	@echo "make (pkg) [list|config|install|search]"

pkg-list pl:
	ls /usr/lib/x86_64-linux-gnu/pkgconfig/gstreamer*
	ls /usr/lib/x86_64-linux-gnu/gstreamer*

pkg-config pc:
	pkg-config --list-all | grep gstreamer	

pkg-install pi:
	sudo apt install libv4l-dev v4l-utils v4l2ucp
	sudo apt install -y \
		gstreamer1.0-tools gstreamer1.0-nice \
		gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
		gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
		gstreamer1.0-libav libgstrtspserver-1.0-dev \
		libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev \
		libglib2.0-dev libsoup2.4-dev libjson-glib-dev
	sudo apt install ges1.0-tools

pkg-search ps:
	apt search gst | grep gstreamer1.0 

#-----------------------------------------------------------------------------------------
video-device vd:
	v4l2-ctl --list-devices --list-ctrls --list-formats

video-play vp:
	vlc udp://@0.0.0.0:$(PORT) &
#-----------------------------------------------------------------------------------------
gst s:
	@echo "make (gst:s) [device|view]"

gst-device sd:
	 $(GST_INSPECT) --print-all
	 #$(GST_INSPECT) --print-plugin-auto-install-info
	 #$(GST_INSPECT) mpegtsmux

gst-view sv:
	@echo "make (gst-view:sv) [1|2]"
sv1:
	$(GST_LAUNCH) playbin3 uri=v4l2:///dev/video0
sv2:
	$(GST_LAUNCH) v4l2src device=/dev/video0 ! videoconvert ! autovideosink

#-----------------------------------------------------------------------------------------
test t:
	@echo "make (test) [discover|play|extract|stream|base]"

test-discover td:
	$(GST_DISCOVER) $(SAMPLE)

test-play tp:
	$(GST_PLAY) $(SAMPLE)

test-extract te:
	-rm test.ac3
	$(GST_LAUNCH) -v filesrc location=$(SAMPLE) ! oggdemux ! vorbisdec ! avenc_ac3 bitrate=64000 ! filesink location=test.ac3
	$(GST_PLAY) test.ac3

test-format tf:
	-rm test.mp4
	$(GST_LAUNCH) filesrc location=$(SAMPLE) ! oggdemux name=demux \
		qtmux name=mux ! filesink location=test.mp4 \
		demux. ! theoradec ! x264enc ! mux. \
		demux. ! queue max-size-time=5000000000 max-size-buffers=10000 ! vorbisdec ! avenc_aac compliance=-2 ! mux.
	$(GST_PLAY) test.mp4

test-stream ts:
	$(GST_LAUNCH) filesrc location=$(SAMPLE) ! oggdemux name=demux \
		mpegtsmux name=mux alignment=7 ! udpsink host=127.0.0.1 port=$(PORT) buffer-size=10000000 \
 		demux. ! theoradec ! x264enc ! mux. \
 		demux. ! queue max-size-time=5000000000 max-size-buffers=10000 ! vorbisdec ! avenc_aac compliance=-2 ! mux.

test-camera tc:
	@echo "make (test-camera) [1|2]"

tc1:
	#gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw,format=YUYV,width=320,height=240' \ 
		#! x264enc pass=qual quantizer=20 tune=zerolatency ! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT)
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 \
		! x264enc ! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT)

tc2:
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 \
		! textoverlay text="Room A" valignment=top halignment=left font-desc="Sans, 22" \
		! videoconvert ! x264enc ! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT)

test-recv tr:
	$(GST_LAUNCH) udpsrc port=$(PORT) ! "application/x-rtp,payload=127" ! rtph264depay ! ffdec_h264 ! xvimagesink sync=false

test-test tt:
	$(GST_LAUNCH) -v udpsrc port=1234 ! fakesink dump=1
	$(GST_LAUNCH) -v audiotestsrc ! udpsink host=127.0.0.1 port=1234

test-base tb:
	@echo "make (test-base) [1|2|3]"
tb1:
	$(GST_LAUNCH) -v videotestsrc ! ximagesink
tb2:
	$(GST_LAUNCH) -v videotestsrc ! x264enc !  mpegtsmux ! fakesink silent=false sync=true -v
tb3:
	$(GST_INSPECT) mpegtsmux

#-----------------------------------------------------------------------------------------
send-recv sr:
	@echo "make (send-recv) [1|2|3]"

sr1:	# JPEG
	$(GST_LAUNCH) udpsrc port=$(PORT) ! application/x-rtp,encoding-name=JPEG,payload=26 ! rtpjpegdepay ! jpegdec ! autovideosink &
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 ! videoconvert ! jpegenc \
		! rtpjpegpay ! udpsink host=127.0.0.1 port=$(PORT) 

sr2:	# VP8
	$(GST_LAUNCH) udpsrc port=$(PORT) caps="application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)VP8-DRAFT-IETF-01, payload=(int)96, ssrc=(uint)2990747501, clock-base=(uint)275641083, seqnum-base=(uint)34810" ! rtpvp8depay ! vp8dec ! autovideosink &
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 ! videoconvert  ! vp8enc ! rtpvp8pay ! udpsink host=127.0.0.1 port=$(PORT)

sr3:	# MPEG-4
	$(GST_LAUNCH) udpsrc port=$(PORT) caps = "application/x-rtp\,\ media\=\(string\)video\,\ clock-rate\=\(int\)90000\,\ encoding-name\=\(string\)MP4V-ES\,\ profile-level-id\=\(string\)1\,\ config\=\(string\)000001b001000001b58913000001000000012000c48d8800cd3204709443000001b24c61766335362e312e30\,\ payload\=\(int\)96\,\ ssrc\=\(uint\)2873740600\,\ timestamp-offset\=\(uint\)391825150\,\ seqnum-offset\=\(uint\)2980" ! rtpmp4vdepay ! avdec_mpeg4 ! autovideosink &
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 ! videoconvert ! avenc_mpeg4 ! rtpmp4vpay config-interval=3 ! udpsink host=127.0.0.1 port=$(PORT)

sr4:	# H.264
	$(GST_LAUNCH) udpsrc port=$(PORT) caps = "application/x-rtp\,\ media\=\(string\)video\,\ clock-rate\=\(int\)90000\,\ encoding-name\=\(string\)H264\,\ payload\=\(int\)96" ! rtph264depay ! avdec_h264 ! autovideosink &
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 ! videoconvert ! x264enc ! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT)

sr5:
	$(GST_LAUNCH) -v v4l2src !  video/x-raw,width=640,height=480 \
		! textoverlay text="Room A" valignment=top halignment=left font-desc="Sans, 22" \
		! videoconvert ! x264enc ! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT) &
	$(GST_LAUNCH) -v v4l2src ! video/x-raw,width=640,height=480 ! videoconvert ! x264enc \
		! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT)

sr6:
	$(GST_LAUNCH) -vc udpsrc port=$(PORT) close-socket=false multicast-iface=false auto-multicast=true \
		! application/x-rtp, payload=96 ! rtpjitterbuffer ! rtph264depay ! avdec_h264 \
		! fpsdisplaysink  sync=false async=false --verbose &
	$(GST_LAUNCH) -v v4l2src device=/dev/video0 \
		! video/x-raw,width=1280,height=720,type=video ! videoscale ! videoconvert ! x264enc tune=zerolatency \
		! rtph264pay ! udpsink host=127.0.0.1 port=$(PORT) --verbose 


sr7:	# WebRTC
	gst-launch-1.0 webrtcbin bundle-policy=max-bundle name=sendrecv  stun-server=stun://stun.l.google.com:19302 ! rtpopusdepay ! opusdec ! audioconvert ! autoaudiosink async=false &
	gst-launch-1.0 webrtcbin bundle-policy=max-bundle name=sendrecv  stun-server=stun://stun.l.google.com:19302 audiotestsrc is-live=true wave=red-noise ! audioconvert ! audioresample ! queue ! opusenc ! rtpopuspay ! application/x-rtp,media=audio,encoding-name=OPUS,payload=97 ! sendrecv.

rist:
	gst-launch-1.0 ristsrc address=0.0.0.0 port=5004 ! rtpmp2depay ! udpsink
	gst-play-1.0 "rist://0.0.0.0:5004?receiver-buffer=700"

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
	git add .gitignore *.md Makefile static/ media/ tutorial/
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

