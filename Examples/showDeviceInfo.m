function showDeviceInfo(handle)
% showDeviceInfo Displays the device's information based on the passed
% device handle.

[ljmError, deviceType, connType, serialNumber, ipAddress, port, maxBytesPerMB] = LabJack.LJM.GetHandleInfo(handle, 0, 0, 0, 0, 0, 0);
ipAddrStr = '';
[ljmError, ipAddrStr] = LabJack.LJM.NumberToIP(ipAddress, ipAddrStr);
disp(['Opened a LabJack with Device type: ' num2str(deviceType) ', Connection type: ' num2str(connType) ','])
disp(['Serial number: ' num2str(serialNumber) ', IP address: ' char(ipAddrStr)  ', Port: ' num2str(port) ','])
disp(['Max bytes per MB: ' num2str(maxBytesPerMB)])

end

