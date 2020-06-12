function plotOutput(obj,outputs,varargin)

%% Plot the stuff that is typical to a navigation filter
obj.plotOutputPpp(outputs,varargin{:})

%% Plot wheel ticks
epochsOut = cat(1,outputs.epoch);

tinds0 = 1:length(epochsOut);

residsData = cat(1,outputs.resids);
residsFull = cat(1,residsData.resids);
measIdFull = cat(1,residsData.measId);
epochsFull = cat(1,residsData.epochs);

residsType = cat(1,measIdFull.TypeID);

indsWheels = find(residsType == navsu.internal.MeasEnum.Wheels);

if ~isempty(indsWheels)
    residsWheels = residsFull(indsWheels);
    measIdWheels = measIdFull(indsWheels);
    epochsWheels = epochsFull(indsWheels);
    
    subtypeWheels = cat(1,measIdWheels.subtype);
    subtypeUn = unique(subtypeWheels);
    
    figure; clf; hold on
    for idx = 1:length(subtypeUn)
        indsi = find(subtypeWheels == subtypeUn(idx));
        s= plot((epochsWheels(indsi)-min(epochsOut))/60,residsWheels(indsi));
        
        % find time indices
        [~,ixb] = ismember(epochsWheels(indsi),epochsOut);
        row = dataTipTextRow('time index',tinds0(ixb));
        s.DataTipTemplate.DataTipRows(3) = row;
        
        % add subtype text
        row = dataTipTextRow('subtype',repelem({char(subtypeUn(idx))},length(indsi),1));
        s.DataTipTemplate.DataTipRows(4) = row;
        
    end
    title('Wheel tick residuals')
    xlabel('Time [min]')
    grid on;
    
    
    %% Plot wheel scale factors
    wheelScales = cat(2,outputs.wheelScale);
    figure; clf; hold on;
    s = plot((epochsOut-min(epochsOut))/60,wheelScales(3,:));
    s.DataTipTemplate.DataTipRows(3) = dataTipTextRow('time index',tinds0);;
    
    s = plot((epochsOut-min(epochsOut))/60,wheelScales(4,:));
    s.DataTipTemplate.DataTipRows(3) = dataTipTextRow('time index',tinds0);;
    
    xlabel('Time [min]')
    title('Wheel tick scale factor')
    grid on;
end
%% plot local 'tude
posEst = cat(2,outputs.pos);
Rbe = cat(3,outputs.R_b_e);

attEnu = nan(size(posEst));

for idx = 1:size(posEst,2)
    % Get latitude and longitude
    llhi = navsu.geo.xyz2llh(posEst(:,idx)');
    
    % Get ECEF to ENU rotation matrix
    [~,RxyzEnu] = navsu.geo.xyz2enu([0 0 0],llhi(1)*pi/180,llhi(2)*pi/180);
    
    Rbenu = RxyzEnu*Rbe(:,:,idx);
    attEnu(:,idx) = navsu.geo.dcm2euler123(Rbenu);
end

figure; clf; hold on;
s = plot((epochsOut-min(epochsOut))/60,attEnu*180/pi);
for idx = 1:length(s)
    s(idx).DataTipTemplate.DataTipRows(3) = dataTipTextRow('time index',tinds0);
end
legend('Pitch','Roll','Yaw')
title('Vehicle Attitude in Local ENU Frame')
xlabel('Time [min]')
ylabel('Attitude [deg]')

%% Plot IMU bias states
imuBias = cat(2,outputs.imuBiasStates);
accBias = imuBias(1:3,:);
gyroBias = imuBias(4:6,:);

figure; clf; hold on;
subplot(2,1,1);
title('Accelerometer bias')
s =  plot((epochsOut-min(epochsOut))/60,accBias);
for idx = 1:length(s)
    s(idx).DataTipTemplate.DataTipRows(3) = dataTipTextRow('time index',tinds0);
end
legend('right','back','up','location','best');
xlabel('Time [min]')
ylabel('Accelerometer bias [m/s^2]')
grid on;

subplot(2,1,2);
title('Gyro bias')
s =  plot((epochsOut-min(epochsOut))/60,gyroBias);
for idx = 1:length(s)
    s(idx).DataTipTemplate.DataTipRows(3) = dataTipTextRow('time index',tinds0);
end
legend('right','back','up','location','best');
ylabel('Gyro bias [rad/s]');
xlabel('Time [min]')
grid on;


end



















