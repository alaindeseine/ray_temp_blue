# BlueTherm LE Protocol 1.

### 23/08/

## Advertisement Payload

```
Length Address SIG Description Info e.g.
0x02 0x01 Flags Connection info
```
```
0x
0x
Complete Local
Name
```
```
Serial number and
product name
```
```
12345678 ThermaQ Blue
12345678 BlueTherm One
12345678 ThermapenBlue
12345678 RayTemp Blue
12345678 TempTest Blue
```
```
0x04 0xFF
Manufacturer
Specific Data ETI SIG ID (0x376)^7603
```
## Standard (SIG) Services

```
Service Name
Service
UUID Property Characteristic
```
```
Characteris
tic UUID Format Further Info.
Device
Information
“ Read Model Number String 0x2A24 utf8s
Product dependant e.g. 292-
911 or THS-292-
“ “ Read Serial Number String 0x2A25 utf8s
e.g. 17061234
yr/week/no.
“ “ Read Firmware Revision String 0x2A26 utf8s e.g. 1.
“ “ Read Hardware Revision String 0x2A27 utf8s Protocol Version e.g. 1.
“ “ Read Software Revision String 0x2A28 Utf8s
BT Module Software revision
No. e.g. 1.33BEC
```
```
“ 0x180A Read
Manufacturer Name
String 0x2A29 utf8s ‘ETI Ltd’
Battery Service 0x180F Notify Battery Level 0x2A19 uint8 0-100%
```
```
Generic Access
0x
Read
Device Name
0x2A
Utf8s
```
```
12345678 ThermaQBlue
12345678BlueThermOne
12345678 Thermapen
12345678 RayTempBlue
12345678TempTestBlue
```
## Private Services

UUID: 0x455449424C5545544845524DB87AD700 (in ASCII = ETIBLUETHERM ̧z×)

Slot No. Private Characteristic Name Characteristic UUID Property
1&2 Sensor 1 Reading 0x455449424C5545544845524DB87AD701 Read & Notify
3&4 Sensor 2 Reading* 0x455449424C5545544845524DB87AD703 Read & Notify
5&6 Command/ Notifications 0x455449424C5545544845524DB87AD705 Read/Write & Notify
7 Sensor 1 Settings 0x455449424C5545544845524DB87AD707 Read/Write
8 Sensor 2 Settings* 0x455449424C5545544845524DB87AD708 Read/Write
9 Instrument Settings 0x455449424C5545544845524DB87AD709 Read/Write
10 Trim Settings 0x455449424C5545544845524DB87AD70A Read/Write
Note: * Sensor 2 Characteristics are only present on dual input devices.


## Private Characteristics

### Sensor 1 & 2 Readings

Offset Length Description Format
0 4 Sensor X Value (in ºC & Trim compensated) IEEE-754 32-bit floating point (Little Endian)
Sensor error = 0xFFFFFFFF
These values are not rounded – use rounding method ‘halfway cases rounded away from zero’.

### Commands / Notifications

```
Offset Length Description Format
0 2 Commands
0x0010 = Measure (Manual)
0x0020 = Identify Instrument (Flashes LED(s) for 3 secs) (if instrument has LEDs)
0x0030 = Set Default settings (excluding Sensor Names & Trim values)
0x0040 = Set Factory Defaults settings (including Sensor Names & Trim values)
Notifications
0x0001 = Button pressed (Measured readings will follow)
0x0002 = Shutdown Notification
0x0003 = Invalid Setting
0x0004 = Invalid Command
0x0005 = Request Refresh*
```
```
uint16(little Endian)
```
*Requests that the host re-reads all readable characteristics

### Sensor (x) Settings

Offset Length Description Max Min Format
0 4 High Alarm Value (in ºC if a temperature) * * IEEE-754 32-bit floating point (little Endian)
0xFFFFFFFF = Off
4 4 Low Alarm Value (in ºC if a temperature) * * IEEE-754 32-bit floating point (little Endian)
0xFFFFFFFF = Off
8 12 Sensor Name N/A N/A Up to 12 bytes of utf8s characters
*Depends on Sensor type – see Sensor Types Table

### Instrument Settings

```
Offset Length Description Max Min Format
0 1 Units:
0x00 = ºC
0x01 = ºF
```
```
0x01 0x00 uint
```
```
1 2 Measurement Interval in seconds.
Set to 0x0000 for Manual Mode (Instrument Button or Measure
Command initiates measurement)
```
```
0x003C 0x0000 uint16(little Endian)
```
```
3 2 Auto-off Interval in Minutes 0x0000 = Inhibited 0x05A0 0x0000 uint16(little Endian)
5 1 Sensor 2 Enable (ThermaQ Blue only)
0x01 = On or 0x00 = Off (default = 0x01)
```
```
0x01 0x00 uint
```
```
6 1 Sensor Types. Low 4-bits: sensor 1 type, high 4 bits: sensor 2
type - see Sensor Type Table
```
```
N/A N/A uint8 (Read Only)
```
```
7 1 Emissivity (IR Sensor only) Default = 95 (0.95 emissivity).
Max = 100 (1.00 emissivity) & Min = 10 (0.10 emissivity)
```
```
0x
(100)
```
```
0x0A
(10)
```
```
uint
```
Please Note: Settings are stored in the instrument’s Flash Memory which has an erase/write endurance of 10,000 cycles,
and therefore it is recommended that the settings are only updated when necessary.


### Sensor Types - The one-byte Sensor Type field in the Instrument Settings characteristic consists of a low 4-bit field

specifying the type of the first sensor, and a high 4-bit field specifying (if present) the type of the second sensor, thus:
Value (4 bits) Description Max °C Min °C e.g. Sensor Type Field

```
0x
Detachable Type K
Thermocouple
```
#### 1372 -

```
ThermaQ Blue = 0x11 (i.e. 2 sensors, both type 0x1)
BlueTherm One LE = 0x01 (i.e. single-sensor, type 0x1)
0x
Fixed Type K
Thermocouple
300 -50 Thermapen Blue = 0x02 (i.e. single-sensor, type 0x2)
0x3 Infrared (Type 1) 350 - 50 RayTemp Blue = 0x03 (i.e. single sensor, type 0x3)
```
### Trim Settings (not recommended for general use)

```
Offset Length Description MAX MIN Format
0 4 Sensor 1 Trim Value (in ºC if a temperature) 5.0 - 5.0 IEEE-754 32-bit floating point (little Endian)
```
(^4 3) Sensor 1 Trim Set Date Day
Month
Year
31 0 3 * uint8 (if all zeros then not set - default)
12 0
99 0
For Dual Input devices Only
7 4 Sensor 2 Trim Value (in ºC if a temperature) 5.0 - 5.0 IEEE-754 32-bit floating point (little Endian)
(^11 3) Sensor 2 Trim Set Date Day
Month
Year
31 0 3 * uint8 (if all zeros then not set - default)
12 0
99 0
Note regarding all settings characteristics: If any value is set outside of the Max or Min values an ‘Invalid Setting’ notification
will occur and the whole characteristic reverts to its previous settings. This is also true if a Trim value other than 0.0 is set
without a valid date or if a Low Alarm value is set higher or equal to its corresponding High Alarm value.


