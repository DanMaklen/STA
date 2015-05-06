#include <iostream>
#include <QString>
#include <QDebug>
#include <QRegExp>
#include <QFile>
#include <QTextStream>
#include <QList>
#include <QMap>
using namespace std;
enum DirEnum{Unknown = 0, Input = 1, Output = 2, InOut = 3};
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
	o << "Gate " << g.Name << "(" << g.Type << ")" << "{";
	o << '\t' << "Pins{";
	o << g.Pins;
	o << "\t}\n}";
	return o;
}
class Wire{
public:
	QString Name;
	QList<int> GateList;
};
QDebug& operator<<(QDebug& o, const Wire& w){
	o << w.Name << "; " << w.GateList;
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

	//Removing Comments
	regex.setPattern("//.*\n"); data = data.remove(regex);
	regex.setPattern("\\(\\*.*\\*\\)\\n"); data = data.remove(regex);
	regex.setPattern("/\\*.*\\*/"); data = data.remove(regex);
	//Remove "/$"
	regex.setPattern("\\\\\\$"); data = data.remove(regex);
	//Remove leading and trailing whitespace

	//qDebug() << data; //data = data.simplified();
	
	//Assuming only one module for now
	data = data.trimmed(); data = data.simplified();
	QList<QString> lines = data.split(";");
	//qDebug() << lines;

	int i = 0;
	regex.setMinimal(false);
	
	regex.setPattern("module\\s+(\\S*)\\(.*\\)");	//Module Name
	regex.indexIn(lines[i]);
	cap = regex.capturedTexts();
	ModuleName = cap[1];
	i++;
	//qDebug() << ModuleName;

	regex.setPattern("(wire|input|output)\\s+(?:\\[(\\d+)\\:(\\d+)\\])?\\s*(\\S+)");
	qDebug() << lines[i];
	while(regex.indexIn(lines[i]) != -1){
		cap = regex.capturedTexts();
		qDebug() << cap;
		i++;
	}
	//while()
	
	
}

int main(){
	QFile outFile("Out"); outFile.open(QFile::WriteOnly); QTextStream fout(&outFile);
	ParseNetList();

}