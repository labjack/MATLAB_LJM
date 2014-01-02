%
% Demonstrates how to use the eReadAddresses (LJM_eReadAddresses) function
% using .NET.
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
    
    %Setup and call eReadAddresses to read values.
    numFrames = 3;
    aAddresses = NET.createArray('System.Int32', 3);
    aAddresses(1) = 60028; %serial number
    aAddresses(2) = 60000; %product ID
    aAddresses(3) = 60004; %firmware version
    aTypes = NET.createArray('System.Int32', 3);
    aTypes(1) = LJM_CONSTANTS.UINT32;
    aTypes(2) = LJM_CONSTANTS.FLOAT32;
    aTypes(3) = LJM_CONSTANTS.FLOAT32;
    aValues = NET.createArray('System.Double', 3);
    LabJack.LJM.eReadAddresses(handle, numFrames, aAddresses, aTypes, aValues, 0);
    
    disp('eReadAddresses results:')
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
