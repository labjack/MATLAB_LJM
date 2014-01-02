%
% Demonstrates how to use the eWriteAddresses (LJM_eWriteAddresses)
% function using .NET.
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
    
    %Setup and call eWriteAddresses to write values.
    numFrames = 2;
    aAddresses = NET.createArray('System.Int32', 2);
    aAddresses(1) = 1000; %DAC0
    aAddresses(2) = 55110; %TEST_UINT16
    aTypes = NET.createArray('System.Int32', 2);
    aTypes(1) = LJM_CONSTANTS.FLOAT32;
    aTypes(2) = LJM_CONSTANTS.UINT16;
    aValues = NET.createArray('System.Double', 2);
    aValues(1) = 2.5; %2.5 V
    aValues(2) = 12345;
    LabJack.LJM.eWriteAddresses(handle, numFrames, aAddresses, aTypes, aValues, 0);
    
    disp('eWriteAddresses:')
    for i=1:numFrames,
        disp(['  Address: ' num2str(aAddresses(i)) ', data type: ' num2str(aTypes(i)) ', value: ' num2str(aValues(i))])
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
