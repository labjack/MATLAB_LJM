%
% Demonstrates how to use the eWriteNames (LJM_eWriteNames) function using
% .NET.
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
    [ljmerror, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    
    showDeviceInfo(handle);
    
    %Setup and call eWriteNames to write values.
    numFrames = 2;
    aNames = NET.createArray('System.String', 2);
    aNames(1) = 'DAC0';
    aNames(2) = 'TEST_UINT16';
    aValues = NET.createArray('System.Double', 2);
    aValues(1) = 2.5; %2.5 V
    aValues(2) = 12345; %12345
    LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);

    disp('eWriteNames:');
    for i=1:numFrames,
        disp(['  Name: ' char(aNames(i)) ', value: ' num2str(aValues(i))])
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
