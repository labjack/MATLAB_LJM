%
% Demonstrates how to read the ethernet configuration settings from a LabJack
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
    [ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    
    showDeviceInfo(handle);
    
    %Setup and call eReadNames to read ethernet configuration.
    numFrames = 8;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'ETHERNET_IP';
    aNames(2) = 'ETHERNET_SUBNET';
    aNames(3) = 'ETHERNET_GATEWAY';
    aNames(4) = 'ETHERNET_IP_DEFAULT';
    aNames(5) = 'ETHERNET_SUBNET_DEFAULT';
    aNames(6) = 'ETHERNET_GATEWAY_DEFAULT';
    aNames(7) = 'ETHERNET_DHCP_ENABLE';
    aNames(8) = 'ETHERNET_DHCP_ENABLE_DEFAULT';
    aValues = NET.createArray('System.Double', numFrames);
    LabJack.LJM.eReadNames(handle, numFrames, aNames, aValues, 0);
    
    disp('Ethernet configuration:')
    str = '';
    %Needs testing
    for i=1:numFrames,
        if isempty(strFind(char(aNames(i)), 'ETHERNET_DHCP_ENABLE')) %may not need char
            [ljmError, str] = LabJack.LJM.NumberToIP(uint32(double(aValues(i))), str); %may not need to convert to double first
            disp(['    ' char(aNames(i)) " : " num2str(aValues(i)) " - " + str]);
        else
            disp(['    ' char(aNames(i)) ' : ' num2str(aValues(i))]);
        end
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
