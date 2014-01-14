%
% Demonstrates I2C communication uaing .NET. The demonstration uses a LJTick-DAC
% connected to FIO0/FIO1, configures I2C settings, and reads, writes and reads
% bytes from/to the EEPROM.
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
    
    
    %Configure the I2C communication.
    LabJack.LJM.eWriteName(handle, 'I2C_SDA_DIONUM', 1); %SDA pin number = 1 (FIO1)
    
    LabJack.LJM.eWriteName(handle, 'I2C_SCL_DIONUM', 0); %SCA pin number = 0 (FIO0)
    
    %Speed throttle is inversely proportional to clock frequency. 0 = max.
    LabJack.LJM.eWriteName(handle, 'I2C_SPEED_THROTTLE', 0); %Speed throttle = 0
    
    %Options bits:
    %  bit0: Reset the I2C bus.
    %  bit1: Restart w/o stop
    %  bit2: Disable clock stretching.
    LabJack.LJM.eWriteName(handle, 'I2C_OPTIONS', 0); %Options = 0
    
    LabJack.LJM.eWriteName(handle, 'I2C_SLAVE_ADDRESS', 80); %Slave Address of the I2C chip = 80 (0x50)
    
    
    %Initial read of EEPROM bytes 0-3 in the user memory area. We need a single
    %I2C transmission that writes the chip's memory pointer and then reads the
    %data.
    LabJack.LJM.eWriteName(handle, 'I2C_NUM_BYTES_TX', 1); %Set the number of bytes to transmit
    LabJack.LJM.eWriteName(handle, 'I2C_NUM_BYTES_RX', 4); %Set the number of bytes to receive
    
    aNames = NET.createArray('System.String', 1);
    aWrites = NET.createArray('System.Int32', 1);
    aNumValues = NET.createArray('System.Int32', 1);
    aValues = NET.createArray('System.Double', 5); %TX/RX bytes will go here
    
    %Set the TX bytes. We are sending 1 byte for the address.
    aNames(1) = 'I2C_WRITE_DATA';
    aWrites(1) = LJM_CONSTANTS.WRITE; %Indicates we are writing the values.
    aNumValues(1) = 1; %The number of bytes
    aValues(1) = 0; %Byte 0: Memory pointer = 0
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, aValues, 0);
    
    LabJack.LJM.eWriteName(handle, 'I2C_GO', 1); %Do the I2C communications.
    
    %Read the RX bytes.
    aNames(1) = 'I2C_READ_DATA';
    aWrites(1) = LJM_CONSTANTS.READ; %Indicates we are reading the values.
    aNumValues(1) = 4; %The number of bytes
    %aValues(1) to aValues(4) will contain the data
    for i=1:4,
        aValues(i) = 0;
    end
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, aValues, 0);
    
    disp('Read User Memory = ')
    aVals = double(aValues);
    disp(aVals(1:4))
    
    
    %Write EEPROM bytes 0-3 in the user memory area, using the page write
    %technique. Note that page writes are limited to 16 bytes max, and must be
    %aligned with the 16-byte page intervals. For instance, if you start writing
    %at address 14, you can only write two bytes because byte 16 is the start of
    %a new page.
    LabJack.LJM.eWriteName(handle, 'I2C_NUM_BYTES_TX', 5); %Set the number of bytes to transmit
    LabJack.LJM.eWriteName(handle, 'I2C_NUM_BYTES_RX', 0); %Set the number of bytes to receive
    
    %Set the TX bytes.
    aNames(1) = 'I2C_WRITE_DATA';
    aWrites(1) = LJM_CONSTANTS.WRITE; %Indicates we are writing the values.
    aNumValues(1) = 5; %The number of bytes
    aValues(1) = 0; %Byte 0: Memory pointer = 0
    %Create 4 new random numbers to write (aValues(2:5)).
    for i=2:5,
        aValues(i) = randi(255); %1 to 255
    end
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, aValues, 0);
    
    LabJack.LJM.eWriteName(handle, 'I2C_GO', 1); %Do the I2C communications.
    
    disp('Write User Memory = ');
    aVals = double(aValues);
    disp(aVals(2:5))
    
    
    %Final read of EEPROM bytes 0-3 in the user memory area. We need a single
    %I2C transmission that writes the address and then reads the data.
    LabJack.LJM.eWriteName(handle, 'I2C_NUM_BYTES_TX', 1); %Set the number of bytes to transmit
    LabJack.LJM.eWriteName(handle, 'I2C_NUM_BYTES_RX', 4); %Set the number of bytes to receive

    %Set the TX bytes. We are sending 1 byte for the address.
    aNames(1) = 'I2C_WRITE_DATA';
    aWrites(1) = LJM_CONSTANTS.WRITE; %Indicates we are writing the values.
    aNumValues(1) = 1; %The number of bytes
    aValues(1) = 0; %Byte 0: Memory pointer = 0
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, aValues, 0);

    LabJack.LJM.eWriteName(handle, 'I2C_GO', 1); %Do the I2C communications.

    %Read the RX bytes.
    aNames(1) = 'I2C_READ_DATA';
    aWrites(1) = LJM_CONSTANTS.READ; %Indicates we are reading the values.
    aNumValues(1) = 4; %The number of bytes
    %aValues(1) to aValues(4) will contain the data
    for i=1:4,
        aValues(i) = 0;
    end
    LabJack.LJM.eNames(handle, 1, aNames, aWrites, aNumValues, aValues, 0);

    disp('Read User Memory = ');
    aVals = double(aValues);
    disp(aVals(1:4))
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
