%
% Demonstrates how to use the eReadName (LJM_eReadName) function using
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
    [ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);

    showDeviceInfo(handle);
    
    %Setup and call eReadName to read a value.
    name = 'SERIAL_NUMBER';
    [ljmError, value] = LabJack.LJM.eReadName(handle, name, 0);
    
    disp('eReadName result:')
    disp(['  Name: ' name ', value: ' num2str(value)])
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
