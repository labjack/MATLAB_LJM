%
% Demonstrates how to stream using the eStream functions using .NET.
%
% support@labjack.com
%

clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

ljmAsm = NET.addAssembly('LabJack.LJM'); %Make the LJM .NET assembly visible in MATLAB

t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
LJM_CONSTANTS = System.Activator.CreateInstance(t); %creating an object to nested class LabJack.LJM.CONSTANTS

dispErr = true;
handle = 0;

try
    %Open first found LabJack
    [ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    
    showDeviceInfo(handle);
    
    maxRequests = 50; %The number of eStreamRead calls to perform in the stream read loop
    
    %Stream Configuration
    numAddresses = 4;
    aScanListNames = NET.createArray('System.String', numAddresses);
    aScanListNames(1) = 'AIN0';
    aScanListNames(2) = 'AIN1';
    aScanListNames(3) = 'AIN2';
    aScanListNames(4) = 'AIN3';
    aScanList = NET.createArray('System.Int32', numAddresses);
    aTypes = NET.createArray('System.Int32', numAddresses); %Dummy array for aTypes parameter
    LabJack.LJM.NamesToAddresses(numAddresses, aScanListNames, aScanList, aTypes);
    scanRate = double(1000);
    scansPerRead = int32(scanRate/2);
    %Stream reads will be stored in aData. Needs to be at least
    %NumAddresses*ScansPerRead in size.
    aData = NET.createArray('System.Double', numAddresses*scansPerRead);
    
    %Configure scan list for single ended readings
    aNames = NET.createArray('System.String', numAddresses);
    aValues = NET.createArray('System.Double', numAddresses);
    for i=1:numAddresses,
        aNames(i) = [char(aScanListNames(i)) '_NEGATIVE_CH'];
        aValues(i) = LJM_CONSTANTS.GND;
    end
    LabJack.LJM.eWriteNames(handle, numAddresses, aNames, aValues, 0);
    
    try
        %Configure and start stream
        [ljmError, scanRate] = LabJack.LJM.eStreamStart(handle, scansPerRead, numAddresses, aScanList, scanRate);
        disp(['Stream started with a scan rate of ' num2str(scanRate) ' Hz.'])
    catch e
        showErrorMessage(e)
        dispErr = false;
        %try
        %    LabJack.LJM.eStreamStop(handle); %In case a previous stream was started
        %catch
        %end
        %throw()
    end
    
    tic

    try
        disp(['Performing ' num2str(maxRequests) ' stream reads Hz.'])

        totalScans = 0;
        curSkippedSamples = 0;
        totalSkippedSamples = 0;
       
        for i=1:maxRequests,
            [ljmError, deviceScanBacklog, ljmScanBacklog] = LabJack.LJM.eStreamRead(handle, aData, 0, 0);

            totalScans = totalScans + scansPerRead;

            %Count the skipped samples which are indicated by -9999 values.
            %Missed samples occur after a device's stream buffer overflows and
            %are reported after auto-recover mode ends.
            
            %Todo: ount the -9999.0
            aData(1) = -9999.00;
            aData(2) = aData(1);
            aData(3) = aData(1);
            aData(4) = aData(1);
            tic
            curSkippedSamples = sum(aData == -9999.0)
            toc
            totalSkippedSamples = totalSkippedSamples + curSkippedSamples;

            disp(['  eStreamRead ' num2str(i)])
            ainStr = '';
            for j=1:numAddresses,
                ainStr = [ainStr char(aScanListNames(j)) ' = ' num2str(aData(j)) '  '];
            end
            disp(['  1st scan out of ' num2str(scansPerRead) ': ' ainStr])
            disp(['  Scans Skipped = ' num2str(curSkippedSamples/numAddresses) ', Scan Backlogs: Device = ' ...
                num2str(deviceScanBacklog) ', LJM = ' num2str(ljmScanBacklog)])
        end
       
    catch e
        showErrorMessage(e)
    end
    
    timeElapsed = toc;
    
    disp(['Total scans = ' num2str(totalScans)])
    disp(['Time Taken = ' num2str(timeElapsed) ' seconds'])
    disp(['LJM Scan Rate = ' num2str(scanRate) ' scans/second'])
    disp(['Timed Scan Rate = ' num2str(totalScans/timeElapsed) ' scans/second'])
    disp(['Sample Rate = ' num2str(numAddresses*totalScans/timeElapsed) ' samples/second'])
    disp(['Skipped Scans = ' num2str(totalSkippedSamples/numAddresses)])

    disp('Stop Stream')
    LabJack.LJM.eStreamStop(handle);
catch e
    if dispErr
        showErrorMessage(e)
    end
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end