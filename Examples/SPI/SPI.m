%
% Demonstrates SPI communication.
%
% You can short MOSI to MISO for testing.
%
% MOSI    FIO2
% MISO    FIO3
% CLK     FIO0
% CS      FIO1
%
% If you short MISO to MOSI, then you will read back the same bytes that you
% write. If you short MISO to GND, then you will read back zeros. If you short
% MISO to VS or leave it unconnected, you will read back 255s.
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
    
    
    %CS is FIO1
    LabJack.LJM.eWriteName(handle, 'SPI_CS_DIONUM', 1);
    
    %CLK is FIO0
    LabJack.LJM.eWriteName(handle, 'SPI_CLK_DIONUM', 0);
    
    %MISO is FIO3
    LabJack.LJM.eWriteName(handle, 'SPI_MISO_DIONUM', 3);
    
    %MOSI is FIO2
    LabJack.LJM.eWriteName(handle, 'SPI_MOSI_DIONUM', 2);
    
    %Modes:
    %0 = A: CPHA=0, CPOL=0 
    %    Data clocked on the rising edge
    %    Data changed on the falling edge
    %    Final clock state low
    %    Initial clock state low
    %1 = B: CPHA=0, CPOL=1
    %    Data clocked on the falling edge
    %    Data changed on the rising edge
    %    Final clock state low
    %    Initial clock state low
    %2 = C: CPHA=1, CPOL=0 
    %    Data clocked on the falling edge
    %    Data changed on the rising edge
    %    Final clock state high
    %    Initial clock state high
    %3 = D: CPHA=1, CPOL=1 
    %    Data clocked on the rising edge
    %    Data changed on the falling edge
    %    Final clock state high
    %    Initial clock state high
    
    %Selecting Mode: A - CPHA=1, CPOL=1.
    LabJack.LJM.eWriteName(handle, 'SPI_MODE', 0);
    
    %Speed Throttle:
    %Frequency = 1000000000 / (175*(65536-SpeedThrottle) + 1020)
    %Valid speed throttle values are 1 to 65536 where 0 = 65536.
    %Note: The above equation and its frequency range were tested for
    %firmware 1.0009 and may change in the future.
    
    %Configuring Max. Speed (~ 1 MHz)
    LabJack.LJM.eWriteName(handle, 'SPI_SPEED_THROTTLE', 0);
    
    %Options
    %bit 0:
    %    0 = Active low clock select enabled
    %    1 = Active low clock select disabled.
    %bit 1:
    %    0 = DIO directions are automatically changed
    %    1 = DIO directions are not automatically changed.
    %bits 2-3: Reserved
    %bits 4-7: Number of bits in the last byte. 0 = 8.
    %bits 8-15: Reserved
    
    %Enabling active low clock select pin
    LabJack.LJM.eWriteName(handle, 'SPI_OPTIONS', 0);
    
    %Read back and display the SPI settings
    numFrames = 7;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'SPI_CS_DIONUM';
    aNames(2) = 'SPI_CLK_DIONUM';
    aNames(3) = 'SPI_MISO_DIONUM';
    aNames(4) = 'SPI_MOSI_DIONUM';
    aNames(5) = 'SPI_MODE';
    aNames(6) = 'SPI_SPEED_THROTTLE';
    aNames(7) = 'SPI_OPTIONS';
    aValues = NET.createArray('System.Double', numFrames);
    LabJack.LJM.eReadNames(handle, numFrames, aNames, aValues, 0);
    
    disp('SPI Configuration:')
    for i=1:numFrames,
        disp(['  ' char(aNames(i)) ' = ' num2str(aValues(i))]);
    end
    
    
    %Write/Read 4 bytes
    numBytes = 4;
    LabJack.LJM.eWriteName(handle, 'SPI_NUM_BYTES', numBytes);
    
    
    %Setup write bytes
    dataWrite = NET.createArray('System.Double', numBytes);
    for i=1:numBytes,
        dataWrite(i) = randi(255); %1 to 255
    end
    aNames = NET.createArray('System.String', 1);
    aWrites = NET.createArray('System.Int32', 1);
    aNumValues = NET.createArray('System.Int32', 1);
    
    %Write the bytes
    aNames(1) = 'SPI_DATA_WRITE';
    aWrites(1) = LJM_CONSTANTS.WRITE;
    aNumValues(1) = numBytes;
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, dataWrite, 0);
    
    %Display the bytes written
    disp('dataWrite: ')
    disp(double(dataWrite))
    
    
    %Read the bytes
    dataRead = NET.createArray('System.Double', numBytes);
    aNames(1) = 'SPI_DATA_READ';
    aWrites(1) = LJM_CONSTANTS.READ;
    aNumValues(1) = numBytes;
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, dataRead, 0);
    
    %Display the bytes read
    disp('dataRead: ')
    disp(double(dataRead));
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
