class GPU
  attr_reader :vram
  attr_accessor :cpu
  attr_reader :scrn # delete this later

  def initialize(screen)
    @screen = screen
    reset
  end

  def reset
    @vram = Array.new(8192, 0x00)
    @oam = Array.new(160, 0x00)
    @reg = []

    @palette = {}
    [:bg, :obj0, :obj1].each do |pal|
      @palette[pal] = 4.times.map { 255 }
    end

    @tilemap = 512.times.map do
      8.times.map do
        8.times.map { 0 }
      end
    end

    @curline = 0
    @curscan = 0
    @linemode = 2
    @modeclocks = 0
    @yscrl = 0
    @xscrl = 0
    @raster = 0
    @ints = 0
    @intfired = 0

    @lcdon = false
    @bgon = false
    @objon = false
    @winon = false
    @objsize = false


    @scanrow = 160.times.map { 0 }

    @objdata = 40.times.map do |i|
      {
        y: -16,
        x: -8,
        tile: 0,
        palette: 0,
        yflip: 0,
        xflip: 0,
        prio: 0,
        num: i
      }
    end
    @objdatasorted = []

    # Set to values expected by BIOS, to start
    @bgtilebase = 0x0000
    @bgmapbase = 0x1800
    @wintilebase = 0x1800
  end

  def [](addr)
    gaddr = addr - 0xFF40
    case gaddr
      # LCD Control
    when 0
      (@lcdon ? 0x80 : 0) |
        ((@bgtilebase == 0x0000) ? 0x10 : 0) |
        ((@bgmapbase == 0x1C00) ? 0x08 : 0) |
        (@objsize ? 0x04 : 0) |
        (@objon ? 0x02 : 0) |
        (@bgon ? 0x01 : 0)
    when 1
      (@curline == @raster ? 4 : 0) | @linemode
    when 2
      @yscrl
    when 3
      @xscrl
    when 4
      @curline
    when 5
      @raster
    else
      @reg[gaddr]
    end
  end

  def []=(addr, val)
    gaddr = addr - 0xFF40
    @reg[gaddr] = val
    case gaddr
    when 0
      @lcdon = (val & 0x80 != 0x00)
      @bgtilebase = (val & 0x10 != 0x00) ? 0x0000 : 0x0800
      @bgmapbase = (val & 0x08 != 0x00) ? 0x1C00 : 0x1800
      @objsize = (val & 0x04 != 0x00)
      @objon = (val & 0x02 != 0x00)
      @bgon = (val & 0x01 != 0x00)
    when 1
      @ints = (val >> 3) & 15
    when 2
      @yscrl = val
    when 3
      @xscrl = val
    when 5
      @raster = val
    when 6
      160.times do |i|
        v = @mmu[(val << 8) + i]
        @oam[i] = v
        updateoam(0xFE00 + i, v)
      end
    # BG palette mapping
    when 7
      4.times do |i|
        case ((val >> (i * 2)) & 3)
        when 0
          @palette[:bg][i] = 255
        when 1
          @palette[:bg][i] = 192
        when 2
          @palette[:bg][i] = 96
        when 3
          @palette[:bg][i] = 0
        end
      end
    # OBJ0 palette mapping
    when 8
      4.times do |i|
        case ((val >> (i * 2)) & 3)
        when 0
          @palette[:obj0][i] = 255
        when 1
          @palette[:obj0][i] = 192
        when 2
          @palette[:obj0][i] = 96
        when 3
          @palette[:obj0][i] = 0
        end
      end
    # OBJ1 palette mapping
    when 9
      4.times do |i|
        case ((val >> (i * 2)) & 3)
        when 0
          @palette[:obj1][i] = 255
        when 1
          @palette[:obj1][i] = 192
        when 2
          @palette[:obj1][i] = 96
        when 3
          @palette[:obj1][i] = 0
        end
      end
    else
      puts "GPU trying to write #{val} into #{addr}"
    end
  end

  def updateoam(addr, val)
    addr -= 0xFE00
    obj = addr >> 2

    if obj < 40 then
      case (addr & 3)
      when 0
        @objdata[obj][:y] = val - 16
      when 1
        @objdata[obj][:x] = val - 8
      when 2
        if @objsize then # maybe != 0x00
          @objdata[obj][:tile] = (val & 0xFE)
        else
          @objdata[obj][:tile] = val
        end
      when 3
        @objdata[obj][:palette] = ((val & 0x10) != 0x00) ? 1 : 0
        @objdata[obj][:xflip] = ((val & 0x20) != 0x00) ? 1 : 0
        @objdata[obj][:yflip] = ((val & 0x40) != 0x00) ? 1 : 0
        @objdata[obj][:prio] = ((val & 0x80) != 0x00) ? 1 : 0
      end
    end

    @objdatasorted = @objdata.sort do |a, b|
      if a[:x] > b[:x] or a[:num] > b[:num] then
        -1
      else
        b[:x] <=> a[:x]
      end
    end
  end

  def step
    @modeclocks += @cpu.r_m
    case @linemode
    when 0 then hblank
    when 1 then vblank
    when 2 then oam_read_mode
    when 3 then vram_read_mode
    end
  end

  def hblank
    if @modeclocks >= 51 then
      # End of hblank for last scanline; render screen
      if @curline == 143 then
        @linemode = 1
        if (@ints & 2) != 0x00 then
          @intfired |= 2
        end
      else
        @linemode = 2
        if (@ints & 4) != 0x00 then
          @intfired |= 2
        end
      end

      @curline += 1

      if @curline == @raster and (@ints & 8) != 0x00 then
        @intfired |= 8
      end

      @curscan += 640
      @modeclocks = 0
    end
  end

  def vblank
    if @modeclocks >= 114 then
      @modeclocks = 0
      @curline += 1
      if @curline > 153 then
        @curline = 0
        @curscan = 0
        @linemode = 2
      end
      if (@ints & 4) != 0x00 then
        @intfired |= 4
      end
    end

  end

  def oam_read_mode
    if @modeclocks >= 20 then
      @modeclocks = 0
      @linemode = 3
    end
  end

  def vram_read_mode
    # Render scanline at end of allotted time
    if @modeclocks >= 43 then
      @modeclocks = 0
      @linemode = 0
      if (@ints & 1) != 0x00 then
        @intfired |= 1
      end

      if @lcdon then
        renderscan
      end
    end
  end

  def renderscan
    if @bgon then
      linebase = @curscan
      mapbase = @bgmapbase + ((((@curline + @yscrl) & 255) >> 3) << 5)
      y = (@curline + @yscrl) & 7
      x = @xscrl & 7
      t = (@xscrl >> 3) & 31

      if @bgtilebase != 0x00 then
      else
        tilerow = @tilemap[@vram[mapbase + t]][y]
        160.downto(1).each do |w|
          @scanrow[160 - x] = tilerow[x]
          @screen[linebase] = @palette[:bg][tilerow[x]]
          x += 1
          if x == 8 then
            t = (t + 1) & 31
            x = 0
            tilerow = @tilemap[@vram[mapbase + t]][y]
          end
          linebase += 1
        end
      end
    end
  end

  def update_tile(addr, val)
    # Get the "base address" for this tile row
    addr &= 0x1FFE

    # Work out which tile and row was updated
    tile = (addr >> 4) & 511
    y = (addr >> 1) & 7

    8.times do |x|
      # Find bit index for this pixel
      sx = 1 << (7-x)

      unless @tilemap[tile] then
        puts "no tileset for tile #{tile}"
      end

      unless @tilemap[y] then
        puts "no y in tileset #{tile} for y #{y}"
      end

      # Update tile set
      @tilemap[tile][y][x] =
        ((@vram[addr] & sx != 0x00)   ? 1 : 0) |
        ((@vram[addr+1] & sx != 0x00) ? 2 : 0)
    end
  end

  def step_counter_registers
    Debugger::GPURegisters.new(@ints, @curline, @raster, @linemode, @modeclocks, @palette[:bg].dup, @bgtilebase, @bgmapbase, @lcdon, @bgon)
  end
end

