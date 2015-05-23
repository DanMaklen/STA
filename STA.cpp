#include <iostream>
#include <algorithm>
#include <QString>
#include <QDebug>
#include <QRegExp>
#include <QFile>
#include <QTextStream>
#include <QList>
#include <QMap>
using namespace std;
enum DirEnum{DirUnknown = 0, DirInput = 1, DirOutput = 2};
enum CellType{CellGate = 0, CellDFF = 1, CellLatch = 2, CellInputPort = 3, CellOutputPort = 4};

class Pin{
public:
	QString Name;
	DirEnum Dir;
	QString WireList;
};
QDebug& operator<<(QDebug& o, const Pin& p){
	o << p.Name << ";" << p.Dir << ";" << p.WireList << ";";
	return o;
}
class Gate{
public:
	QString Name;
	QString Type;
	QList<Pin> Pins;
};
QDebug& operator<<(QDebug& o, const Gate& g){
	o << "Gate " << g.Name << "(" << g.Type << ") ";
	o << "Pins\n";
	o << "\t" << g.Pins << "\n";
	return o;
}
class PinIndex{
public:
	int gIDX;
	int pIDX;
	PinIndex(int x, int y){
		gIDX = x;
		pIDX = y;
	}
	bool operator<(const PinIndex& pid) const{
		return gIDX < pid.gIDX || (gIDX == pid.gIDX && pIDX < pid.pIDX);
	}
	bool operator==(const PinIndex& pid) const{
		return gIDX == pid.gIDX && pIDX == pid.pIDX;
	}
};
uint qHash(const PinIndex &p){
	return p.gIDX + p.pIDX;
}
QDebug& operator<<(QDebug& o, const PinIndex& pid){
	o << "PinIndex (" << pid.gIDX << ", " << pid.pIDX << ")";
	return o;
}
class Wire{
public:
	QString Name;
	QList<PinIndex> GateList;
};
QDebug& operator<<(QDebug& o, const Wire& w){
	o << w.Name << "; " << w.GateList << "\n";
	return o;
}
class LookUpTable{
public:
	int rows, cols;
	QMap<double, int> rIndex;
	QMap<double, double> cIndex;
	double table[10][10];
	LookUpTable& operator=(const LookUpTable& lut){
		rows = lut.rows; cols = lut.cols;
		rIndex = lut.rIndex; cIndex = lut.cIndex;
		for(int i = 0; i < 10; i++) for(int j = 0; j < 10; j++) table[i][j] = lut.table[i][j];
		return *this;
	}
	void clear(){
		rows = cols = 0;
		rIndex.clear(); cIndex.clear();
		for(int i = 0; i < rows; i++) for(int j = 0; j < 10; j++) table[i][j] = 0;
	}
};
QDebug& operator<<(QDebug& o, const LookUpTable& lut){
	o << "\nLUT(#Rows = " << lut.rows << " #Cols = " << lut.cols << '\n';
	o << "Row index = "; o << lut.rIndex;
	o << "\nCol index = "; o << lut.cIndex;
	o << "\nData:\n";
	for(int i = 0; i < lut.rows; i++, o << "\n") for(int j = 0; j < lut.cols; j++) o << lut.table[i][j] << ", ";
	o<<")LUT;\n";
	return o;
}
class TimingTable{
public:
	QString RelatedTo;
	QList<LookUpTable> tables;
	void clear(int n){
		RelatedTo = "";
		tables.clear();
		for(int i = 0; i < n; i++){
			tables.push_back(LookUpTable());
			tables.back().clear();
		}
	}
};
QDebug& operator<<(QDebug& o, const TimingTable& tt){
	o << "Timing Table Related to: " << tt.RelatedTo << "\t" << tt.tables.size();
	o << "\n";
	o << tt.tables;
	return o;
}
class CellPin{
public:
	QString Name;
	DirEnum Dir;
	double maxCap, minCap;
	QList<TimingTable> DelayTable;
	QList<TimingTable> SlewTable;
	void clear(){
		Name = "";
		Dir = DirUnknown;
		maxCap = minCap = -1;
		DelayTable.clear();
		SlewTable.clear();
	}
};
QDebug& operator<<(QDebug& o, const CellPin& p){
	o << p.Name << ", " << p.Dir << ", MaxC: " << p.maxCap << ", MinC: " << p.minCap << "\n";
	if(p.Dir == DirOutput) o << "Delay:\n" << p.DelayTable;
	if(p.Dir == DirOutput) o << "\nSlew:\n" << p.SlewTable;
	return o;
}
class CellClass{
public:
	CellType Type;
	QString Name;
	QList<int> Sizes;
	QList<QList<CellPin> > InputPins;
	QList<QList<CellPin> > OutputPins;
	TimingTable SetupTiming;
	TimingTable HoldTiming;
	void clear(){
		Name = "";
		Type = CellGate;
		Sizes.clear(); Sizes.push_back(0);
		InputPins.clear(); InputPins.push_back(QList<CellPin>());
		OutputPins.clear(); OutputPins.push_back(QList<CellPin>());
		SetupTiming.clear(2); HoldTiming.clear(2);
	}
};
QDebug& operator <<(QDebug& o, const CellClass& c){
	o << "\n********************\n";
	o << c.Name << ' ' << c.Type << ' ' << c.Sizes << "\nInput Pins: " << c.InputPins << "\nOutput Pins: " << c.OutputPins;
	if(c.Type == CellDFF || c.Type == CellLatch) o << "\nSetup: " << c.SetupTiming << "\nHold: " << c.HoldTiming;
	o << "\n********************\n";
	return o;
}

