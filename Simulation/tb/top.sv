/***************************************************************************************************************************
*
*    File Name:  top.sv
*      Version:  1.0
*        Model:  CPU Clock
*
* Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 0.1    TJs       03/08/18    Design
* 0.2    TJs 	   03/17/18    Code Freeze
*****************************************************************************************************************************/

`timescale 1ps/1ps

module hdltop();

	parameter tck         = 2500/2;
	parameter ps          = 2500/4;
	logic     i_cpu_ck    = 1     ;
	logic     i_cpu_ck_ps = 1     ;
//===================== Clock Generation========================================================
	// clock generator
	always i_cpu_ck = #tck ~i_cpu_ck;
	always i_cpu_ck_ps = #ps i_cpu_ck;
//===================== Interface Instance =====================================================
	mem_intf cpu_contr (.i_cpu_ck(i_cpu_ck)//InstanceofCPU-CONTRInterface);

	mem_if contr_mem (.i_cpu_ck(i_cpu_ck)//InstanceofCONTR-MEMInterface);

//======================= CPU Instance===========================================================

	cpu_model cpu_model_inst (.i_cpu_ck(i_cpu_ck), .if_cpu(cpu_contr.cpu));

//======================= Controller Instance====================================================
	DDR3_Controller DDR3 (
		.i_cpu_ck   (i_cpu_ck               ), // System Clock
		.i_cpu_ck_ps(i_cpu_ck_ps            ),
		.cont_if_cpu(cpu_contr.MemController), // CPU-CONTR ports
		.cont_if_mem(contr_mem.contr_sig    )
	);			// CONTR-MEM ports

//======================Memory Instance===========================================================

	ddr3 dd3_model (.cont_if_mem_model(contr_mem.mem_sig));

endmodule // hdltop	