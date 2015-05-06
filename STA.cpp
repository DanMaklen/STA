#include <iostream>
#include <QString>
#include <QDebug>
#include <QRegExp>
#include <QFile>
#include <QTextStream>
#include <QList>
#include <QMap>
using namespace std;
enum DirEnum{DirUnknown = 0, DirInput = 1, DirOutput = 2, DirInOut = 3};
class Pin{
public:
	QString Name;
	DirEnum Dir;
	QString WireList;
	QList<int> GateList;
};
QDebug& operator<<(QDebug& o, const Pin& p){
	o << p.Name << ";" << p.WireList << ";" << p.GateList;
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
class Wire{
public:
	QString Name;
	QList<int> GateList;
};
QDebug& operator<<(QDebug& o, const Wire& w){
	o << w.Name << "; " << w.GateList << "\n";
	return o;
}

QString ModuleName;
QList<Gate> DAG;
QMap<QString, Wire> Wires;

void ParseNetList(){
	//QFile inFile("mux_NetList.v");
	QFile inFile("Test.v");
	inFile.open(QFile::ReadOnly);
	QTextStream fin(&inFile);
	QRegExp regex("", Qt::CaseSensitive); regex.setMinimal(true);
	QList<QString> cap;
	QString data = fin.readAll();

	//Removing Comments and /$
	regex.setPattern("//.*\n"); data = data.remove(regex);
	regex.setPattern("\\(\\*.*\\*\\)\\n"); data = data.remove(regex);
	regex.setPattern("/\\*.*\\*/"); data = data.remove(regex);
	regex.setPattern("\\\\\\$"); data = data.remove(regex);

	//Assuming only one module for now
	data = data.trimmed(); data = data.simplified();
	QList<QString> lines = data.split(";");

	int i = 0;
	regex.setMinimal(false);
	
	regex.setPattern("module\\s+(\\S*)\\(.*\\)");	//Parsing Module Name
	regex.indexIn(lines[i]);
	cap = regex.capturedTexts();
	ModuleName = cap[1];
	i++;

	//Parsing Wires
	regex.setPattern("(wire|input|output)\\s+(?:\\[(\\d+)\\:(\\d+)\\])?\\s*(\\S+)");
	Wire wt; Gate gt; Pin pt;
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
				Wires[wt.Name].GateList.push_back(DAG.size());
				DAG.push_back(gt);
			}
		}
		i++;
	}
	
	//Parsing Gates
	regex.setPattern("(\\S+)\\s+(\\S+)\\s*\\((.*)\\)");
	while(regex.indexIn(lines[i]) != -1){
		cap = regex.capturedTexts();
		//qDebug() << cap;
		QRegExp Param("\\.(\\S+)\\((\\S+)\\)", Qt::CaseSensitive);
		gt.Name = cap[2];
		gt.Type = cap[1];
		for (QString p : cap[3].trimmed().split(QRegExp("\\s*,\\s*"))){
			Param.indexIn(p);
			pt.Name = Param.capturedTexts()[1];
			pt.Dir = DirUnknown;
			pt.WireList = Param.capturedTexts()[2];

			Wires[pt.WireList].GateList.push_back(DAG.size());
			qDebug() << p;
		}
		/*
		Gate:
		QString Name;
		QString Type;
		QList<Pin> Pins;
		Pin:
		QString Name;
		DirEnum Dir;
		QString WireList;
		QList<int> GateList;
		Wire:
		QString Name;
		QList<int> GateList;
		*/
		i++;	
	}
}

int main(){
	QFile outFile("Out"); outFile.open(QFile::WriteOnly); QTextStream fout(&outFile);
	ParseNetList();

}