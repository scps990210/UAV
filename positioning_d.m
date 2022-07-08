viewer = siteviewer("Buildings","nycu.osm","Basemap","topographic");

fileID = fopen('nycu2.txt','w');

lat = [24.788088 , 24.788077, 24.788717, 24.788602];
long = [120.999772, 121.000301, 121.000282, 121.000639];
alt = [85,85,85];
w = [0,0,0];
frequency = 28000;
weight = 0;
lat_uav = 0;
long_uav = 0;

demandrate = [6,3,2];
for i = 1 :1: 3
    w(i) = demandrate(i);
end
for i = 1 :1: 3
    weight = weight + w(i);
end
for i = 1 :1: 3
    lat_uav = lat_uav + (w(i)/weight)*lat(i);
    long_uav = long_uav + (w(i)/weight)*long(i);
end 

tx = txsite("Name","Small cell transmitter", ...
    "Latitude",lat_uav, ...
    "Longitude",long_uav, ...
    "AntennaHeight",40, ...
    "TransmitterPower",5, ...
    "TransmitterFrequency",28e9);
%show(tx)
rtpm = propagationModel("raytracing", ...
    "MaxNumReflections",0, ...
    "BuildingsMaterial","perfect-reflector", ...
    "TerrainMaterial","perfect-reflector");
coverage(tx,rtpm, ...
    "SignalStrengths",-120:-5, ...
    "MaxRange",250, ...
    "Resolution",3, ...
    "Transparency",0.6)

for i = 1 :1: 3
    %get surface high
    h = 0;
    alt = 85;
    rxs = rxsite("Name","Small cell receiver", ...
        "Latitude",lat(i), ...
        "Longitude",long(i), ...
        "AntennaHeight",h);
    surface = elevation(rxs)
    h = alt - elevation(rxs)
    %非建築區的信號強度
    if h>=0
        %(訊號接收站)
        rxs = rxsite("Name","Small cell receiver", ...
            "Latitude",lat(i), ...
            "Longitude",long(i), ...
            "AntennaHeight",h);
        los(tx,rxs)
        rtpm.MaxNumReflections = 1;
        h2 = elevation(rxs);

        rtpm.BuildingsMaterial = "concrete";
        rtpm.TerrainMaterial = "concrete";
        %raytrace(tx,rxs,rtpm)
        ss = sigstrength(rxs,tx,rtpm);
        %建築區標是為1
    else
        ss = 1;
    end
    A=lat(i);
    B=long(i);
    C=alt;
    D=ss;
    aa=[A;B;C;D]
    fprintf(fileID,'%12.8f\t',A);
    fprintf(fileID,'%12.8f\t',B);
    fprintf(fileID,'%12.8f\t',C);
    fprintf(fileID,'%12.8f\n',D);
end
fclose(fileID);