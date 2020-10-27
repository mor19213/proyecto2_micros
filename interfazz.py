from dibujoo import *
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import threading
import serial
import sys
import puerto_serial as ps


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
    pass

aplication = QtWidgets.QApplication([])
ventanamain=dibujito()
ventanamain.show()
aplication.exec_()

