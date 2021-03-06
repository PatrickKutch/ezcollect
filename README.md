# ezcollectd
---------------
## Synopys
This is a docker buildfile to create a docker image that will allow you to specify and configure desired collectd plugins via command line parameters when you launch the docker images.
It is based upon the opnfv barometer docker images for collectd at https://github.com/opnfv/barometer.  The difference being that the launching of collectd is done via a python script for which you can specify pretty much everything you want collected, how you want it collected and where you want the data exported to.

## Background
Collectd is a quite useful and versatile mechanism for collecting a tremendous amount of telemetry from a system.  It is however sometimes a challenge to build and install.  To make that easier the barometer project includes docker images of collectd.
The challenge with the docker images that are part of barometer is that the configuration file must be specified either by setting up a volume when launching the docker image and pointing to a configuration file outside of the docker image or using ansible to compile the docker image on every system and run it.

I want to be able to easily deploy collectd and yet have it easy to cusomize on a system by system basis.  So I created this project.  

In general, you run it like any other docker image, but you also specify what the data it is you want to collect, and where to send it to.  A number of build-in collectors and exporters are supported by this launch script.  You may specify one or more pre-determined set of collectors with the -t option, or you can cusomize it and specify each individually.
Some collectors have individual configurations that you may also specify.

One thing I added that is not part of collectd itself, is for the network collectors (ethstat,netlink) you may specify to get data from the physical nics, and ignore things like bridges, and other virtual net devices.

If you specify the option --list_plugins you will get a list of the 'test groups' and exporters:


Plugins for which support is explicitly added

Test Group | Plugin Name | Custom Options
---------- | ----------- | --------------
Content from cell 1 | Content from cell 2
cpu
 -|contextswitch
-|cpu
-|cpufreq
-|intel_pmu
-|intel_rdt 
-|ipc
-|irq
-|numa
-|turbostat
dpdk
-|dpdk_stats
ovs
-|ovs_events
-|ovs_stats
standard
-|cpu
-|df
-|disk
-|ethstat|all_physical_nics=true - if set, will gather stats for all real nics
-|ipmi
-|irq
-|load
-|memory
-|netlink | all_physical_nics=true - if set, will gather stats for all real nics
-|pcie_errors
-|processes
-|swap
-|turbostat

Exporters Supported:

Exporter Name | Custom Options
------------- | --------------
amqp | publish='name' [default=collectd], all others standard for amqp plugin
csv | See collectd documentation ** note - need to mount a volume
http | node='name', all others standard for http_write
kafka | See collectd documentation
network | target=ip:port
prometheus | See collectd documentation


## Example Configurations
Example:

docker run -tid --net=host --privileged -v /root/csv:/opt/csvdir patrickkutch/ezcollectd -x network,target=10.254.176.132:50001 -x csv,datadir=/opt/csvdir -t standard -v 4 --hostname bruno --interval=2

This example runs the ezcollectd docker images as a daemon in privileged mode (needed for some plugins) collecting the 'standard' set of telemetry as described above at an interval of 2 seconds.  The hostname is set to 'bruno' and the data is exported to two places, the first is a netowork connection (maybe InfluxDB) at the specified IP:Port and the second is to a csv folder. Note the mouting of the volume at the beginning of the docker run line, the local /root/csv directory is mapped into the /opt/csvdir directory of the docker image.  This could also be mapped to a network share.

Example:

docker run -tid --net=host --privileged -p 9092:5000  patrickkutch/ezcollectd -x kafka,listenAt=localhost:5000 -t ovs -t custom --interval=15 -- intel_pmu,cores='[]' foo bar

This example runs the ezcollectd docker images as a daemon in privileged mode (needed for some plugins) collecting the 'ovs' set of telemetry as described above at an interval of 15 seconds and it will also configure the intel_pmu collector to collect from all cores.  Additionally it will configure collectors foo and bar with default plugin configuration (these do not really exist, but are placed here as an example of how to specify a collector that does not explicitly have support build-into the launch script).

This example is setup to support a Kafka listener at localhost:5000 within the container (note the port mapping of -p 9092:5000, which means that kafka will point to the server soemhow at port 9092 but docker will remap that to port 5000 within the container.