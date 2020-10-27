import serial
import sys

def enviar(coso, x, y):
    coso.flushOutput()
    try:
        coso.write(bytes.fromhex(x)) 
        coso.write(bytes.fromhex(y))
        return
    except:
        coso.write(bytes.fromhex('00'))
        coso.write(bytes.fromhex('00'))
        return

def recibir(coso):
    enviado = ''
    junto = []
    coso.flushInput()
    coso.flushOutput()
    try:
        coso.readline()
        for i in range(4):
            dato = coso.read()
            junto.append(dato)
        eje_x = str(int(ord(junto[0])))
        eje_y = str(int(ord(junto[2])))
        enviado = eje_x + ',' + eje_y
        return enviado
    except:
        enviado = '00,00'
        return  enviado
