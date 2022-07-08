viewer = siteviewer("Buildings","nycu.osm","Basemap","topographic");

fileID = fopen('nycu2.txt','w');

lat = [24.788088 , 24.788077, 24.788717, 24.788602];
long = [120.999772, 121.000301, 121.000282, 121.000639];
alt = [85,85,85];
frequency = 28000;
distance = power(10, ((27.55 - (20 * log10(frequency)) + signalLevel)/20));
weight = 0;
lat_uav = 0;
long_uav = 0;

demandrate = [6,3,2];
for i = 1 :1: 3
    w(i) = 1/(power(10, ((27.55 - (20 * log10(frequency)) + abs(demandrate(i)))/20)));
end
for i = 1 :1: 3
    weight = weight + w(i);
end
for i = 1 :1: 3
    lat_uav = lat_uav + (w(i)/weight)*lat(i);
    long_uav = long_uav + (w(i)/weight)*long(i);
end 

for i = 1 :1: 4
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
    end
end