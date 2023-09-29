#include <stdlib.h>
#include <stdint.h>

extern void print_serial(uint8_t * str);

// Entry function in EL2 from El3
extern void enter_el2();

extern uint64_t _ttb_1_base;

extern void init_gic_cpu_interface(); 

extern void generate_sgi_interrupt(uint8_t affinity1, uint8_t affinity2, uint8_t affinity3, uint16_t target, uint8_t INTID);

extern void enable_timer_interrupt(uint32_t tval);

extern uint8_t ack_timer();

// GIC configurations
//**********************
// Register definitions 
//
typedef struct {
   volatile uint32_t                         LOWER;
   volatile uint32_t                         UPPER;
} gic_d_irouter;

typedef struct {
   volatile uint32_t                         CTLR;
   volatile uint32_t                         TYPER;
   volatile uint32_t                         IIDR;
   volatile uint8_t                          Rsvd0[4];
   volatile uint32_t                         STATUSR;
   volatile uint8_t                          Rsvd1[44];
   volatile uint32_t                         SETSPI_NSR;
   volatile uint8_t                          Rsvd2[4];
   volatile uint32_t                         CLRSPI_NSR;
   volatile uint8_t                          Rsvd3[4];
   volatile uint32_t                         SETSPI_SR;
   volatile uint8_t                          Rsvd4[4];
   volatile uint32_t                         CLRSPI_SR;
   volatile uint8_t                          Rsvd5[36];
   volatile uint32_t                         IGROUPR_SGI_PPI;
   volatile uint32_t                         IGROUPR_SPI[30];
   volatile uint8_t                          Rsvd6[4];
   volatile uint32_t                         ISENABLER_SGI_PPI;
   volatile uint32_t                         ISENABLER_SPI[30];
   volatile uint8_t                          Rsvd7[4];
   volatile uint32_t                         ICENABLER_SGI_PPI;
   volatile uint32_t                         ICENABLER_SPI[30];
   volatile uint8_t                          Rsvd8[4];
   volatile uint32_t                         ISPENDR_SGI_PPI;
   volatile uint32_t                         ISPENDR_SPI[30];
   volatile uint8_t                          Rsvd9[4];
   volatile uint32_t                         ICPENDR_SGI_PPI;
   volatile uint32_t                         ICPENDR_SPI[30];
   volatile uint8_t                          Rsvd10[4];
   volatile uint32_t                         ISACTIVER_SGI_PPI;
   volatile uint32_t                         ISACTIVER_SPI[30];
   volatile uint8_t                          Rsvd11[4];
   volatile uint32_t                         ICACTIVER_SGI_PPI;
   volatile uint32_t                         ICACTIVER_SPI[30];
   volatile uint8_t                          Rsvd12[4];
   volatile uint32_t                         IPRIORITYR_SGI_PPI[8];
   volatile uint32_t                         IPRIORITYR_SPI[240];
   volatile uint8_t                          Rsvd13[32];
   volatile uint32_t                         ITARGETSR_SGI_PPI[8];
   volatile uint32_t                         ITARGETSR_SPI[240];
   volatile uint8_t                          Rsvd14[32];
   volatile uint32_t                         ICFGR_SGI_PPI[2];
   volatile uint32_t                         ICFGR_SPI[60];
   volatile uint8_t                          Rsvd15[8];
   volatile uint32_t                         IGRPMODR_SGI_PPI;
   volatile uint32_t                         IGRPMODR_SPI[30];
   volatile uint8_t                          Rsvd16[132];
   volatile uint32_t                         NSACR[62];
   volatile uint8_t                          Rsvd17[8];
   volatile uint32_t                         SGIR;
   volatile uint8_t                          Rsvd18[12];
   volatile uint32_t                         CPENDSGIR[4];
   volatile uint32_t                         SPENDSGIR[4];
   volatile uint8_t                          Rsvd19[20944];
   gic_d_irouter               				 IROUTER[960];
   volatile uint8_t                          Rsvd20[16640];
   volatile uint32_t                         ESTATUSR;
   volatile uint32_t                         ERRTESTR;
   volatile uint8_t                          Rsvd21[124];
   volatile uint32_t                         SPISR[30];
   volatile uint8_t                          Rsvd22[16084];
   volatile uint32_t                         PIDR4;
   volatile uint32_t                         PIDR5;
   volatile uint32_t                         PIDR6;
   volatile uint32_t                         PIDR7;
   volatile uint32_t                         PIDR0;
   volatile uint32_t                         PIDR1;
   volatile uint32_t                         PIDR2;
   volatile uint32_t                         PIDR3;
   volatile uint32_t                         CIDR0;
   volatile uint32_t                         CIDR1;
   volatile uint32_t                         CIDR2;
   volatile uint32_t                         CIDR3;
} gic_distributor;


