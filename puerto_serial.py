import serial
import sys

def enviar(coso, x, y):
    coso.flushOutput()
    var1 = hex(ord('0'))[2:]
    var2 = hex(ord(x[0]))[2:]
    try:
        variable = x[1]
        x1 = hex(ord(x[0]))[2:]
        x2 = hex(ord(x[1]))[2:]
        coso.write(bytes.fromhex(x1))
        coso.write(bytes.fromhex(x2))
    except:
        coso.write(bytes.fromhex(var1))
        coso.write(bytes.fromhex(var2))
    coso.write(bytes.fromhex('2C'))
    try: 
        variable = y[1]
        y1 = hex(ord(y[0]))[2:]
        y2 = hex(ord(y[1]))[2:]
        coso.write(bytes.fromhex(y1))
        coso.write(bytes.fromhex(y2))
    except:        
        coso.write(bytes.fromhex(var1))
        coso.write(bytes.fromhex(var2))
    coso.write(bytes.fromhex('0A'))
    return

def recibir(coso):
    coso.flushInput()
    coso.flushOutput()
    try:
        coso.readline()
        recibido = str(coso.readline()).split(',')
        recibido[0] = int(recibido[0][2:], 16)
        recibido[1] = int(recibido[1][:2], 16)
        return recibido
    except:
        pass
'''
ser = serial.Serial(port="COM3",baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
while 1:
    print(recibir(ser))
'''
