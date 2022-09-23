require 'colorize'
$num_of_players = 0
$num_of_pits = 6
$num_of_stones = 6
class Player
    attr_accessor :pit_start, :pit_end, :big_pit, :player_name
    def initialize(p,c)
        @player_name = c == 'y'? p.yellow : p.blue
        @pit_start = ($num_of_players)*($num_of_pits+1)
        @pit_end = @pit_start + ($num_of_pits-1)
        @big_pit = @pit_start + 6
        $num_of_players += 1
    end
end
class Mankala
    attr_accessor :player_now
    def initialize(p1,p2)
        @p1 = Player.new(p1,'y')
        @p2 = Player.new(p2, 'b')
        @player_now = @p1
        #@board = [0,0,0,0,0,1,15,2,4,0,4,1,3,4]
        @board = Array.new($num_of_pits*2+2, $num_of_stones)
        @board[@p1.big_pit] = 0
        @board[@p2.big_pit] = 0
    end
    def pick_stones(pit)
        pit = @player_now.pit_start + (pit - 1)
        if pit < 0 || pit > @board.length
            raise  "ERROR: This pit does not exist."
        elsif pit == @player_now.big_pit
            raise "ERROR: You can not pick stones from your big pit." 
        elsif pit < @player_now.pit_start || pit > @player_now.pit_end
            raise "ERROR: You can not pick stones from the opponents pit."

        elsif @board[pit] == 0
            raise "ERROR: This pit is empty."
        end
        collected_stones = @board[pit]
        @board[pit] = 0
        while collected_stones > 0
            pit = (pit + 1)% @board.length
            if (@player_now == @p1 && pit == @p2.big_pit) || (@player_now == @p2 && pit == @p1.big_pit)
                next
            end
            #valid pit to drop stone
            @board[pit] += 1
            collected_stones -= 1
        end

        #drop all stones and at pit of last stone
        #check if pit is empty and it is on player's own side
        opposite_pit = (2*(@player_now.pit_end - pit) + 3)% @board.length

        if pit >= @player_now.pit_start && pit <= @player_now.pit_end && @board[pit] == 1
            @board[@player_now.big_pit] += @board[opposite_pit] + 1
            @board[opposite_pit] = 0
            @board[pit] = 0
            puts "YOUR LAST STONE ENDED IN YOUR OWN EMPTY PIT. YOU ALSO GET OPPONENT'S STONES IN FRONT OF YOU!".green
        end
        #check if player won, if won switch player, if not, check big pit condition if true dont switch else switch player
        if has_won
            old_player = @player_now
            switch_player
            rest_of_stones = @board.slice(@player_now.pit_start, @player_now.pit_end+1).inject(0) {|sum, curr| sum+curr}
            @board[@player_now.big_pit] = rest_of_stones
            @board = @board.slice(0,$num_of_stones+1) + Array.new(6,0) + [@board[-1]]
            winner = old_player.big_pit >= @player_now.big_pit ? old_player.player_name : @player_now.player_name 
            puts ''
            puts "CONGRATULATIONS! #{winner} has won!".green
            print_board
        else
            if pit != @player_now.big_pit
                switch_player
            else
                puts "YOUR LAST STONE ENDED IN YOUR BIG PIT. YOU GET AN EXTRA TURN!".green
            end
        end
    end
    def has_won
        for pit in @player_now.pit_start..@player_now.pit_end
            if @board[pit] != 0
                return false
            end
        end
        return true
    end
    def switch_player
        @player_now = @player_now == @p1? @p2 : @p1 
    end
    def print_board
        puts ''
        print_row('<')
        line1 = @board.slice(@p1.pit_start, $num_of_pits).reverse 
        line2 = @board.slice(@p2.pit_start,$num_of_pits)
        before_space = "    "
        print_line(line1, before_space)
        puts @board[@p1.big_pit].to_s.yellow + " "*(3*line1.length+4 - 1) + @board[@p2.big_pit].to_s.blue
        print_line(line2, before_space)
        print_row('>')
    end
    def print_line(player, space)
        print space
        for i in (0...player.length)
            print player[i].to_s + "  "
        end
        puts ''
    end
    def print_row(direction)
        line = '-----------------------'
        if direction == '<'
            line = direction + line + @p1.player_name
        else
            line = @p2.player_name + line + direction
        end
        print line
        puts ''
    end
end


#Game Start
puts "Welcome to Mankala!"
puts "Enter Player 1 name >> "
p1 = gets.chomp()
puts "Enter Player 2 name >> "
p2 = gets.chomp()
mankala = Mankala.new(p1,p2)

while !mankala.has_won do
    begin
        mankala.print_board
        puts "===> #{mankala.player_now.player_name}'s turn"
        puts "Select a pit from 1 to 6 >> "
        pit = gets.chomp().to_i
        mankala.pick_stones(pit)
    rescue Exception => e
        puts e.message.red
        puts 'Try again'.red
    end
end