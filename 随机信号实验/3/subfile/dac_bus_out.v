//
//
//

module dac_bus_out(

		input							clk_in,           		//

		input		[7:0]				dac_in0_i,				//	
		input		[7:0]				dac_in0_q,
		
	   output                  r_ref_c,
		
		output						dac_sel,
		output						dac_clk,	
		output						dac_wr,
		output						dac_reset,
		output	reg	[9:0]		dac_data
	
	);


	assign    r_ref_c = 1'b0;
	
	
	reg    clk_en;
	
	always @(posedge clk_in )begin					//
		clk_en <= ~clk_en;

   end	
	
	assign  dac_clk = ~clk_in;
	assign  dac_wr = ~clk_in;
	assign  dac_sel = ~clk_en;
	assign  dac_reset = 1'b0;
	
	reg    [9:0]	data_out_i = 10'b0;
	reg    [9:0]	data_out_q = 10'b0;
	
	always @(posedge clk_in )begin					//
	if(clk_en == 0)   begin             					//

				data_out_i <= {dac_in0_i,2'b0};			//
				data_out_q <= {dac_in0_q,2'b0};       //

	end
	end

	
	
	
	
	////////////////////////////////////////////////////
	//将数据发送到DA上，以及时钟控制信号
	///////////////////////////////////////////////////
	reg   [9:0]data_out_q_r;
	always @(posedge clk_in )begin			//clk  = 61p44m
		if(clk_en==1) begin						//30p72m
				dac_data	      <= {(data_out_i[9]),data_out_i[8:0]};   	//
				data_out_q_r	<= {(data_out_q[9]),data_out_q[8:0]};		//
		end
		else
				dac_data 		<=  data_out_q_r;		   

	end

	
endmodule


