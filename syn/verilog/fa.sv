module fa
		(output logic [3:0] sum,
		output logic cout,
		input logic cin,
		input logic [3:0] x,y,
		input logic sw_ctrl_net);

	// Intermediate carries. 
	logic c1, c2, c3;

	fa_1 fa1 (c1, sum[0], cin, x[0], y[0]);
	fa_1 fa2 (c2, sum[1], c1, x[1], y[1]);
	fa_1 fa3 (c3, sum[2], c2, x[2], y[2]);
	fa_1 fa4 (cout, sum[3], c3, x[3], y[3]);


endmodule: fa


module fa_1
      (output  logic cout, s,
       input   logic cin, x, y);

       assign {cout,s} = cin + x + y;

endmodule: fa_1
