library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0)
           );
end test_env;

architecture Behavioral of test_env is

signal func: std_logic_vector (5 downto 0);
signal sa, rt, rd, rWA: std_logic_vector (4 downto 0);
signal en, rst: std_logic := '0';
signal output, Instruction, PC, rd1, rd2, wd, ext_imm, BranchAddress, aluRes, aluResOut, MemData, JumpAddress : std_logic_vector(31 downto 0);
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemToReg, RegWrite, zero, PCSrc, Br_ne: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);


signal Instruction_IF_ID: std_logic_vector(31 downto 0);
signal PC_IF_ID : std_logic_vector(31 downto 0);

signal RegDst_ID_EX: std_logic;
signal AluSrc_ID_EX: std_logic;
signal Branch_ID_EX: std_logic;
signal AluOp_ID_EX: std_logic_vector(2 downto 0);
signal MemWrite_ID_EX: std_logic;
signal MemToReg_ID_EX: std_logic;
signal RegWrite_ID_EX: std_logic;
signal BNE_ID_EX: std_logic;
signal RD1_ID_EX: std_logic_vector(31 downto 0);
signal RD2_ID_EX: std_logic_vector(31 downto 0);
signal Ext_Imm_ID_EX: std_logic_vector(31 downto 0);
signal func_ID_EX: std_logic_vector(5 downto 0);
signal sa_ID_EX: std_logic_vector(4 downto 0);                                                  
signal Rd_ID_EX: std_logic_vector(4 downto 0);
signal Rt_ID_EX: std_logic_vector(4 downto 0);
signal PC_ID_EX: std_logic_vector(31 downto 0);

signal Branch_EX_MEM : std_logic;
signal MemWrite_EX_MEM: std_logic;
signal MemToReg_EX_MEM: std_logic;
signal RegWrite_EX_MEM: std_logic;
signal Zero_EX_MEM: std_logic;
signal BNE_EX_MEM: std_logic;
signal BranchAddress_EX_MEM: std_logic_vector(31 downto 0);
signal ALURes_EX_MEM: std_logic_vector(31 downto 0);
signal RD2_EX_MEM: std_logic_vector(31 downto 0);
signal WA_EX_MEM: std_logic_vector(4 downto 0);

signal RegWrite_MEM_WB  : std_logic;
signal Mem2Reg_MEM_WB: std_logic;
signal ALURes_MEM_WB : std_logic_vector(31 downto 0);
signal MemData_MEM_WB: std_logic_vector(31 downto 0);
signal WA_MEM_WB: std_logic_vector(4 downto 0);


component MPG is
    Port ( 
    clk : in STD_LOGIC;
    btn: in STD_LOGIC;
    enable : out STD_LOGIC
    );
end component;

component SSD is
Port ( digit : in std_logic_vector(31 downto 0);
         clk   : in std_logic;
         cat   : out std_logic_vector(6 downto 0);
         an    : out std_logic_vector(7 downto 0));
end component;

component IFetch is
    Port ( clk : in STD_LOGIC;
           Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR (31 downto 0);
           PC : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component ID is
    Port ( clk: in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           Wa : in  STD_LOGIC_VECTOR(4 downto 0);
           en : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           rd1 : out STD_LOGIC_VECTOR (31 downto 0);
           rd2 : out STD_LOGIC_VECTOR (31 downto 0);
           wd : in STD_LOGIC_VECTOR (31 downto 0);
           ext_imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           rt : out STD_LOGIC_VECTOR (4 downto 0);
           rd : out STD_LOGIC_VECTOR (4 downto 0)
           );
end component;

component UC is
    Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           Br_ne : out STD_LOGIC
           );
end component;

component EX is
    Port ( rd1 : in STD_LOGIC_VECTOR (31 downto 0);
           aluSrc : in STD_LOGIC;
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           ext_imm : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           aluOp : in STD_LOGIC_VECTOR (2 downto 0);
           pc : in STD_LOGIC_VECTOR (31 downto 0);
           rt: in STD_LOGIC_VECTOR(4 downto 0);
           rd: in STD_LOGIC_VECTOR(4 downto 0);
           RegDst: in STD_LOGIC;
           zero : out STD_LOGIC;
           aluRes : out STD_LOGIC_VECTOR (31 downto 0);
           branchAdress : out STD_LOGIC_VECTOR (31 downto 0);
           rWA: out STD_LOGIC_VECTOR(4 downto 0)
           );
end component;

