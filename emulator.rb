# Welcome to Baby Euro Gym
# In today's sports class we're going to run a test rom for the original gameboy

# to warm up, we'll add the /emulator folder to the $LOAD_PATH
GYM_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift GYM_ROOT

# GameBoys have several components, here you can choose to load
# the finished version or make your own in the unfinished version

require "finished_emulator/cpu"

cpu = CPU.new
p cpu
