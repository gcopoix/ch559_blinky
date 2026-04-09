#include <compiler.h>
#include "CH559.h"
#include "delay.h"


SBIT(LED4, 0x90, 4); // accessing LED at pin 1.4
SBIT(LED5, 0x90, 5); // accessing LED at pin 1.5



void main() {
	PORT_CFG = 0b00101101;
	P1_DIR = 0b11110000;
	P1 = 0x00;

	while (1) {
		delay(120000UL);
		LED4 = LED5;
		LED5 = !LED5;
	}
}