component mem is
    Port ( memWrite : in STD_LOGIC;
           aluResIn : in STD_LOGIC_VECTOR (31 downto 0);
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           memData : out STD_LOGIC_VECTOR (31 downto 0);
           aluResOut : out STD_LOGIC_VECTOR (31 downto 0));
end component;

begin

connectMPG1: MPG port map(clk, btn(0), en);
connectMPG2: MPG port map(clk, btn(1), rst);


connectSSD: SSD port map(output, clk, cat, an);

connectIFetch: IFetch port map(clk, Jump, JumpAddress, PCSrc, BranchAddress_EX_MEM, en, rst, Instruction, PC);
connectUC: UC port map(Instruction_IF_ID(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemToReg, RegWrite, Br_ne);
connectID: ID port map(clk, RegWrite_MEM_WB , Instruction_IF_ID(25 downto 0), WA_MEM_WB, en, ExtOp, rd1, rd2, wd, ext_imm, func, sa, rt, rd);
connectEX: EX port map(RD1_ID_EX, AluSrc_ID_EX, RD2_ID_EX, Ext_Imm_ID_EX, sa_ID_EX, func_ID_EX, AluOp_ID_EX, PC_ID_EX, Rt_ID_EX, Rd_ID_EX, RegDst_ID_EX, zero, aluRes, BranchAddress, rWA);
connectMEM: mem port map(MemWrite_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM, clk, en, MemData, aluResOut);

JumpAddress <= PC_IF_ID(31 downto 28) & (Instruction_IF_ID(25 downto 0) & "00");
PCSrc <= (Branch_EX_MEM and Zero_EX_MEM) or (not(Zero_EX_MEM) and BNE_EX_MEM);

wd <= ALURes_MEM_WB when Mem2Reg_MEM_WB = '0' else MemData_MEM_WB;

process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            --IF/ID
            Instruction_IF_ID <= Instruction;
            PC_IF_ID <= PC;
            
            --ID/EX
            RegDst_ID_EX <= RegDst;
            AluSrc_ID_EX <= ALUSrc;
            Branch_ID_EX <= Branch;
            AluOp_ID_EX <= ALUOp;
            MemWrite_ID_EX <= MemWrite;
            MemToReg_ID_EX <= MemToReg;
            RegWrite_ID_EX <= RegWrite;
            RD1_ID_EX <= rd1;
            BNE_ID_EX <= Br_ne;
            RD2_ID_EX <= rd2;
            Ext_Imm_ID_EX <= ext_imm;
            func_ID_EX <= func;
            sa_ID_EX <= sa;
            Rd_ID_EX <= rd;
            Rt_ID_EX <= rt;
            PC_ID_EX <= PC_IF_ID;
            
            --EX/MEM
            Branch_EX_MEM <= Branch_ID_EX;
            MemWrite_EX_MEM <= MemWrite_ID_EX;
            MemToReg_EX_MEM <= MemToReg_ID_EX;
            RegWrite_EX_MEM <= RegWrite_ID_EX;
            Zero_EX_MEM <= zero;
            BranchAddress_EX_MEM <= BranchAddress;
            ALURes_EX_MEM <= aluRes;
            WA_EX_MEM <= rWA;
            BNE_EX_MEM <= BNE_ID_EX;
            RD2_EX_MEM <= RD2_ID_EX;
            
            --MEM/WB
            RegWrite_MEM_WB <= RegWrite_EX_MEM;
            Mem2Reg_MEM_WB <= MemToReg_EX_MEM;
            ALURes_MEM_WB <= aluResOut;
            MemData_MEM_WB <= MemData; 
            WA_MEM_WB <= WA_EX_MEM;
        end if;
    end if;    
end process;

process(sw(7 downto 5), Instruction, PC, rd1, rd2, ext_imm, aluRes, MemData, wd)
begin
  case sw(7 downto 5) is 
    when "000" =>
      output <= Instruction;
    when "001" =>
      output <= PC;
    when "010" =>
      output <= RD1_ID_EX;
    when "011" =>
      output <= RD2_ID_EX;
    when "100" =>
      output <= Ext_Imm_ID_EX;
    when "101" =>
       output <= aluRes;
    when "110" =>
       output <= MemData;
     when "111" =>        
       output <= wd; 
    when others =>
      output <= (others => '0');
  end case;
end process;

led(11) <= Br_ne;
led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= Branch;
led(3) <= Jump;
led(2) <= MemWrite;
led(1) <= MemToReg;
led(0) <= RegWrite;

led(8) <= ALUOp(0);
led(9) <= ALUOp(1);
led(10) <= ALUOp(2);


end Behavioral;