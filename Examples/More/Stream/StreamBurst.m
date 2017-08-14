%
% Demonstrates how to use the StreamBurst function for streaming using
% .NET.
%
% support@labjack.com
%

clc  % Clear the MATLAB command window
clear  % Clear the MATLAB variables

% Make the LJM .NET assembly visible in MATLAB
ljmAsm = NET.addAssembly('LabJack.LJM');

% Creating an object to nested class LabJack.LJM.CONSTANTS
t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
LJM_CONSTANTS = System.Activator.CreateInstance(t);

handle = 0;

try
    % Open first found LabJack

    % Any device, Any connection, Any identifier
    [ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);

    % T7 device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.OpenS('T7', 'ANY', 'ANY', handle);

    % T4 device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.OpenS('T4', 'ANY', 'ANY', handle);

    % Any device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, ...
    %     LJM_CONSTANTS.ctANY, 'ANY', handle);

    showDeviceInfo(handle);

    % Stream configuration
    numScans = 20000;  % Number of scans to perform
    numAddresses = 2;
    % Scan list names to stream.
    aScanListNames = NET.createArray('System.String', numAddresses);
    aScanListNames(1) = 'AIN0';
    aScanListNames(2) = 'AIN1';
    aTypes = NET.createArray('System.Int32', numAddresses);  % Dummy
    % Scan list addresses to stream. StreamBurst uses Modbus addresses.
    aScanList = NET.createArray('System.Int32', numAddresses);
    LabJack.LJM.NamesToAddresses(numAddresses, aScanListNames, ...
        aScanList, aTypes);
    scanRate = 10000;  % Scans per second
    % Stream burst reads will be stored in aData. Needs to be at least
    % numAddresses*numScans in size.
    aData = NET.createArray('System.Double', numScans * numAddresses);

    % Configure the analog inputs negative channel, range, settling time
    % and resolution.
    % When streaming, negative channels and ranges can be configured for
    % individual analog inputs, but the stream has only one settling time
    % and resolution.
    numAddressesConfig = 5;
    aNames = NET.createArray('System.String', numAddressesConfig);
    aNames(1) = 'AIN_ALL_NEGATIVE_CH';
    aNames(2) = 'AIN0_RANGE';
    aNames(3) = 'AIN1_RANGE';
    aNames(4) = 'STREAM_SETTLING_US';
    aNames(5) = 'STREAM_RESOLUTION_INDEX';
    aValues = NET.createArray('System.Double', numAddressesConfig);
    aValues(1) = LJM_CONSTANTS.GND;  % Single-ended
    aValues(2) = 10.0;  % +/-10V
    aValues(3) = 10.0;  % +/-10V
    aValues(4) = 0;  % 0 (default)
    aValues(5) = 0;  % 0 (default)
    LabJack.LJM.eWriteNames(handle, numAddressesConfig, aNames, ...
        aValues, -1);

    disp('Scan list:')
    for i = 1:numAddresses
        disp(['  ' char(aScanListNames(i))])
    end
    disp(['Scan rate = ' num2str(scanRate) ' Hz'])
    disp(['Sample rate = ' num2str(scanRate * numAddresses) ' Hz'])
    disp(['Total number of scans = ' num2str(numScans)])
    disp(['Total number of samples = ' num2str(numScans * numAddresses)])
    disp(['Seconds of samples = ' num2str(numScans / scanRate) ' seconds'])

    disp('Streaming with StreamBurst...')

    tic

    % Stream data using StreamBurst
    [~, scanrate] = LabJack.LJM.StreamBurst(handle, numAddresses, ...
        aScanList, scanRate, numScans, aData);

    timeElapsed = toc;

    disp('Done')

    skippedTotal = sum(double(aData) == -9999.0);

    disp(['Skipped scans = ' num2str(skippedTotal/numAddresses)])
    disp(['Time taken = ' num2str(timeElapsed) ' seconds'])

    disp('Last scan:')
    for i = 1:numAddresses
        disp(['  ' char(aScanListNames(i)) ' = ' ...
             num2str(aData((numScans-1)*numAddresses + i))])
    end

    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
    LabJack.LJM.CloseAll();
end
