#include "delay.h"

void delay(uint32_t count) {
	for (uint32_t i = 0; i < count; i++) {
		__asm__("nop");
	}
}
