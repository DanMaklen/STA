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
	*There is a bug if a target is also a starting point. For example, if the function of the flipflop a function of it's output. It will do the calculations correctly, however it will only print its setup with respect to D only. Not it's tcq delay from of the start. That is because I am displaying per gate not per pin.

A complete sample report is done on DFFSR and mac. (P.S. DFFSR is much easier to trace and validate).
There are  more test cases in folder TEST. Some of them might crash because of the reasons stated above. For example, "PmodI2S_FSM" module crashed because of the Ties cells.

Illusteration for mac_Report, path 1:
This reports the slack of setup constrain on flipflip '_129_'(DFFPOSX1)
Each row discribes the delay and slack on each node in the path.
First column is the name of the node, second column is the type of gate. Then the delay it adds, followed by the accumlated delay and finally the slack.
The clock - _129_ connection is not displayed here unfortuantly bacause of the bug stated earilier.
Since the program doesn't output the reported orded, we will have to order them manually by sorting them according to accumlation delay. Ofcourse the target flipflop should be at the end.
After sorting, I personally find it easier to trace it from the buttom up.
So flipflip _129_ has a setup requirment of 1.26121 and total delay of 6.62457 and slack on that node of 3.3754.
That means that we can resize the flipflop for more setup constrain. Or decrease the clock period by 3.3754 units.
We can also compare the slacks, all those have the same slack as the target flipflop are part of the critical path.
And those who have more slack may indicate that it is possible to resize them for more delay.

Name    Type     	Delay       Acc 		Slack
A[0]    InputPort   0.2         0.2         3.37543
B[0]    InputPort   0.2         0.2         3.37904
clk     InputPort   0.23        0.23        4.04226
_064_   AND2X2      0.209965    0.409965    3.37543
rst     InputPort   0.5         0.5        	5.00654
_063_   INVX1       0.171042    0.572351    4.04226
_065_   INVX1       0.289941    0.699906    3.37543
_095_   INVX1       0.111994    0.611994    5.00654
_099_   NAND2X1     0.566264    1.26617     3.37543
_066_   NOR2X1      0.679978    1.37988     7.31575
_100_   NAND2X1     1.18907     2.45524     3.37543
_101_   NOR2X1      2.90812     5.36335     3.37543
_129_	DFFPOSX1    1.26121		6.62457     3.37543