class Emulator
  attr_accessor :debug_mode, :step_by_step, :step_counter
  attr_reader :screen
  attr_reader :gpu # delete this later

  def initialize
  end

  def load_rom(path)
  end

  def reset
  end

  def step
  end

  def frame
    fclk = @cpu.clock_m + 17556
    begin
      step
    end while @cpu.clock_m < fclk
  end

  def render
  end
end

