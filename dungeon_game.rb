class Dungeon
  attr_accessor :player, :rooms

  def initialize(player_name="Hero")
    @rooms = [
      Room.new(:entrance, "Entrance Chamber", "the colossal entrance chamber to a mysterious cave", {west: :tunnel}),
      Room.new(:tunnel, "Narrow Tunnel", "a claustrophobic tunnel, choked with rocks and debris", {east: :entrance, west: :tinyroom}),
      Room.new(:tinyroom, "Tiny Room", "a closet-sized room, with a crude bed and desk, apparently inhabited", {east: :tunnel, north: :longhall}),
      Room.new(:longhall, "Long Hall", "a long, dark hallway, deserted but pristine", {south: :tinyroom, east: :deadend, west: :torture}),
      Room.new(:torture, "Torture Chamber", "a large, stone-walled cell full of terrifying objects that appear to be instruments of torture--but on a blood-stained table, there's a rusted key", {east: :longhall}),
      Room.new(:deadend, "Dead End", "a small, stone-walled cell with no exits, an ancient skeleton seated in a corner")
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
      puts "\nYou run around frantically and accomplish nothing. Try picking a real direction. You can go #{current_location.list_directions}."
      choice = gets.chomp
      choice = check_direction(choice)
    end

    if choice == :quit
      abort "You give up and die. Lame."
    else
      return choice
    end
  end


  class Room
    attr_accessor :reference, :name, :description, :connections, :contents

    def initialize(reference, name, description, connections={}, contents=[])
      @reference = reference
      @name = name
      @description = description
      @connections = connections
      @contents = contents
    end

    def full_description
#      directions = list_directions
      print "\nYou are in the #{@name}. It's #{@description}. "
      print "You can go #{list_directions}. "
      if @connections.length > 0
        print "Which direction do you go? "
      end
#      return description
    end

    def list_directions
      directions = []
      if @connections.length > 0
        connections.each do |direction|
          directions << direction[0].to_s
          connections.delete(direction)
        end
        return list_to_text(directions)
      else
        abort "A rockfall behind you traps you in the #{@name} and you slowly asphyxiate to death."
      end
      return nil
    end

    def list_to_text(list)
      text = ""
      if list.length > 2
        i = list.length - 1
        (list.length - 1).times do
          text += list[i] + ", "
          i -= 1
        end
        text += ("or " + list[0])
        return text
      elsif list.length == 2
        return list.join(" or ")
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

    def add_to_inventory(object)
      @inventory << object
    end

    def drop_from_inventory(object)
      @inventory.delete(object)
    end

  end

  class Passage
    attr_accessor :reference, :type, :status, :to, :from
  end
end

def main
  d = Dungeon.new
  d.start(:entrance)

  while true
    choice = d.get_direction
    d.go(choice)
  end
end

main





  #Player = Struct.new(:name, :location)
  #Room = Struct.new(:reference, :name, :description, :connections)
