module count_m16(
                 input          clk,
                 input          rst_n,
                 input          en,    //Counter enable
                 input          clr,   //Counter synchronous reset 
                 input          one,
                 input          ten,
                 output reg[3:0]data_0,
                 output reg[3:0]data_1,  //counter value
                 output reg     t      // carry enable signal
                );
always@(posedge clk or negedge rst_n) 

begin
    if(rst_n==0)
    begin
        data_0 <= 4'd0;
        data_1 <= 4'd0;
        t <= 1'd0;
    end
    else if(clr)
    begin
        data_0 <= 4'd0;
        data_1 <= 4'd0;
        t <= 1'd0;      
    end
    else if(en)
    begin
        if(data_0==4'd9)
        begin
            t<= 1'b1;    //Counter to 9 to generate carry
            data_1 <= data_1 +1; 
            data_0 <= 4'd0;//Counter to 9 reset
        end
        else if(data_0 == 4'd5 && data_1 == 4'd1)
        begin
            data_0 <= 4'd0;
            data_1 <= 4'd0;
        end
        else
        begin
            t <= 1'b0;
            data_0 <= data_0 + 4'd1;
        end
    end
    else
        t <= 1'b0;
end

endmodule