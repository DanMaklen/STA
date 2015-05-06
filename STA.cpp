#include <iostream>
#include <QString>
#include <QDebug>
#include <QRegExp>
#include <QFile>
#include <QTextStream>
#include <QVector>
#include <map>
using namespace std;
enum DirEnum{Unknown = 0, Input = 1, Output = 2, InOut = 3};
class Pin{
public:
	QString Name;
	DirEnum Dir;
	QVector<QString> WireList;
	QVector<int> GateList;
};
QDebug& operator<<(QDebug& o, const Pin& p){
	return o << p.Name << QString(";") << p.WireList << QString(";") << p.GateList;
}

class Gate{
public:
	QString Name;
	QString Type;
	QVector<Pin> Pins;
	bool operator<(const Gate& g){
		return Name < g.Name;
	}
}
QDebug& operator<<(QDebug& o, const Gate& g){
	o << "Gate " << g.Name << "(" << Type << ")" << "{";
	o << '\t' << "Pins{";
	o << g.Pins;
	o << "\t}\n}";
	return o;
}

class Wire{
	QString Name;
	QVector<int> GateList;
};

QVector<Gate> DAG;
QVector<Wire> Wires;

void ParseNetList(){
	QFile inFile("mux_NetList.v");
	inFile.open(QFile::ReadOnly);
	QTextStream fin(&inFile);
	QRegExp regex("", Qt::CaseSensitive); regex.setMinimal(true);	
	QString data = fin.readAll();

	//Removing Comments
	regex.setPattern("//.*\n"); data = data.remove(regex);
	regex.setPattern("\\(\\*.*\\*\\)\\n"); data = data.remove(regex);
	regex.setPattern("/\\*.*\\*/"); data = data.remove(regex);
	//Remove "/$"
	regex.setPattern("\\\\\\$"); data = data.remove(regex);
	//Remove leading and trailing whitespace

	data = data.trimmed();
	qDebug() << data;
	//data = data.simplified();
	
	//Assuming only one module for now
	QVector<QString> lines = data.split(";");
	qDebug() << data;
}

int main(){
	QFile outFile("Out"); outFile.open(QFile::WriteOnly); QTextStream fout(&outFile);
	ParseNetList();

}