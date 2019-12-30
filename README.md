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


Plugins for which support is explicitly added<br />
Test Group | Plugin Name | Custom Options<br />
---------- | ----------- | --------------<br />
cpu<br />
|contextswitch<br />
		cpu<br />
		cpufreq<br />
		intel_pmu<br />
	intel_rdt <br />
		ipc<br />
		irq<br />
		numa<br />
		turbostat<br />
dpdk<br />
		dpdk_stats<br />
ovs<br />
    ovs_events<br />
    ovs_stats<br />
standard
		cpu
		df
		disk
		ethstat         all_physical_nics=true - if set, will gather stats for all real nics
                ipmi
                irq
                load
                memory
                netlink         all_physical_nics=true - if set, will gather stats for all real nics
                pcie_errors
                processes
                swap
                turbostat

Exporters Supported:
Name            	Custom Options
 amqp                   publish='name' [default=collectd], all others standard for amqp plugin
 csv                    See collectd documentation
 http                   node='name', all others standard for http_write
 kafka                  See collectd documentation
 network                target=ip:port
 prometheus             See collectd documentation