QString ModuleName;
QList<CellClass> Class;
QList<Gate> DAG;
QMap<QString, Wire> Wires;

LookUpTable ParseLUT(QString str){
	QRegExp regex("", Qt::CaseSensitive);
	QList<QString> tlst;
	LookUpTable ret; ret.clear();
	regex.setMinimal(true);
	regex.setPattern("\\s*index_1\\(\"(.*)\"\\);\\s*index_2\\(\"(.*)\"\\);\\s*values\\(\"(.*)\"\\);\\s*");
	regex.indexIn(str);
	//Rows
	for(QString v : regex.capturedTexts()[1].split(", ")){
		ret.rIndex[v.toDouble()] = ret.rows++;
	}
	//Cols
	for(QString v : regex.capturedTexts()[2].split(", "))
		ret.cIndex[v.toDouble()] = ret.cols++;
	//Data
	tlst = regex.capturedTexts()[3].split(", ");
	for(int i = 0, k = 0; i < ret.rows; i++)
		for(int j = 0; j < ret.cols; j++)
			ret.table[i][j] = tlst[k++].toDouble();
	return ret;
}
void ParseLiberty(const char* fpath){
	//ParseNetList("mux_NetList.v");
	QFile outFile("Out"); outFile.open(QFile::WriteOnly); QTextStream fout(&outFile);

	QFile inFile(fpath); inFile.open(QFile::ReadOnly); QTextStream fin(&inFile);
	QRegExp regex("", Qt::CaseSensitive);
	QList<QString> cap;
	QString data = fin.readAll();
	
	//Simplification
	{
		//Remove Comments
		regex.setMinimal(true);
		regex.setPattern("/\\*.*\\*/"); data = data.remove(regex);

		//Handeling Escape Sequences
		regex.setMinimal(false);
		regex.setPattern("\",\\s*\\\\\\s*\""); data = data.replace(regex, ", ");
		regex.setPattern("\\s*\\\\\\s*"); data = data.replace(regex, " ");
		
		//Simplify Information
		regex.setMinimal(true);
		regex.setPattern("ff (.*) "); data = data.replace(regex, "_IsDFF_ ");
		regex.setPattern("latch (.*) "); data = data.replace(regex, "_IsLatch_ ");
		regex.setPattern("timing_type\\s*:\\s*(hold_falling|hold_rising)\\s*;"); data = data.replace(regex, "_HoldConstrains_");
		regex.setPattern("timing_type\\s*:\\s*(setup_falling|setup_rising)\\s*;"); data = data.replace(regex, "_SetupConstrains_");

		//Removing extra info that are hardcoded (For simpler parsing).
		regex.setMinimal(true);
		regex.setPattern("\\s*\\S+_template\\(\\S*_template_\\S*\\) \\{.*\\}"); data = data.remove(regex);
		regex.setPattern("\\(\\S*_template_\\S*\\)"); data = data.remove(regex);
		regex.setPattern("internal_power\\(\\)\\s*\\{.*\\{.*\\}.*\\{.*\\}.*\\}"); data = data.remove(regex);
		regex.setPattern("\\s+pad_cell :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+is_pad :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+drive_current :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+three_state :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+function :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+area.*;"); data = data.remove(regex);
		regex.setPattern("\\s+cell_leakage_power.*;"); data = data.remove(regex);
		regex.setPattern("\\s+timing_sense.*;"); data = data.remove(regex);
		regex.setPattern("\\s+cell_footprint.*;"); data = data.remove(regex);
		regex.setPattern("\\s+min_pulse_width_high :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+min_pulse_width_low :.*;"); data = data.remove(regex);
		regex.setPattern("\\s+capacitance : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+next_state : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+clear : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+preset : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+clear_preset_var1 : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+data_in : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+timing_type : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+when : .*;"); data = data.remove(regex);
		regex.setPattern("\\s+sdf_cond : .*;"); data = data.remove(regex);
		regex.setPattern("\\{\\s*enable :.*;\\s*\\}"); data = data.remove(regex);
		regex.setPattern("\\{\\s*clocked_on :.*;\\s*\\}"); data = data.remove(regex);

		regex.setMinimal(false);
		regex.setPattern("\\s*cell \\(PADFC\\).*$"); data = data.remove(regex);
		regex.setPattern("^.*typical;\\s*"); data = data.remove(regex);
		regex.setPattern("\\s*fall_capacitance : 0;"); data = data.remove(regex);
		regex.setPattern("\\s*rise_capacitance : 0;"); data = data.remove(regex);

		//WhiteSpace Cleanup
		regex.setMinimal(false);
		regex.setPattern("\n\\s*\n"); data = data.replace(regex, "\n");
		regex.setPattern("\\s*\\(\\s*"); data = data.replace(regex, "(");
		regex.setPattern("\\s*\\{"); data = data.replace(regex, "{");
		regex.setPattern("\\s*:\\s*"); data = data.replace(regex, ":");

		fout << data;
	}

	//Extracting data
	regex.setMinimal(false);
	data = data.trimmed(); //data = data.simplified();
	CellClass ct; CellPin pt; TimingTable ttt;
	ttt.clear(2);
	for(QString c : data.split("cell(")) if(c != ""){ ct.clear(); ttt.clear(2);
		//Cell Names
		if(regex.setPattern("^([A-WY-Z1-9]+)X?([1-9])\\)\\{"), regex.indexIn(c) != -1){
			cap = regex.capturedTexts();
			ct.Name = cap[1];
			ct.Sizes[0] = cap[2].toInt();
		}
		else if(regex.setPattern("^([A-Z1-9]+)X([1-9])\\)\\{"), regex.indexIn(c) != -1){
			cap = regex.capturedTexts();
			ct.Name = cap[1];
			ct.Sizes[0] = cap[2].toInt();
		}
		else if(regex.setPattern("^([A-Z1-9]+)\\)\\{"), regex.indexIn(c) != -1){
			cap = regex.capturedTexts();
			ct.Name = cap[1];
			ct.Sizes[0] = 1;
		}
		else{
			qDebug() << c.left(10).simplified() << "\t Unable to parse!";
			continue;
		}
		
		if(ct.Name == "PADINOUT" || ct.Name == "DFFSR") continue;

		//Type
		if(regex.setPattern("\\s+_IsDFF_\\s+"), regex.indexIn(c) != -1) ct.Type = CellDFF;
		else if(regex.setPattern("\\s+_IsLatch_\\s+"), regex.indexIn(c) != -1) ct.Type = CellLatch;
		else ct.Type = CellGate;

		//Setup and hold time
		if(ct.Type == CellDFF || ct.Type == CellLatch){
			regex.setMinimal(true);
			regex.setPattern("\\s+timing\\(\\)\\{.*_HoldConstrains_\\s*rise_constraint\\{(.*)\\}\\s*fall_constraint\\{(.*)\\}\\s*\\}\\s+timing\\(\\)\\{.*_SetupConstrains_\\s*rise_constraint\\{(.*)\\}\\s*fall_constraint\\{(.*)\\}\\s*\\}");
			regex.indexIn(c); cap = regex.capturedTexts(); c.remove(regex);
			ct.HoldTiming.RelatedTo = ct.SetupTiming.RelatedTo = "CLK";
			ct.HoldTiming.tables[0] = ParseLUT(cap[1]);	//Rising
			ct.HoldTiming.tables[1] = ParseLUT(cap[2]);	//Falling
			ct.SetupTiming.tables[0] = ParseLUT(cap[3]);
			ct.SetupTiming.tables[1] = ParseLUT(cap[4]);
		}

		//Pins
		regex.setMinimal(true);
		for(QString p : c.split("pin(")){ pt.clear();
			regex.setPattern("\\s*direction:(input|output);\\s*"); regex.indexIn(p);
			cap = regex.capturedTexts();
			if(cap[0] == "") continue;	//Ignoring first one.

			//Pin Direction
			pt.Dir = DirEnum(DirInput * (cap[1] == "input") + DirOutput * (cap[1] == "output"));
			
			//Pin Name
			regex.setPattern("^\\s*(.*)\\)\\{\\s*"); regex.indexIn(p);
			pt.Name = regex.capturedTexts()[1];

			//Pin Capacitance
			if(pt.Dir == DirOutput){
				regex.setPattern("\\s*max_capacitance:(.*);"); regex.indexIn(p);
				pt.minCap = 0; pt.maxCap = regex.capturedTexts()[1].toDouble();
			}
			else{
				regex.setPattern("\\s*rise_capacitance:(.*);\\s*fall_capacitance:(.*);\\s*"); regex.indexIn(p);
				pt.minCap = min(regex.capturedTexts()[1].toDouble(), regex.capturedTexts()[2].toDouble());
				pt.maxCap = max(regex.capturedTexts()[1].toDouble(), regex.capturedTexts()[2].toDouble());
			}

			//Pin Delays and Slew models
			if(pt.Dir == DirOutput){
				for(QString tim : p.split("timing()")){
					regex.setPattern("\\s*related_pin:\"(.*)\";"); regex.indexIn(tim);
					if(regex.capturedTexts()[0] == "") continue;
					if(ttt.RelatedTo == "EN"&&ct.Name == "TBUF") continue;	//Hotfix for the 2 timings related to pin "EN" in TBuffs
					ttt.RelatedTo = regex.capturedTexts()[1];
					qDebug() << ttt.RelatedTo;
					regex.setPattern("cell_rise\\{(.*)\\}"); regex.indexIn(tim);
					ttt.tables[0] = ParseLUT(regex.capturedTexts()[1]);
					regex.setPattern("cell_fall\\{(.*)\\}"); regex.indexIn(tim);
					ttt.tables[1] = ParseLUT(regex.capturedTexts()[1]);
					pt.DelayTable.push_back(ttt);

					regex.setPattern("rise_transition\\{(.*)\\}"); regex.indexIn(tim);
					ttt.tables[0] = ParseLUT(regex.capturedTexts()[1]);
					regex.setPattern("fall_transition\\{(.*)\\}"); regex.indexIn(tim);
					ttt.tables[1] = ParseLUT(regex.capturedTexts()[1]);
					pt.SlewTable.push_back(ttt);
				}
			}

			//Pushing Pin
			if(pt.Dir == DirInput) ct.InputPins[0].push_back(pt);
			else if(pt.Dir == DirOutput) ct.OutputPins[0].push_back(pt);
		}
		//qDebug() << ct;
		
		//Add To List of Cell Classes
		bool NewFlag = true;
		for(CellClass& cc : Class) if(cc.Name == ct.Name){
			cc.Sizes.push_back(ct.Sizes[0]);
			cc.InputPins.push_back(ct.InputPins[0]);
			cc.OutputPins.push_back(ct.OutputPins[0]);
			NewFlag = false;
		}
		if(NewFlag) Class.push_back(ct);
	}
}
void ParseNetList(const char* fpath){
	QFile inFile(fpath); inFile.open(QFile::ReadOnly); QTextStream fin(&inFile);
	QRegExp regex("", Qt::CaseSensitive); regex.setMinimal(true);
	QList<QString> cap;
	QString data = fin.readAll();

	//Simplification
	{
		//Removing Comments and /$
		regex.setPattern("//.*\n"); data = data.remove(regex);
		regex.setPattern("\\(\\*.*\\*\\)\\n"); data = data.remove(regex);
		regex.setPattern("/\\*.*\\*/"); data = data.remove(regex);
		regex.setPattern("\\\\\\$"); data = data.remove(regex);
	}

	//Assuming only one module for now
	data = data.trimmed(); data = data.simplified();
	QList<QString> lines = data.split(";");

	int i = 0;
	Wire wt; Gate gt; Pin pt;
	regex.setMinimal(false);
	
	regex.setPattern("module\\s+(\\S*)\\(.*\\)");	//Parsing Module Name
	regex.indexIn(lines[i]);
	cap = regex.capturedTexts();
	ModuleName = cap[1];
	i++;

	//Parsing Wires
	regex.setPattern("(wire|input|output)\\s+(?:\\[(\\d+)\\:(\\d+)\\])?\\s*(\\S+)");
	while(regex.indexIn(lines[i]) != -1){
		cap = regex.capturedTexts();
		for(int s = cap[2].toInt(); s >= cap[3].toInt(); s--){
			wt.Name = (cap[2] == "") ? cap[4] : (cap[4] + "[" + QString::number(s) + "]");
			Wires[wt.Name] = wt;
			if(cap[1] == "input" || cap[1] == "output"){
				pt.Name = "Port";
				pt.Dir = (cap[1] == "input") ? DirOutput : DirInput;
				pt.WireList = gt.Name = wt.Name;
				gt.Type = (cap[1] == "input") ? "InputPort" : "OutputPort";
				DAG.push_back(gt);
				DAG.last().Pins.push_back(pt);
				Wires[wt.Name].GateList.push_back(PinIndex(DAG.size() - 1, 0));
			}
		}
		i++;
	}
	//Parsing Gates
	regex.setPattern("(\\S+)\\s+(\\S+)\\s*\\((.*)\\)");
	while(regex.indexIn(lines[i]) != -1){
		cap = regex.capturedTexts();
		QRegExp Param("\\.(\\S+)\\((\\S+)\\)", Qt::CaseSensitive);
		gt.Name = cap[2];
		gt.Type = cap[1];
		DAG.push_back(gt);
		for (QString p : cap[3].trimmed().split(QRegExp("\\s*,\\s*"))){
			Param.indexIn(p);
			pt.Name = Param.capturedTexts()[1];
			pt.Dir = DirUnknown;
			pt.WireList = Param.capturedTexts()[2];
			DAG.last().Pins.push_back(pt);
			Wires[pt.WireList].GateList.push_back(PinIndex(DAG.size() - 1, DAG.last().Pins.size() - 1));
		}
		i++;	
	}
	//Parsing Assigns
	regex.setPattern("assign(?:\\s+)(\\S+)(?:\\s*)=(?:\\s*)(\\S+)");
	while(regex.indexIn(lines[i]) != -1){
		cap = regex.capturedTexts();
		Wires[cap[1]].GateList.append(Wires[cap[2]].GateList); Wires[cap[1]].GateList = Wires[cap[1]].GateList.toSet().toList();
		Wires[cap[2]].GateList.append(Wires[cap[1]].GateList); Wires[cap[2]].GateList = Wires[cap[2]].GateList.toSet().toList();
		i++;
	}
	qDebug() << DAG;
	qDebug() << Wires;
}
int main(){
	ParseLiberty("Liberty.lib");
}