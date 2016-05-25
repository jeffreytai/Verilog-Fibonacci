`timescale 1ns / 1ps

module model_uart(/*AUTOARG*/
   // Outputs
   TX,
   // Inputs
   RX
   );

   output TX;
   input  RX;

   parameter baud    = 115200;
   parameter bittime = 1000000000/baud;
   parameter name    = "UART0";
   
   reg [7:0] rxData;
   event     evBit;
   event     evByte;
   event     evTxBit;
   event     evTxByte;
   reg       TX;

	reg [2:0] counter;
	reg [7:0] rxData1;
	reg [7:0] rxData2;
	reg [7:0] rxData3;
	reg [7:0] rxData4;
	reg [7:0] rxData5;

	
   initial
     begin
        TX = 1'b1;
		  counter <= 3'b000;
     end
   
   always @ (negedge RX)
     begin
        rxData[7:0] = 8'h0;
        #(0.5*bittime);
        repeat (8)
          begin
             #bittime ->evBit;
             //rxData[7:0] = {rxData[6:0],RX};
             rxData[7:0] = {RX,rxData[7:1]};
          end
        ->evByte;
		  
		  counter <= counter + 1'b1;
		  rxData1 <= rxData;
		  rxData2 <= rxData1;
		  rxData3 <= rxData2;
		  rxData4 <= rxData3;
		  rxData5 <= rxData4;
		  
		  if (counter == 3'b101)
			begin
				counter <= 3'b000;
				//$display ("%d %s Received bytes %02x (%s) %02x (%s) %02x (%s) %02x (%s) %02x (%s) %02x (%s)", $stime, name, rxData5, rxData5, rxData4, rxData4, rxData3, rxData3, rxData2, rxData2, rxData1, rxData1, rxData, rxData);
				$display ("%d %s Received bytes %s%s%s%s%s%s", $stime, name, rxData5, rxData4, rxData3, rxData2, rxData1, rxData);
			end
     end

   task tskRxData;
      output [7:0] data;
      begin
         @(evByte);
         data = rxData;
      end
   endtask // for
      
   task tskTxData;
      input [7:0] data;
      reg [9:0]   tmp;
      integer     i;
      begin
         tmp = {1'b1, data[7:0], 1'b0};
         for (i=0;i<10;i=i+1)
           begin
              TX = tmp[i];
              #bittime;
              ->evTxBit;
           end
         ->evTxByte;
      end
   endtask // tskTxData
   
endmodule // model_uart
