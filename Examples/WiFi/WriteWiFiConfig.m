%
% Demonstrates how to configure the WiFi settings on a LabJack using .NET.
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
    
    %Setup and call eWriteNames to configure WiFi default settings.
    numFrames = 3;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'WIFI_IP_DEFAULT';
    aNames(2) = 'WIFI_SUBNET_DEFAULT';
    aNames(3) = 'WIFI_GATEWAY_DEFAULT';
    aValues = NET.createArray('System.Double', numFrames);
    [ljmError, aValues(1)] = LabJack.LJM.IPToNumber("192.168.1.207", 0);
    [ljmError, aValues(2)] = LabJack.LJM.IPToNumber("255.255.255.0", 0);
    [ljmError, aValues(3)] = LabJack.LJM.IPToNumber("192.168.1.1", 0);
    LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);
    
    disp('Set WiFi configuration:')
    str = '';
    %Needs testing
    for i=1:numFrames,
        [ljmError, str] = LabJack.LJM.NumberToIP(uint32(double(aValues(i))), str); %may not need to convert to double first
        disp(['    ' char(aNames(i)) " : " num2str(aValues(i)) " - " + str])
    end
    
    %Setup and call eWriteString to configure the default WiFi SSID.
    name = 'WIFI_SSID_DEFAULT';
    str = 'LJOpen';
    [ljmError, str] = LabJack.LJM.eWriteNameString(handle, name, str);
    disp(['    ' name ' : ' str])

    %Setup and call eWriteString to configure the default WiFi password.
    name = 'WIFI_PASSWORD_DEFAULT';
    str = 'none';
    [ljmError, str] = LabJack.LJM.eWriteNameString(handle, name, str);
    disp(['    ' name ' : ' str])

    %Setup and call eWriteName to apply the new WiFi configuration
    name = "WIFI_APPLY_SETTINGS";
    value = 1; %1 = apply
    [ljmError, str] = LabJack.LJM.eWriteName(handle, name, value);
    disp(['    ' name ' : ' value])
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
