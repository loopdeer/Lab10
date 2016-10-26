// Game physics

#include <stdint.h>
#include "tm4c123gh6pm.h"

unsigned int unsignedmin(unsigned int first, unsigned int second);
unsigned int unsignedmax(unsigned int first, unsigned int second);
int intersecting(unsigned int x1, unsigned int y1, unsigned int h1, unsigned int w1, unsigned int x2, unsigned int y2, unsigned int h2, unsigned int w2);


unsigned int unsignedmin(unsigned int first, unsigned int second) {
	return first <= second ? first : second;
}

unsigned int unsignedmax(unsigned int first, unsigned int second) {
	return first > second ? first : second;
}

// x1, etc. are for the player, and x2 is for the rock (obstacle)
int intersecting(unsigned int x1, unsigned int y1, unsigned int h1, unsigned int w1, unsigned int x2, unsigned int y2, unsigned int h2, unsigned int w2) {
/*	unsigned int leftx = unsignedmin(x1, x2); old physics
	unsigned int width;
	if(leftx == x1) width = w1;
	else width = w2;
	unsigned int rightx = unsignedmax(x1, x2);
	unsigned int bottomy = unsignedmin(y1, y2);
	unsigned int topy = unsignedmax(y1, y2);
	unsigned int height;
	if(bottomy == y1) height = h1;
	else height = h2;
	if(rightx >= leftx && rightx <= leftx+width) {
		if(topy >= bottomy && topy <= bottomy+height) {
			return 1;
		}
	}
	return 0;*/
	//new simplified physics (this probably has some case that is wrong so let's addrress this later)
	return ((y2 - h2) < y1 && (x1 + w1) > x2);
}
