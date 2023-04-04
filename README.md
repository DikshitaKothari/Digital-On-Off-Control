# Digital-On-Off-Control
The goal in this case study is to provide an understanding of the issues and techniques for on/off control using an embedded microcontroller.
Feedback control involves the measuring of a sensor signal and deriving an input to the system to
produce a required response in real time. While feedback control often involves the measurement
and use of continuous (analog) signals, a very large number of embedded control applications
require simply measuring a discrete (digital) source such as a switch and turning a device on or
off. These applications include the use of high power sources. Large motors, for example, often
use alternating current (ac) rather than direct current (dc) and derive their speed control from the
frequency of the power grid (60 Hz in the United States). To start these motors, a signal is sent to
a triac, solid-state switch or relay which applies the ac power to the motor. Chemical processes
often use solenoid (on/off) valves to control the flow of reactants. Safety systems are often on/off
where the power to the system can be shutdown by opening the main breaker. What
differentiates on/off control from simple on/off switching is the use of sensors. When an actuator
is turned on, a sensor determines if the process really turns on. When an actuator is turned off, a
sensor determines if the process really turns off.

The microcomputer is a very effective device for sophisticated on/off control applications. While
some microcomputers have A/D converter inputs to read analog signals and pulse width
modulated (PWM) outputs to produce analog signals, all have digital (on/off) input and output
ports for interfacing to the system. Programming the microcomputer involves setting the
properties on the port for the desired operation (reading or writing) and setting internal registers
for the desired control. Considerations for turning power devices on or off can involve simple
timing (open loop) or the state of digital sensors (closed loop feedback).
