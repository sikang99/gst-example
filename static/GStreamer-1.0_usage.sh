#!/bin/bash

# play YUV444 FULL HD file 
gst-launch-1.0 -v filesrc location=size_1920x1080.yuv ! \
    videoparse width=1920 height=1080 framerate=25/1 format=GST_VIDEO_FORMAT_Y444 ! \
    videoconvert ! \
    autovideosink

# play YUV422 FULL HD file 
gst-launch-1.0 -v filesrc location=size_1920x1080.yuv ! \
    videoparse width=1920 height=1080 framerate=25/1 format=GST_VIDEO_FORMAT_Y42B ! \
    videoconvert ! \
    autovideosink

# play YUV422 FULL HD file 
gst-launch-1.0 -v filesrc location=size_1920x1080.yuv ! \
    videoparse width=1920 height=1080 framerate=25/1 format=GST_VIDEO_FORMAT_Y42B ! \
    videoconvert ! \
    autovideosink

# make PNG from YUV420
gst-launch-1.0 -v filesrc location=size_1920x1080.yuv ! \
    videoparse width=1920 height=1080 framerate=25/1 format=GST_VIDEO_FORMAT_Y42B ! \
    videoconvert ! \
    pngenc ! multifilesink location=img%03d.png

# play MP4 FULL HD file
gst-launch-1.0 filesrc location=test.mp4 ! \
    decodebin name=dec ! \
    queue ! \
    videoconvert ! \
    autovideosink dec. ! \
    queue ! \
    audioconvert ! \
    audioresample ! \
    autoaudiosink

# play MP3
gst-launch-1.0 filesrc location=test.mp3 ! decodebin ! playsink

# play OGG
gst-launch-1.0 filesrc location=test.ogg ! decodebin ! playsink

# play MP3 over UDP + RTP
# sender: 
gst-launch-1.0 -v filesrc location=test.mp3 ! \
    decodebin ! \
    audioconvert ! \
    rtpL16pay ! \
    udpsink port=6969 host=192.168.1.42
# receiver:
gst-launch-1.0 -v udpsrc port=6969 \
    caps="application/x-rtp, media=(string)audio, format=(string)S32LE, \
    layout=(string)interleaved, clock-rate=(int)44100, channels=(int)2, payload=(int)0" ! \
    rtpL16depay ! playsink

#play webcam video over UDP with h264 coding
#sender
gst-launch-1.0 v4l2src ! \
    'video/x-raw, width=640, height=480, framerate=30/1' ! \
    videoconvert ! \
    x264enc pass=qual quantizer=20 tune=zerolatency ! \
    rtph264pay ! \
    udpsink host=192.168.1.140 port=1234
#receiver
gst-launch-1.0 udpsrc port=1234 ! \
    "application/x-rtp, payload=127" ! \
    rtph264depay ! \
    avdec_h264 ! \
    videoconvert  ! \
    xvimagesink sync=false

#play RAW webcam video over UDP (+RTP) without any coding
#sender
gst-launch-1.0 -v v4l2src ! 'video/x-raw, width=(int)640, height=(int)480, framerate=10/1' ! \
    videoconvert ! queue ! \
    rtpvrawpay ! queue ! \
    udpsink host=127.0.0.1 port=1234
#receiver
gst-launch-1.0 udpsrc port=1234 ! \
    "application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)RAW, \
    sampling=(string)YCbCr-4:2:2, depth=(string)8, width=(string)640, height=(string)480, \
    ssrc=(uint)1825678493, payload=(int)96, clock-base=(uint)4068866987, seqnum-base=(uint)24582" ! \
    rtpvrawdepay ! queue  ! videoconvert  ! autovideosink   

#save RAW video from webcam to file
gst-launch-1.0 -v v4l2src ! 'video/x-raw, width=(int)640, height=(int)480, framerate=10/1' ! videoconvert ! filesink location=out.yuv  

#play RAW video from file
gst-launch-1.0 filesrc location=out.yuv ! videoparse width=640 height=480 format=GST_VIDEO_FORMAT_YUY2 ! videoconvert ! autovideosink  

