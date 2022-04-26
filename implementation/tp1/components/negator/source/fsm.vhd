library IEEE;
use IEEE.std_logic_1164.all;

entity fsm is
end;

architecture fsm_arq of fsm is

	-- R = Rojo
	-- A = Amarillo
	-- V = Verde
	-- RA = Rojo y amarillo (cuando se va de Rojo a Amarillo, aparecen juntos. De Verde a Rojo no.)
	type state_t is (R1_V2, R1_A2, RA1_R2, V1_R2, A1_R2, R1_RA2);
	signal current_state : state_t;

begin
end;
