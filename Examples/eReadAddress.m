%
% Demonstrates how to use the eReadAddress (LJM_eReadAddress) function using
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
    [ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    
    showDeviceInfo(handle);
    
    %Setup and call eReadAddress to read a value from the LabJack.
    address = 60028; % Serial number
    dataType = LJM_CONSTANTS.UINT32;
    value = 0;
    [ljmerror, value] = LabJack.LJM.eReadAddress(handle, address, dataType, value);
    
    disp('eReadAddress result:')
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
