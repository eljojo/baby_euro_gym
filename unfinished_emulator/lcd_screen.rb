class LcdScreen
  WIDTH = 160
  HEIGHT = 144
  COLORS = [40, 47, 100, 107] # darkest to lightest

  def initialize
  end

  def render
  end

  def []=(coords, color)
  end

  private
  # https://github.com/fazibear/colorize/blob/master/lib/colorize.rb
  # http://misc.flogisoft.com/bash/tip_colors_and_formatting
  def print_pixel(color)
  end
end

