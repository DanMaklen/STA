This project is to apply static timing analysis on a given NetList.
First it parses the Liberty file to know what available cells, pins and their properties.
That information is stored in a structs with only method to calculate the interpolation and extrapolation.
Second it parses the Gate level NetList and associate with one of the GateClasses or PinClasses.
The basic structure is that I have a bipartite graph of three levels. First level there are Gates connected to Pins in the second level which inturn connected to wires in the last level.
Each pin and gate has a pointer to its Class from the liberty file.
InputPorts and OutputPorsts are modeled as a pair of wire and a special gate (doesn't belong to any of the liberty classes).
Finally it reads the constrain file to know the skews.
Then it traverse all the wires, propagate its load capacitance to the correct gates it is connect to.
Then traverse all the gates/pins to calculate the output slew rates
Then traverse all the gates/pins to calculate accumlated output delay.
Finally it traverses timing pathes, calculate the slack and print a report of that timing path.

Bugs & Limitations:
	*Hold slack is not calculated, however enough information is there to calculate it by passing on the graph.
	*Cell PADINOUT is not is not supported.
	*Assign statments doesn't connect pins. It crashes when capacitance of the wire is calculated.
	*Tie cells are not implemented in the liberty file thus a special cell need to be implemented to handel ties.
	*Cell DFFSR Setup Constrain on S and R are not taken into consideration. (i.e. only 1 setup constrain allowed).
	*It report the delays and slack per gate instead of per pin. (i.e. worst case only).
	*It report the delays and slack not in a specific order.
	*The terms Skew and Required in the code are used in wrong manner. Some required are actually skews. (That's due to bad design while generalizing DFF and OutputPort constrains.)

A complete sample report is done on DFFSR and mac. (P.S. DFFSR is much easier to trace and validate).
There are  more test cases in folder TEST. Some of them might crash because of the reasons stated above. For example, "PmodI2S_FSM" module crashed because of the Ties cells.