/**************************************************************************
* Hardware Region  : GICR
**************************************************************************/

/**************************************************************************
* Register Overlay Structure
**************************************************************************/

typedef struct {
   volatile uint32_t                         CTLR;
   volatile uint32_t                         IIDR;
   volatile uint32_t                         TYPER_LOWER;
   volatile uint32_t                         TYPER_UPPER;
   volatile uint32_t                         STATUSR;
   volatile uint32_t                         WAKER;
   volatile uint8_t                          Rsvd0[40];
   volatile uint32_t                         SETLPIR_LOWER;
   volatile uint32_t                         SETLPIR_UPPER;
   volatile uint32_t                         CLRLPIR_LOWER;
   volatile uint32_t                         CLRLPIR_UPPER;
   volatile uint8_t                          Rsvd1[32];
   volatile uint32_t                         PROPBASER_LOWER;
   volatile uint32_t                         PROPBASER_UPPER;
   volatile uint32_t                         PENDBASER_LOWER;
   volatile uint32_t                         PENDBASER_UPPER;
   volatile uint8_t                          Rsvd2[32];
   volatile uint32_t                         INVLPIR_LOWER;
   volatile uint32_t                         INVLPIR_UPPER;
   volatile uint8_t                          Rsvd3[8];
   volatile uint32_t                         INVALLR_LOWER;
   volatile uint32_t                         INVALLR_UPPER;
   volatile uint8_t                          Rsvd4[8];
   volatile uint32_t                         SYNCR;
   volatile uint8_t                          Rsvd5[65292];
   volatile uint32_t                         PIDR4;
   volatile uint32_t                         PIDR5;
   volatile uint32_t                         PIDR6;
   volatile uint32_t                         PIDR7;
   volatile uint32_t                         PIDR0;
   volatile uint32_t                         PIDR1;
   volatile uint32_t                         PIDR2;
   volatile uint32_t                         PIDR3;
   volatile uint32_t                         CIDR0;
   volatile uint32_t                         CIDR1;
   volatile uint32_t                         CIDR2;
   volatile uint32_t                         CIDR3;
} gic_redistributor_control;


typedef struct {
   volatile uint8_t                          Rsvd0[128];
   volatile uint32_t                         IGROUPR_SGI_PPI;
   volatile uint8_t                          Rsvd1[124];
   volatile uint32_t                         ISENABLER0;
   volatile uint8_t                          Rsvd2[124];
   volatile uint32_t                         ICENABLER0;
   volatile uint8_t                          Rsvd3[124];
   volatile uint32_t                         ISPENDR0;
   volatile uint8_t                          Rsvd4[124];
   volatile uint32_t                         ICPENDR0;
   volatile uint8_t                          Rsvd5[124];
   volatile uint32_t                         ISACTIVER0;
   volatile uint8_t                          Rsvd6[124];
   volatile uint32_t                         ICACTIVER0;
   volatile uint8_t                          Rsvd7[124];
   volatile uint32_t                         IPRIORITYR[8];
   volatile uint8_t                          Rsvd8[2016];
   volatile uint32_t                         ICFGR0;
   volatile uint32_t                         ICFGR1;
   volatile uint8_t                          Rsvd9[248];
   volatile uint32_t                         IGRPMODR_SGI_PPI;
   volatile uint8_t                          Rsvd10[252];
   volatile uint32_t                         NSACR;
   volatile uint8_t                          Rsvd11[45564];
   volatile uint32_t                         MISCSTATUSR;
   volatile uint8_t                          Rsvd12[124];
   volatile uint32_t                         PPISR;
   volatile uint8_t                          Rsvd13[16252];
} gic_redistributor_sgi_ppi;

typedef struct {
		gic_redistributor_control          CONTROL;
        gic_redistributor_sgi_ppi          SGI_PPI;
} gic_redistributor;

