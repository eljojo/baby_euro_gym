class Emulator
  attr_accessor :debug_mode, :step_by_step, :step_counter
  attr_reader :screen
  attr_reader :gpu # delete this later

  def initialize
    @screen = LcdScreen.new
    @gpu = GPU.new(@screen)
    @mmu = MMU.new(@gpu)
    @cpu = CPU.new(@mmu)
    @gpu.cpu = @cpu
  end

  def load_rom(path)
    rom = File.binread(path)
    @cpu.load_with(*rom.unpack("C*"))
  end

  def reset
    @cpu.reset
  end

  def step
    @cpu.step
    @gpu.step

    if step_counter then
      step = @cpu.step_counter_step
      step.gpu_r = @gpu.step_counter_registers
      step_counter << step
    end
  end

  def frame
    fclk = @cpu.clock_m + 17556
    begin
      step
    end while @cpu.clock_m < fclk
  end

  def render
    screen.render
  end

  def run_test(enum)
    enum.each do
      step
    end
  end
end

