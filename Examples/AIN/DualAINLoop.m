%
% Demonstrates reading 2 analog inputs (AINs) in a loop using .NET.
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
    
    %Setup and call eWriteNames to configure AINs.
    numFrames = 6;
    names = NET.createArray('System.String', numFrames);
    names(1) = 'AIN0_NEGATIVE_CH';
    names(2) = 'AIN0_RANGE';
    names(3) = 'AIN0_RESOLUTION_INDEX';
    names(4) = 'AIN1_NEGATIVE_CH';
    names(5) = 'AIN1_RANGE';
    names(6) = 'AIN1_RESOLUTION_INDEX';
    aValues = NET.createArray('System.Double', numFrames);
    aValues(1) = 199; %single-ended
    aValues(2) = 10;  %+-10 V
    aValues(3) = 0;   %default
    aValues(4) = 199; %single-ended
    aValues(5) = 10;  %+-10 V
    aValues(6) = 0;   %default
    LabJack.LJM.eWriteNames(handle, numFrames, names, aValues, 0);
    
    disp('Set configuration:');
    for i=1:numFrames,
        disp(['  ' char(names(i)) ': value: ' num2str(aValues(i))])
    end
    
    %Setup and call eReadNames to read AINs.
    numFrames = 2;
    names = NET.createArray('System.String', numFrames);
    names(1) = 'AIN0';
    names(2) = 'AIN1';
    aValues = NET.createArray('System.Double', numFrames);
    
    delay = 1; %delay between readings (in sec)
    disp(['Performing 10 AIN0 and AIN1 readings with ' num2str(delay) ' second delay between readings:']);
    
    for i=1:10,
        LabJack.LJM.eReadNames(handle, numFrames, names, aValues, 0);
        disp(['  ' char(names(1)) ': ' num2str(aValues(1)) ' V, ' char(names(2)) ': ' num2str(aValues(2)) ' V'])
        pause(delay);
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