void gic_init(){
		volatile uint32_t local_var = 0; 

		// Configure Distributer  (SPIs)
		//	Pointer to Distributor MMR space
		gic_distributor * gic_distributor_ptr = (gic_distributor *) 0x08000000;

		/* Enable Affinity rounting for both secure and non-secure
		 * Enable interrupts from all groups: grp0, grp1_secure, grp1_ns
		 * */
		local_var = gic_distributor_ptr->IIDR;  // Just for information
		gic_distributor_ptr->CTLR |= (0x3 << 4U); // ARE_NS and ARE_S bits set (Affinity enable)
		gic_distributor_ptr->CTLR |= 0x7U; /* enable all groups*/ 
												  
		
		// Configure Redistributer  (PPIs and SGIs)
		// Pointer to Re Distributor MMR space
		gic_redistributor * gic_redistributor_ptr = (gic_redistributor *) 0x080A0000;

		/* Configure WAKER to mark PE as awake */
		gic_redistributor_ptr->CONTROL.WAKER &= 0x5U;
		local_var = (gic_redistributor_ptr->CONTROL.WAKER >> 2) & 0x1;
		while (local_var != 0)
		{
				local_var = (gic_redistributor_ptr->CONTROL.WAKER >> 2) & 0x1;
		}
		// We configure SGI0 as secure group 0 interrupt 
		// GROUP setting
		gic_redistributor_ptr->SGI_PPI.IGROUPR_SGI_PPI &= ~(1<<0);
		gic_redistributor_ptr->SGI_PPI.IGROUPR_SGI_PPI &= ~(1<<30); // PPI TIMER interrupt

		// Priority settings for SGI0 : give highest priority
		gic_redistributor_ptr->SGI_PPI.IPRIORITYR[0] &=  0x0;
		gic_redistributor_ptr->SGI_PPI.IPRIORITYR[7] &=  0x0U; // Highest priority to PPI 30(TIMER)

		// Edge-level triggered: SGI edge triggered 0b10
		gic_redistributor_ptr->SGI_PPI.ICFGR0 |=  0b10;
		gic_redistributor_ptr->SGI_PPI.ICFGR1 |=  0b00; // PPI 30 is level-sensitive

		// Enable SGI 0 in redistributor
		gic_redistributor_ptr->SGI_PPI.ISENABLER0  |= 0x1;
		gic_redistributor_ptr->SGI_PPI.ISENABLER0  |= (1<<30); // PPI 30 TIMER enable
		
		// Configure CPU interface (using System Registers)
		init_gic_cpu_interface();

}



//**********************

// translation table 2 with 512 , 2 MB blocks
uint64_t _ttb_2_base[512] __attribute__(( aligned (0x1000) ));

void init_l2_table(){
		// initiliza all 2MB blocks in L2 table 
		// Add address of table 2 ino 3rd entry of  table 1 
		int i; 
		uint64_t *ttb_1 = (uint64_t *)&_ttb_1_base;
		uint64_t ttb_2_base_addr = (uint64_t) &_ttb_2_base[0];
		*(ttb_1 + 3) = (ttb_2_base_addr & 0xFFFFF000) | 0x3;  // point to L2 table is is table entry 
		
		// iterate and fill all 2 MB blocks 
		for (i=0; i< 512; i++)
		{
				_ttb_2_base[i] = (0x741) | (0x40000000 + i*2*1024*1024);
		}
}

gic_redistributor * gic_redistributor_ptr = (gic_redistributor *) 0x080A0000;

void main_el3(){

		volatile uint32_t main_var_el3 = 20; 
		print_serial("###########");
		print_serial("Starting Cortex A in EL3 exception Level \n");
		print_serial("Connect debugger and set main_var_el3 = 0 to continue ... \n");
		while (main_var_el3 != 0)
		{
		; 
		}
		
		// configure GIC to control asynchronous interrupts
		gic_init();

		// generate SGI interrupt ID=0
		generate_sgi_interrupt(0x0, 0x0, 0x0, 0x1, 0x0);
		enable_timer_interrupt(0x100);

		// Generate synchonous exception and go to EL2
		enter_el2();

}

/* SMC call handeler in EL3 */
void el3_smc_handler(uint64_t smccall_number){

		switch (smccall_number){
				case 1:
						print_serial("[EL3] Entered in EL3 with SMC call number: 1 \n");
						break; 
				case 2: 
						print_serial("[EL3] Entered in EL3 with SMC call number: 2 \n");
						break;
				default:
						print_serial("[EL3] Entered in EL3 but SMC call is not implemented \n");
						break;
		}
}

void el3_fiq_handler(uint32_t INTID){
		// handle FIQ 
		// Determine wich exception came
		if (INTID <16){
				print_serial("[EL3] SGI interrupt is triggered ... \n");
		}
		else
		{
				print_serial("[EL3] PPI (TIMER) interrupt is triggered ... \n");
				// ACK timer
				ack_timer();
		}
}

