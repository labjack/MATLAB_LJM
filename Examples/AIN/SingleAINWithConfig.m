%
% Demonstrates configuring and reading a single analog input (AIN) with a
% LabJack using .NET.
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
    
    %Setup and call eWriteNames to configure AIN0.
    numFrames = 3;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'AIN0_NEGATIVE_CH';
    aNames(2) = 'AIN0_RANGE';
    aNames(3) = 'AIN0_RESOLUTION_INDEX';
    aValues = NET.createArray('System.Double', numFrames);
    aValues(1) = 199; %single-ended
    aValues(2) = 10;  %+-10 V
    aValues(3) = 0;   %default
    LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);

    disp('Set configuration:');
    for i=1:numFrames,
        disp(['  ' char(aNames(i)) ': value: ' num2str(aValues(i))])
    end

    %Setup and call eReadName to read from AIN0.
    name = 'AIN0';
    [ljmError, value] = LabJack.LJM.eReadName(handle, name, 0);

    disp([name ': ' num2str(value) ' V'])
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
