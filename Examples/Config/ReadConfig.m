%
% Demonstrates how to read configuration settings on a LabJack using .NET.
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

    %Setup and call eReadNames to read configuration values.
    numFrames = 10;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'PRODUCT_ID';
    aNames(2) = 'HARDWARE_VERSION';
    aNames(3) = 'FIRMWARE_VERSION';
    aNames(4) = 'BOOTLOADER_VERSION';
    aNames(5) = 'WIFI_VERSION';
    aNames(6) = 'SERIAL_NUMBER';
    aNames(7) = 'POWER_ETHERNET_DEFAULT';
    aNames(8) = 'POWER_WIFI_DEFAULT';
    aNames(9) = 'POWER_AIN_DEFAULT';
    aNames(10) = 'POWER_LED_DEFAULT';
    aValues = NET.createArray('System.Double', numFrames);
    LabJack.LJM.eReadNames(handle, numFrames, aNames, aValues, 0);

    disp('Configuration settings:')
    for i=1:numFrames,
        disp([char(aNames(i)) ', value: ' num2str(aValues(i))])
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
