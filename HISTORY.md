


## History


* 2019/05/06:
    - dowwnload and build the [gstreamer](https://github.com/GStreamer/gstreamer) 1.17.1
    ```
    $ ccget https://github.com/GStreamer/gstreamer
    $ ./autogen.sh
    $ ./configure
    $ make
    ```
    - Configuration
    ```
	Version                    : 1.17.0.1
	Source code location       : .
	Prefix                     : /usr/local
	Compiler                   : gcc
	Package name               : GStreamer git
	Package origin             : Unknown package origin

	API Documentation          : no

	Debug logging              : yes
	Tracing subsystem hooks    : yes
	Command-line parser        : yes
	Option parsing in gst_init : yes
	Plugin registry            : yes
	Plugin support	           : yes
	Static plugins             : 
	Unit testing support       : yes
	PTP clock support          : yes
	libunwind support          : yes
	libdw support              : yes

	Debug                      : yes
	Profiling                  : no

	Building benchmarks        : yes
	Building examples          : yes
	Building test apps         : yes
	Building tests that fail   : no
	Building tools             : yes
    ```

* 2018/05/04:
    - build and test some tutorial examples in GStreamer [Documentation](https://gstreamer.freedesktop.org/documentation/)
