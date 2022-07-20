viewer = siteviewer("Buildings","nycu.osm","Basemap","topographic");

fileID = fopen('nycu6.txt','w');

lat_uav = 24.787142;
long_uav = 120.996546;
alt = 105;
flag = 1;
count = 0;
base = 0;
threshold = 5 ;

fq = 4.5e9;
y = design(yagiUda,fq);
y.Tilt = 180;
y.TiltAxis = 'y';

tx = txsite("Name","Small cell transmitter", ...
    "Latitude",lat_uav, ...
    "Longitude",long_uav, ...
    "AntennaHeight",40, ...
    "TransmitterPower",0.25, ...
    "TransmitterFrequency",fq);
%show(tx)
rtpm = propagationModel("raytracing", ...
    "MaxNumReflections",0, ...
    "BuildingsMaterial","perfect-reflector", ...
    "TerrainMaterial","perfect-reflector");
%coverage(tx,rtpm, ...
%    "SignalStrengths",-120:-5, ...
%    "MaxRange",250, ...
%    "Resolution",3, ...
%    "Transparency",0.6)

for lat=24.785342: 0.000009:24.788942
    for lon=120.994746:0.000009:120.998346
        dis = power(lat-lat_uav,2)+power(lon-long_uav,2);
        if  dis > 0.00000324
            flag = 0;
        else 
            flag = 1;
        end
            %get surface high
            h = 0;
            rxs = rxsite("Name","Small cell receiver", ...
                 "Latitude",lat, ...
                 "Longitude",lon, ...
                 "AntennaHeight",h);
            surface = elevation(rxs);
            h = alt - elevation(rxs);
            %非建築區的信號強度
            if h>=0
                %(訊號接收站)
                rxs = rxsite("Name","Small cell receiver", ...
                    "Latitude",lat, ...
                    "Longitude",lon, ...
                    "AntennaHeight",h);
                los(tx,rxs)
                rtpm.MaxNumReflections = 1;
                h2 = elevation(rxs);
                rtpm.BuildingsMaterial = "concrete";
                rtpm.TerrainMaterial = "concrete";
                %raytrace(tx,rxs,rtpm)
                ss = sigstrength(rxs,tx,rtpm);
                e = power(10,ss/10);
                r = sinr(rxs,tx);
            %建築區標是為1
            else
                ss = 1;
            end
            if (flag == 1) && (r > threshold)
                count = count + 1 ;
                base = base+1;
            elseif(flag == 1) && (r < threshold)
                base = base+1;
            end
            A=lat;
            B=lon;
            C=alt;
            D=ss;
            E=power(10,ss/10);
            fprintf(fileID,'%12.8f\t',A);
            fprintf(fileID,'%12.8f\t',B);
            fprintf(fileID,'%12.8f\t',C);
            fprintf(fileID,'%12.8f\t',D);
            fprintf(fileID,'sinr = %12.8f\t',r);
            fprintf(fileID,'count = %12.8f\t',count);
            fprintf(fileID,'base = %12.8f\t',base);
            fprintf(fileID,'percent = %12.8f\t',count/base);
            fprintf(fileID,'sigstrength = %12.8f\n',E);
    end
end
fclose(fileID);
