class MMU
  # Initializes the memory areas
  def initialize(gpu)
  end

  # Reads a byte from to the different memory areas
  def [](i)
  end

  # Gets the word accessor
  def word
  end

  # Writes a byte to the different memory areas
  def []=(i, n)
  end

  # Loads a ROM
  def load_rom(*args)
  end

  # Access to words (16 bits) in memory
  class WordAccessor
    # Creates a new word accessor for the specified MMU
    def initialize(mmu)
    end

    # Reads a word
    def [](i)
    end

    # Writes a word
    def []=(i, n)
    end
  end
end

