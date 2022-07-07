viewer = siteviewer("Buildings","nycu.osm","Basemap","topographic");

fileID = fopen('nycu1.txt','w');

lat = [24.788088 , 24.788077, 24.788717, 24.788602];
long = [120.999772, 121.000301, 121.000282, 121.000639];
alt = [85,85,85];

for latitude = 24.788371 : 0.000009 : 24.788407
    for longtitude = 121.000248 : 0.000009 : 121.000284
            tx = txsite("Name","Small cell transmitter", ...
                "Latitude",latitude, ...
                "Longitude",longtitude, ...
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
    end
end
fclose(fileID);
