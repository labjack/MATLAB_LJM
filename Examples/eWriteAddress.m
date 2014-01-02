%
% Demonstrates how to use the eWriteAddress (LJM_eWriteAddress) function
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
    [ljmerror, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctUSB, 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.OpenS('ANY', 'USB', 'ANY', handle);
    
    showDeviceInfo(handle);

    %Setup and call eWriteAddress to write a value to the LabJack.
    address = 1000; %DAC0
    dataType = LJM_CONSTANTS.FLOAT32;
    value = 2.5; %2.5 V
    LabJack.LJM.eWriteAddress(handle, address, dataType, value);

    disp('eWriteAddress:')
    disp(['  Address: ' num2str(address) ', data type: ' num2str(dataType) ', value: ' num2str(value)])
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
