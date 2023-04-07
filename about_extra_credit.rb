# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

class Constants
    def Constants.MIN_ENTRY() 300 end
    def Constants.GOAL() 1000 end
end

class Game
    def initialize()
        @turn = 0
        @final_turn = -1
        count = 0
        while true do
            print "How many players are there? > "
            count_string = gets.chomp
            begin
                count = Integer(count_string)
            rescue
                puts "---Input must be an integer"
                next
            end

            if count > 1
                break
            else
                puts "---You need at least 2 players"
            end
        end
        @players = Array.new(count) {Player.new}
        play_game
    end

    def play_game()
        while @final_turn < 0 or @final_turn >= @turn do
            if take_turn(@final_turn > 0) and @final_turn < 0
                @final_turn = @turn + @players.size
                puts "----Player #{@turn % @players.size + 1} has reached the goal of #{Constants.GOAL} points----"
                puts "Each player will get one more turn."
            end
            @turn += 1
            print "--press enter to continue--"
            gets
        end
        puts "\nGame over! Results:"
        max_index = 0
        max_score = 0
        for i in 0...@players.size do
            if @players[i].score > max_score
                max_score = @players[i].score
                max_index = i
            end
            puts "\tPlayer #{i + 1}: #{@players[i].score()}"
        end
        puts "The winner is Player #{max_index + 1}!"
    end

    def take_turn(final_turn)
        player_id = @turn % @players.size + 1
        player = @players[player_id - 1]

        set = DiceSet.new
        puts "\nStarting player #{player_id}'s #{final_turn ? 'final ' : ''}turn with #{player.score} points"
        puts "First roll: rolled #{set.last_roll} for score: #{set.score}"
        player.add_score(set.score)
        while true do 
            if !get_choice("Player #{player_id}: Roll #{set.next_roll_count} dice")
                if !player.minimum_met and player.running_score < Constants.MIN_ENTRY
                    puts "You have not met the minimum entry score of #{Constants.MIN_ENTRY} yet"
                    if get_choice("Are you sure you want to end your turn?", false)
                        break;
                    else
                        next
                    end
                else
                    break
                end
            end
            set.roll()
            puts "Rolled #{set.last_roll} for score: #{set.score}"
            if set.score == 0
                puts "Player #{player_id} was too greedy. Ending turn without adding points to total."
                player.bankrupt()
                return false
            end
            player.add_score(set.score)
            puts "Running total: #{player.running_score}"
        end
        reached_goal = player.finish_turn()
        puts "Results: Player #{player_id} has score #{player.score}"
        return reached_goal
    end

    def get_choice(message, default_yes=true)
        while true do
            print ">> #{message} [#{default_yes ? 'Y/n' : 'y/N'}] > "
            input = gets.chomp.downcase
            if input == "y" or (default_yes and input == "") then return true
            elsif input == "n" or (!default_yes and input == "") then return false
            else puts "Invalid input<#{input}>: please enter y or n" end
        end
    end

end

class Player
    def initialize()
        @minimum_met = false
        @score = 0
        @running_score = 0
    end

    def score() @score end
    def running_score() @running_score end
    def minimum_met() @minimum_met end

    def add_score(val) @running_score += val end

    def bankrupt() @running_score = 0 end

    def finish_turn()
        if @minimum_met then @score += @running_score
        elsif @running_score >= Constants.MIN_ENTRY
            @minimum_met = true
            @score = @running_score
        end
        @running_score = 0
        return @score >= Constants.GOAL
    end
end

class DiceSet
    def dice() @dice end
    def score() @score end
    def last_roll() @last_roll end
    def next_roll_count() @dice.size > 0 ? @dice.size : 5 end

    def initialize()
        @dice = []
        @score = 0
        roll()
    end

    def roll()
        options = (1..6).to_a
        @dice = Array.new(@dice.size > 0 ? @dice.size : 5) { options.sample }
        @last_roll = @dice.clone
        generate_score()
    end

    private
    def generate_score()
        if @dice.size > 2
            if check_count(1)
                remove_three(1)
                @score = 1000 + generate_score()
                return @score
            end
            for num in (2..6) do
                if check_count(num)
                    remove_three(num)
                    @score = (num * 100) + generate_score()
                    return @score
                end
            end
        end
        score = 0
        i = 0
        while i < @dice.size
            if @dice[i] == 1
                score += 100
                @dice.delete_at(i)
                next
            elsif @dice[i] == 5
                score += 50
                @dice.delete_at(i)
                next
            end
            i += 1
        end
        @score = score
    end
        
    def check_count(num)
        return (@dice.select {|item| item == num}).size > 2
    end
    
    def remove_three(num)
        for i in (0..2) do @dice.delete_at(@dice.index(num)) end
    end
end

Game.new