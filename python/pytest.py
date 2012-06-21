#!/usr/bin/python2.7


class Getch:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch

get = Getch()
while True:
    print "Keep trace? 'y' for yes, 'n' for no, 'r' for redo: "
    inp = get()
    if inp == "q":
        print "exiting"
        exit()
    print "you entered " + inp

