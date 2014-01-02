%
% Demonstrates how to use the eNames (LJM_eNames) function using .NET.
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
    
    %Setup and call eNames to write/read values.
    numFrames = 3;
    aNames = NET.createArray('System.String', 3);
    aNames(1) = 'DAC0';
    aNames(2) = 'TEST_UINT16';
    aNames(3) = 'TEST_UINT16';
    aWrites = NET.createArray('System.Int32', 3);
    aWrites(1) = LJM_CONSTANTS.WRITE;
    aWrites(2) = LJM_CONSTANTS.WRITE;
    aWrites(3) = LJM_CONSTANTS.READ;
    aNumValues = NET.createArray('System.Int32', 3);
    aNumValues(1) = 1;
    aNumValues(2) = 1;
    aNumValues(3) = 1;
    aValues = NET.createArray('System.Double', 3);
    aValues(1) = 2.5; %write 2.5 V
    aValues(2) = 12345; %write 12345
    aValues(3) = 0; %read
    LabJack.LJM.eNames(handle, numFrames, aNames, aWrites, aNumValues, aValues, 0);
    
    disp('eNames results:')
    for i=1:numFrames,
        disp(['  Name: ' char(aNames(i)) ', write: ' num2str(aWrites(i)) ', value: ' num2str(aValues(i))])
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
