class Dungeon
  attr_accessor :player, :rooms

  def initialize(player_name="Hero")
    @rooms = [
      Room.new(:entrance, "Entrance Chamber", "the colossal entrance chamber to a mysterious cave", {west: :tunnel}),
      Room.new(:tunnel, "Narrow Tunnel", "a claustrophobic tunnel, choked with rocks and debris", {east: :entrance, west: :tinyroom}),
      Room.new(:tinyroom, "Tiny Room", "a closet-sized room, with a crude bed and desk, apparently inhabited", {east: :tunnel, north: :longhall}),
      Room.new(:longhall, "Long Hall", "a long, dark hallway, deserted but pristine", {south: :tinyroom, east: :deadend, west: :torture}),
      Room.new(:torture, "Torture Chamber", "a large, stone-walled cell full of terrifying objects that appear to be instruments of torture--but on a blood-stained table, there's a rusted key", {east: :longhall}, ['iron key', 'goblet']),
      Room.new(:deadend, "Dead End", "a small, stone-walled cell with no exits. There's an ancient skeleton seated in a corner. Something terrible has clearly happened here")
  ]

  @player = Player.new(player_name)
  end

  def start(location)
    @player.location = location
    return show_current_description
  end

  def add_room(reference, name, description, connections={}, contents=[])
    @rooms << Room.new(reference, name, description, connections, contents)
  end

  def show_current_description
    puts find_room_in_dungeon(@player.location).full_description
  end

  def find_room_in_dungeon(reference)
    return @rooms.detect { |room| room.reference == reference }
  end

  def find_room_in_direction(direction)
    current_location = find_room_in_dungeon(@player.location)

    if current_location.connections.has_key? direction
      return current_location.connections[direction]
    else
      puts "There's no way through to the #{direction}. Go somewhere else."
      return current_location.reference
    end

  end

  def go(direction)
    @player.location = find_room_in_direction(direction)
    show_current_description
  end

  def check_direction(input)
    directions = {
      :north => ['north', 'n'],
      :east => ['east', 'e'],
      :south => ['south', 's'],
      :west => ['west', 'w'],
      :quit => ['quit', 'q']
    }

    directions.each do |direction, input_list|
      if input_list.include? input.downcase
        return direction
      end
    end

    return nil
  end

  def get_direction
    choice = gets.chomp
    choice = check_direction(choice)
    current_location = find_room_in_dungeon(@player.location)

    while not choice
      puts "\nYou run around the #{current_location.name} frantically; this accomplishes nothing. Try picking a real direction. You can go #{current_location.list_directions}."
      choice = gets.chomp
      choice = check_direction(choice)
    end

    if choice == :quit
      abort "You give up and die. Lame."
    else
      return choice
    end
  end

  # not yet implemented
  def pick_up_object(room, object)
    @player.inventory << room.contents.delete(object)
  end

  def drop_object(room, object)
    room.contents << @player.inventory.object.delete
  end


  class Room
    attr_accessor :reference, :name, :description, :connections, :contents

    def initialize(reference, name, description, connections={}, contents=[])
      @reference = reference
      @name = name
      @description = description
      @connections = connections
      @contents = []
      contents.each do |item|
        @contents << add_article(item)
      end
    end

    def full_description
      print "\nYou are in the #{@name}. It's #{@description}. "
      if @contents.length > 0
        if @contents.length == 1
          verb = "is"
        else
          verb = "are"
        end
        print "In the room #{verb} #{list_to_text(@contents)}. "
        print "You can go #{list_directions}. What do you do?"
      else
        print "You can go #{list_directions}. Which direction do you go?"
      end
    end

    def list_directions
      directions = []
      # there's a way to do this by something like list comprehension
      if @connections.length > 0

        connections.each do |direction|
          directions << direction[0].to_s
        end

        return list_to_text(directions, " or ")
      else
        abort "But before you can contemplate it, a rockfall behind you traps you in the #{@name} and you slowly asphyxiate to death."
      end
      return nil
    end

    # this is very unsophisticated
    def add_article(noun)
      vowels = "AEIOUaeiou"

      if noun[-1].downcase == 's'
        return noun
      else
        if vowels.include? noun[0]
          return "an " + noun
        else
          return "a " + noun
        end
      end
    end

    def list_to_text(list, separator=" and ")
      if list.length > 2
        i = list.length - 1
        text = ""

        i.times do
          text += list[i] + ", "
          i -= 1
        end

        text += (separator.lstrip + list[0])
        return text
      elsif list.length == 2
        return list.join(separator)
      else
        return list[0]
      end
    end

  end

  class Player
    attr_accessor :name, :location, :inventory

    def initialize(name)
      @name = name
      @inventory = []
    end

    # not implemented yet
    def add_to_inventory(object)
      @inventory << object
    end

    def drop_from_inventory(object)
      @inventory.delete(object)
    end

  end

  # not implemented yet
  class Passage
    attr_accessor :reference, :type, :status, :to, :from
  end
end

def main
  d = Dungeon.new
  d.start(:torture)

  while true
    choice = d.get_direction
    d.go(choice)
  end
end

main





  #Player = Struct.new(:name, :location)
  #Room = Struct.new(:reference, :name, :description, :connections)
