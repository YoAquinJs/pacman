# Raspberry Pi Version

The game can be played via the raspberry GPIO pins, if you want to use this feature YOU MUST FOLLOW THESE GUIDELINES for connecting the electric components to the pins, it's not assured that any other configuration would work.


## GPIO Input 

The game can be played via the raspberry GPIO pins, if you want to use this feature YOU MUST FOLLOW THESE GUIDELINES for connecting the electric components to the pins, it's not assured that any other configuration would work.

## Circuits

The input will be received via push buttons for the start and player movement input

### Components

* 5 Push buttons
* Cables
* Soldering iron and metal for soldering (Optional)
* Raspberry Pi 4 Model B (not tested in different versions of the raspberry)

### Pins

* Left: GPIO 20
* right: GPIO 21
* up: GPIO 22
* down: GPIO 23
* start: GPIO 24

### Connections

Coneect each buttons input to a 3.3v source, raspberry pi Pin 1 outputs this voltage, then connect each buttons output to its corresponding pin:

![](circuit.png)