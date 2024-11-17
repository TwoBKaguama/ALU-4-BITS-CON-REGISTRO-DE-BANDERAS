module testbench;

    reg [3:0] X, Y;   // Entradas de 4 bits
    wire [3:0] B;     // Salida: Registro de banderas

    // Instancia de la UAL
    UAL_4bits ual (
        .X(X),
        .Y(Y),
        .B(B)
    );

    initial begin
        // Caso 1: X = Y
        X = 4'b0101; Y = 4'b0101; // 5 == 5
        #10; $display("Caso 1: B = %b (Esperado: Z=1, N=0, P=0, V=0)", B);

        // Caso 2: X < Y
        X = 4'b0010; Y = 4'b0111; // 2 < 7
        #10; $display("Caso 2: B = %b (Esperado: Z=0, N=1, P=0, V=0)", B);

        // Caso 3: X > Y
        X = 4'b0111; Y = 4'b0011; // 7 > 3
        #10; $display("Caso 3: B = %b (Esperado: Z=0, N=0, P=1, V=0)", B);

        // Caso 4: Overflow positivo (7 + 1)
        X = 4'b0111; Y = 4'b0001; // 7 + 1 => Overflow
        #10; $display("Caso 4: B = %b (Esperado: Z=0, N=0, P=1, V=1)", B);

        // Caso 5: Overflow negativo (-8 + (-8))
        X = 4'b1000; Y = 4'b1000; // -8 + -8 => Overflow
        #10; $display("Caso 5: B = %b (Esperado: Z=0, N=1, P=0, V=1)", B);

        // Caso 6: Resultado es cero
        X = 4'b0000; Y = 4'b0000; // 0 + 0 = 0
        #10; $display("Caso 6: B = %b (Esperado: Z=1, N=0, P=0, V=0)", B);

        $stop; // Detener simulación
    end
endmodule
module UAL_4bits (
    input [3:0] X,    // Entrada de 4 bits para X
    input [3:0] Y,    // Entrada de 4 bits para Y
    output reg [3:0] B // Salida: Registro de banderas ZNPV
);

    reg [4:0] resultado; // Resultado de la operación de 5 bits para detectar overflow

    always @(*) begin

        B = 4'b0000; // Asignamos 0 a todas las banderas

        resultado = X + Y;


        // Bandera Z: Se activa si el resultado es 0
        if (B[3] == 1'b0 && (X == Y)) begin
            B[3] = 1'b1;  // Z = 1
        end

        // Bandera N: Se activa si X < Y
        if (B[2] == 1'b0 && (X < Y)) begin
            B[2] = 1'b1;  // N = 1
        end

        // Bandera P: Se activa si X > Y
        if (B[1] == 1'b0 && (X > Y)) begin
            B[1] = 1'b1;  // P = 1
        end

        // Bandera V: Detecta Overflow
        // Si ocurre overflow, el bit de signo de los operandos no concuerda con el bit de signo del resultado
        if (B[0] == 1'b0 && ((~X[3] & ~Y[3] & resultado[4]) | (X[3] & Y[3] & ~resultado[4]))) begin
            B[0] = 1'b1;  // V = 1 (Overflow detectado)
        end
    end

endmodule

