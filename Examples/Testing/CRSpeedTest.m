%
% Performs LabJack operations in a loop and reports the timing statistics for
% the operations.
%
% support@labjack.com
%

clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

ljmAsm = NET.addAssembly('LabJack.LJM'); %Make the LJM .NET assembly visible in MATLAB

t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
LJM_CONSTANTS = System.Activator.CreateInstance(t); %creating an object to nested class LabJack.LJM.CONSTANTS

handle = 0;

try
    %Open first found LabJack
    [ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    
    showDeviceInfo(handle);
    
    
    numIterations = 1000; %Number of iterations to perform in the loop
    
    %Analog input settings
    numAIN = 1; %Number of analog inputs to read
    rangeAIN = 10.0;
    resolutionAIN = 1.0;
    
    %Digital settings
    readDigital = FALSE;
    writeDigital = FALSE;
    
    %Analog output settings
    writeDACs = FALSE;
    
    %Variables for LJM library calls
    numFrames = 0;
    %aNames = NET.createArray('System.String', numFrames);
    %aWrites = NET.createArray('System.Int32', numFrames);
    %aNumValues = NET.createArray('System.Int32', numFrames);
    %aValues = NET.createArray('System.Double', numFrames);
    
    if numAIN > 0
        %Configure analog input settings
        numFrames = numAIN*2;
        aNames = NET.createArray('System.String', numFrames);
        aValues = NET.createArray('System.Double', numFrames);
        for i=1:numAIN,
            aNames(i*2) = ['AIN' num2str(i) '_RANGE'];
            aValues(i*2) = rangeAIN;
            aNames(i*2+1) = ['AIN' num2Str(i) '_RESOLUTION_INDEX'];
            aValues(i*2+1) = resolutionAIN;
        end
        LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);
    else
        numAIN = 0;
    end
    
    %Initialize and configure eNames parameters for loop's eNames call
    numFrames = numAIN + readDigital + writeDigital + writeDACs*2;
    aNames = NET.createArray('System.String', numFrames);
    aWrites = NET.createArray('System.String', numFrames);
    aNumValues = NET.createArray('System.String', numFrames);
    aValues = NET.createArray('System.String', numFrames); %In this case numFrames is the size of aValue
    
    %Add analog input reads (AIN 0 to numAIN-1)
    for i=1:numAIN,
        aNames(i) = ['AIN' num2str(i-1)];
        aWrites(i) = LJM.CONSTANTS.READ;
        aNumValues(i) = 1;
        aValues(i) = 0;
    end

    if readDigital
        %Add digital read
        aNames(i) = 'DIO_STATE';
        aWrites(i) = LJM_CONSTANTS.READ;
        aNumValues(i) = 1;
        aValues(i) = 0;
        i++;
    end
    
    if writeDigital
        %Add digital write
        aNames(i) = 'DIO_STATE';
        aWrites(i) = LJM_CONSTANTS.WRITE;
        aNumValues(i) = 1;
        aValues(i) = 0; %output-low
        i++;
    
    if writeDACs
        %Add analog output writes (DAC0-1)
        for j=0:1,
            aNames(i) = ['DAC' num2Str(j)];
            aWrites(i) = LJM_CONSTANTS.WRITE;
            aNumValues(i) = 1;
            aValues(i) = 0.0; %0.0 V
            i++;
        end
    end
    
    disp('Test frames:')
    
    wrStr = "";
    for i=1:numFrames,
        if aWrites(i) == LJM_CONSTANTS.READ
            wrStr = 'READ';
        else
            wrStr = 'WRITE';
        end
        disp(['    ' wrStr ' ' aNames(i)])
    end
    disp(['Beginning ' num2str(numIterations) ' iterations...']);
    
    
    %Initialize time variables
    maxMS = 0;
    minMS = 0;
    totalMS = 0;
    curMS = 0;
    
    tic;
    
    %eNames operations loop
    for i=1:numIterations,
        st2 = tic;
        LabJack.LJM.eNames(handle, numFrames, aNames, aWrites, aNumValues, aValues, 0);
        
        curMS = toc*1000(st2)
        if minMS == 0
            minMS = curMS;
        end
        minMS = min(curMS, minMS);
        maxMS = max(curMS, maxMS);
        %totalMS += curMS;
    end
    
    totalMS = toc*1000;
    
    disp(['    ' num2str(numIterations) ' iterations performed:'])
    disp(['    Time taken: " num2str(totalMS) ' ms']);
    disp(['    Average time per iteration: ' num2str(totalMS/numIterations) ' ms'])
    disp(['    Min / Max time for one iteration: ' num2str(minMS) ' ms / ' num2str(maxMS) ' ms'])
    
    disp('Last eNames results:')
    for i=1:numFrames,
        if aWrites(i) == LJM_CONSTANTS.READ)
            wrStr = 'READ';
        else
            wrStr = 'WRITE';
        end
        disp(['    ' aNames(i) ' ' wrStr ' value : ' + aValues(i)]);
    end
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
