# Welcome to Baby Euro Gym
# In today's sports class we're going to run a test rom for the original gameboy

# to warm up, we'll add the /emulator folder to the $LOAD_PATH
GYM_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift GYM_ROOT

# GameBoys have several components, here you can choose to load
# the finished version or make your own in the unfinished version

require "finished_emulator/emulator"
require "finished_emulator/memory"
require "finished_emulator/cpu"
require "finished_emulator/gpu"
require "finished_emulator/lcd_screen"
require "finished_emulator/operations"
require "finished_emulator/operations/alu"
require "finished_emulator/operations/bit"
require "finished_emulator/operations/jump"
require "finished_emulator/operations/load"
require "finished_emulator/operations/stack"

emulator = Emulator.new
emulator.load_rom "./test_rom.gb"
emulator.reset

5.times do
  emulator.frame
end

screen = LcdScreen.new
scrn = emulator.gpu.scrn.compact

# clear screen
# puts "\e[H\e[2J"

screen.screen = scrn
screen.render
