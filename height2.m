viewer = siteviewer("Buildings","nycu.osm","Basemap","topographic");

fileID = fopen('nycu14.txt','w');
for k = 100 : 100 : 1000
    fprintf(fileID,'Antenna height = %12.8f\n',k);
    lat_uav = 24.787142;
long_uav = 120.996546;
alt = 115;
flag = 1;
count1 = 0;
count2 = 0;
count3 = 0;
count4 = 0;
base1 = 0;
base2 = 0;
base3 = 0;
base4 = 0;
threshold1 = 5;
threshold2 = 10;
threshold3 = 15;
threshold4 = 20;

fq = 4.5e9;
y = design(yagiUda,fq);
y.Tilt = 180;
y.TiltAxis = 'y';

tx = txsite("Name","Small cell transmitter", ...
    "Latitude",lat_uav, ...
    "Longitude",long_uav, ...
    "AntennaHeight",k, ...
    "TransmitterPower",0.1, ...
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

for lat=24.783542:0.00009:24.790742
    for lon=120.992946:0.00009:121.000146
        dis = power(lat-lat_uav,2)+power(lon-long_uav,2);
        if  dis > 0.00001296
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
            if (flag == 1) && (r > threshold1) && (ss ~= 1)
                count1 = count1 + 1 ;
                base1 = base1+1;
            elseif(flag == 1) && (r < threshold1) && (ss ~= 1)
                base1 = base1+1;
            end
            if (flag == 1) && (r > threshold2) && (ss ~= 1)
                count2 = count2 + 1 ;
                base2 = base2+1;
            elseif(flag == 1) && (r < threshold2) && (ss ~= 1)
                base2 = base2+1;
            end
            if (flag == 1) && (r > threshold3) && (ss ~= 1)
                count3 = count3 + 1 ;
                base3 = base3+1;
            elseif(flag == 1) && (r < threshold3) && (ss ~= 1)
                base3 = base3+1;
            end
            if (flag == 1) && (r > threshold4) && (ss ~= 1)
                count4 = count4 + 1 ;
                base4 = base4+1;
            elseif(flag == 1) && (r < threshold4) && (ss ~= 1)
                base4 = base4+1;
            end
            A=lat;
            B=lon;
            C=alt;
            D=ss;
            E=power(10,ss/10);
            fprintf(fileID,'sinr = %12.8f\t',r);
            fprintf(fileID,'percent1 = %12.8f\t',count1/base1);
            fprintf(fileID,'percent2 = %12.8f\t',count2/base2);
            fprintf(fileID,'percent3 = %12.8f\t',count3/base3);
            fprintf(fileID,'percent4 = %12.8f\t',count4/base4);
            fprintf(fileID,'%12.8f\t',A);
            fprintf(fileID,'%12.8f\t',B);
            fprintf(fileID,'%12.8f\t',C);
            fprintf(fileID,'%12.8f\t',D);
            fprintf(fileID,'sigstrength = %12.8f\n',E);
    end
end
end

fclose(fileID);