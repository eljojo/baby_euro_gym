class LcdScreen
  WIDTH = 160
  HEIGHT = 144
  COLORS = [40, 47, 100, 107] # darkest to lightest

  def initialize
    @screen = (WIDTH * HEIGHT).times.map { 0 }
  end

  def render
    @screen.each_with_index do |color, pos|
      print_pixel(color)
      print "\n" if (pos + 1) % WIDTH == 0
    end
  end

  def []=(coords, color)
    return unless color
    @screen[coords] = color
  end

  private
  # https://github.com/fazibear/colorize/blob/master/lib/colorize.rb
  # http://misc.flogisoft.com/bash/tip_colors_and_formatting
  def print_pixel(color)
    code = COLORS[color]
    print "\e[49m\e[#{code}m \e[49m"
  end
end

