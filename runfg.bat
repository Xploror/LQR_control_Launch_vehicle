C:
cd ..
cd ..

cd C:\Program Files\FlightGear 2020.3.4

SET FG_ROOT=C:\Program Files\FlightGear 2020.3.4\data

SET FG_SCENERY=C:\Program Files\FlightGear 2020.3.4\data\Scenery;D:\FlightGear\Custom Scenery;D:\FlightGear\TerraSync

.\\bin\fgfs --aircraft=Vostok-1 --fdm=null --enable-auto-coordination --native-fdm=socket,in,30,localhost,5502,udp --fog-disable --enable-clouds3d --start-date-lat=2021:02:04:09:00:00 --enable-sound --visibility=15000 --in-air --prop:/engines/engine0/running=true --disable-freeze --airport=KSEA --runway=01 --altitude=1000 --heading=0 --offset-distance=0 --offset-azimuth=0 --enable-rembrandt