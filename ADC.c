// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Student names: Hans Xu, Pranav Harathi
// Last modification date: 4/19/2016
// Last Modified: 4/19/2016 

#include <stdint.h>
#include "tm4c123gh6pm.h"

// ADC initialization function 
// Input: none
// Output: none
void ADC_Init(void){ volatile int delay;
	SYSCTL_RCGCGPIO_R |= 0x08;
	delay = SYSCTL_RCGCGPIO_R;
	GPIO_PORTD_DIR_R &= ~0x04; // PD2 input
	GPIO_PORTD_AFSEL_R |= 0x04; // set AFSEL
	GPIO_PORTD_DEN_R &= ~0x04; // disable digital
	GPIO_PORTD_AMSEL_R |= 0x04; // set analog
	SYSCTL_RCGCADC_R |= 0x01; // activate ADC0
	delay = SYSCTL_RCGCADC_R;
	delay = SYSCTL_RCGCADC_R;
	delay = SYSCTL_RCGCADC_R;
	delay = SYSCTL_RCGCADC_R;
	ADC0_PC_R |= 0x01; // 125KHz conversion speed
	ADC0_SSPRI_R = 0x0123; //set priority order: 3 is highest
	ADC0_ACTSS_R &= ~0x08; // clear bit 3 
	ADC0_EMUX_R &= ~0xF000; // seq3 is the software trigger
	ADC0_SSMUX3_R = (ADC0_SSMUX3_R&0xFFFFFFF0)+5; //Ain5
	ADC0_SSCTL3_R = 0x006; 
	ADC0_IM_R &= ~0x0008;
	ADC0_ACTSS_R |= 0x0008; //enable sample sequencer 3
}

//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
uint32_t ADC_In(void){  
	uint32_t data = 0;	
  ADC0_PSSI_R = 0x08;	
  while((ADC0_RIS_R&0x08) == 0){};
	data = ADC0_SSFIFO3_R&0xFFF;
  ADC0_ISC_R = 0x0008;		
  return data; 
}


