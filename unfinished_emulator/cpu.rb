# This class represents the Game Boy CPU, a modified Z80.
class CPU
  # 8 bit registers: A, F, B, C, D, E, H, L
  
  # 16 bit PC register (Program counter)
  
  # 16 bit SP register (Stack pointer)
  

  # CPU Clock m and t
  
  

  # Clock for last instruction
  
  

  # Default register values
  DEFAULTS = {
    a: 0x00,
    f: 0x00,
    b: 0x00,
    c: 0x00,
    d: 0x00,
    e: 0x00,
    h: 0x00,
    l: 0x00,
    pc: 0x0000,
    sp: 0x0000
  }

  # Bitmasks for Z, N, H and C flags from the F register
  Z_FLAG = 0b1000_0000
  N_FLAG = 0b0100_0000
  H_FLAG = 0b0010_0000
  C_FLAG = 0b0001_0000

  # Creates a new CPU and initializes with the provided options
  # if no options where give all the registers will be initialized
  # with deafult values
  def initialize(mmu, options = {})
  end

  # restarts the emulation
  # values gotten from
  # http://imrannazar.com/content/files/jsgb-gpu-ctrl.jsgb.js
  def reset
    self.pc=0x100
    # MMU._inbios=0;
    self.sp = 0xFFFE
    self.hl = 0x014D
    self.c = 0x13
    self.e = 0xD8
    self.a = 1
    @total_steps = 0
  end

  # Executes next instruction
  def step
  end

  # Loads a program
  def load_with(*args)
    @mmu.load_rom(*args)
    self
  end

  def step_counter_step
    op_index = OPERATIONS.index(@last_operation)
    registers = Debugger::Registers.new(a, b, c, d, e, f, h, l, pc)
    Debugger::Step.new(@total_steps, op_index, registers, nil)
  end

  # Reads the next byte from memory and increments PC by 1
  def next_byte
  end

  # Reads the next word from memory and increments PC by 2
  def next_word
  end

  # Gets the value of the "virtual" 16 bits AF register
  def af
    (@a << 8) + @f
  end

  # Sets the value of the "virtual" 16 bits AF register
  def af=(n)
    @a = (n >> 8)
    @f = n & 0xFF
  end

  # Gets the value of the "virtual" 16 bits BC register
  def bc
    (@b << 8) + @c
  end

  # Sets the value of the "virtual" 16 bits BC register
  def bc=(n)
    @b = (n >> 8)
    @c = n & 0xFF
  end

  # Gets the value of the "virtual" 16 bits DE register
  def de
    (@d << 8) + @e
  end

  # Sets the value of the "virtual" 16 bits DE register
  def de=(n)
    @d = (n >> 8)
    @e = n & 0xFF
  end

  # Gets the value of the "virtual" 16 bits HL register
  def hl
    (@h << 8) + @l
  end

  # Sets the value of the "virtual" 16 bits HL register
  def hl=(n)
    @h = (n >> 8)
    @l = n & 0xFF
  end

  # Gets the Z flag from the F register
  def z_flag
    (@f & Z_FLAG) == Z_FLAG
  end

  # Gets the N flag from the F register
  def n_flag
    (@f & N_FLAG) == N_FLAG
  end

  # Gets the H flag from the F register
  def h_flag
    (@f & H_FLAG) == H_FLAG
  end

  # Gets the C flag from the F register
  def c_flag
    (@f & C_FLAG) == C_FLAG
  end
end

