// Header file for Physics.c

#include <stdint.h>

// Returns unsigned minimum int
unsigned int unsignedmin(unsigned int first, unsigned int second);

// Returns unsigned maximum int
unsigned int unsignedmax(unsigned int first, unsigned int second);

// returns 1 if two rectangles intersect
int intersecting(unsigned int x1, unsigned int y1, unsigned int h1, unsigned int w1, unsigned int x2, unsigned int y2, unsigned int h2, unsigned int w2);

