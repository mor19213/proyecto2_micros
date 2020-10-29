from dibujoo import *
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import serial
import threading
import puerto_serial as ps
import sys
x =80
y =80


class dibujito (QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__ (self):
        super().__init__()
        self.setupUi(self)
        self.mapa = QPixmap(700, 700)
        self.mapa.fill(QColor('WHITE'))
        self.label.setPixmap(self.mapa)
        self.painter = QPainter(self.label.pixmap())
        pen = QPen()
        pen.setWidth(3)
        pen.setColor(QColor('#7584F3'))
        self.painter.setRenderHint(QPainter.Antialiasing)
        self.painter.setPen(pen)
        cordenada = threading.Thread(daemon=True,target=union_puntos)
        cordenada.start()
        self.pushButton.clicked.connect(self.apachado)

    def paint (self,suma_x,suma_y):
        global x,y
        try:
            self.painter.drawLine(x, y, x+suma_x , y+suma_y)
            self.update()
            x=suma_x+x
            if x<10:
                x= 700
            elif x >= 700:
                x=10
            y=y+suma_y
            if y<10:
                y= 700
            elif y >= 700:
                y=10
        except:
            print('error pintar')

    def apachado(self):
        self.painter.eraseRect(0,0,700,700)

def union_puntos ():
    global puntox,puntoy,ventanamain
    ser = serial.Serial(port="COM3",baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
    
    while (1) :       
        try :
            punto = ps.recibir(ser)
            puntoy = 5*(punto[1])//13
            puntox = 5*(punto[0])//13
            suma_x=0
            suma_y=0
            
            if puntox >=50:
                suma_x=1*(puntox-50)
            elif puntox <=40:
                suma_x=-1*(40-puntox)
            else:
                suma_x=0
                
            if puntoy >=50:
                suma_y=1*(puntoy-50)
            elif puntoy <=40:
                
                suma_y=-1*(40-puntoy)
            else:
                suma_y=0

            ps.enviar(ser, str(99*x//700), str(99*y//700))
            ventanamain.paint(suma_x,suma_y)
            print(99*x//700,99*y//700)
        except:
            pass
        
aplication = QtWidgets.QApplication([])
ventanamain=dibujito()
ventanamain.show()
aplication.exec_()

