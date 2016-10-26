// Sound.c
// This module contains the SysTick ISR that plays sound
// Runs on LM4F120 or TM4C123
// Program written by: put your names here
// Date Created: 8/25/2014 
// Last Modified: 3/6/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "dac.h"
#include "tm4c123gh6pm.h"
#include "Timer1.h"
#include "Sound.h"
void Timer1A_Start(void);
void Timer1A_Stop(void);
void Sounder(void);
// **************Sound_Init*********************
// Initialize Systick periodic interrupts
// Called once, with sound initially off
// Input: interrupt period
//           Units to be determined by YOU
//           Maximum to be determined by YOU
//           Minimum to be determined by YOU
// Output: none
//const uint8_t SineWave[32] = {8, 9, 11, 12, 13, 14, 14, 15, 15, 15, 14, 14, 13, 12, 11, 9, 8, 7, 5, 4, 3, 2, 2, 1, 1, 1, 2, 2, 3, 4, 5, 7};

uint32_t Index;

void Sound_Init(uint32_t period){
	DAC_Init();          // Port B is DAC
  Index = 0;
	Timer1_Init(Sounder, period);
}


// **************Sound_Play*********************
// Start sound output, and set Systick interrupt period 
// Input: interrupt period
//           Units to be determined by YOU
//           Maximum to be determined by YOU
//           Minimum to be determined by YOU
//         input of zero disable sound output
// Output: none
void Sound_Play(uint32_t period){
	TIMER1_TAILR_R = period-1;
	if(period == 0)
		DAC_Out(0);
}

void Array_Play(unsigned char *pt, uint32_t count)
{
	Timer1A_Start();
	wav = pt;
	//Timer1A_Stop();
}

void Sounder(void){
  DAC_Out(wav[Index]);
	Index++;
	if(Index > play_count-1){
		Index = 0;
		Timer1A_Stop();
	}
}


