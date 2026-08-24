# Prowork
import pyautogui
import time
import threading

pyautogui.FAILSAFE = False

running = True

def jiggle():
    while running:
        x, y = pyautogui.position()
        pyautogui.moveRel(2, 0, duration=0.1)
        pyautogui.moveRel(-2, 0, duration=0.1)
        time.sleep(30)  # espera 30 segundos entre cada movimiento

def wait_for_stop():
    global running
    input("Pulsa ENTER para detener el mouse jiggler...\n")
    running = False

print("Mouse Jiggler iniciado. Pulsa ENTER para detener.")
t = threading.Thread(target=jiggle, daemon=True)
t.start()
wait_for_stop()
print("Mouse Jiggler detenido.")
