require 'json'
class SeatAllocation
    attr_accessor :max_rows, :input_seats, :arrangement, :passenger_no, :count, :error
    def initialize(options={})
        @count = 0
        @input_seats = options[:input_seats]
        @passenger_no = options[:passenger_no]
    end
    
    def allocate_seats
        is_valid = validate_input(@input_seats, @passenger_no)
        unless is_valid
            p @error
            return @error
        end
        @max_rows    = @input_seats.map{|n| n[1]}.max
        @arrangement =  build_seat_arrangement(@input_seats)
        @arrangement = fill_aisle_seats(@arrangement)
        @arrangement = fill_window_seats(@arrangement)
        @arrangement = fill_center_seats(@arrangement)
        print_arrangement(@arrangement)
    end

    #validates the input
    def validate_input seats, passenger_count
        if (seats.select{|x| x.size >2 || x.size < 2}).size > 0
            @error = "Input seats format is invalid"
            return false
        end
        if(seats.select{|x| x[0]<=0|| x[1]<= 0}).size > 0
            @error = "row or column cannot be negative or zero"
            return false
        end
        max_seats = @input_seats.reduce(0) { |sum, num| sum + num[0]*num[1] }
        if(@passenger_no > max_seats)
            @error = "Passenger count is more than available seats."
            return false    
        end
        return true
    end
    
    #building inputs seats in the form of array
    def build_seat_arrangement a
    	array = []
    	a.each do |queue|
    		array.push(generate_array queue[0], queue[1])
    	end
    	array
    end
    
    def generate_array col, row
        array = []
    	row.times {array.push([*1..col].map{|x| 'x'})}
    	array
    end
    
    def print_arrangement allocated_seats
        @max_rows.times do |row_no|
            string =  ""
            allocated_seats.each_with_index do |segment, segment_no|
                if row_no <= segment.size-1
                    string = string.concat("#{segment[row_no].map{|x|x.to_s.rjust(2, '0')}.join(' ')}").concat(" "*4).gsub('0x', 'XX')
                else
                    string = string.concat((" "*segment[-1].map{|x|x.to_s.rjust(2, '0')}.join(' ').length).concat(" "*4))
                end
            end
            puts string
        end
    end
    
    def fill_aisle_seats a
        array = a
        @max_rows.times do |row_no|
           a.each_with_index do |segment, segment_no|
               return array if @count == @passenger_no
                if row_no <= segment.size-1 
                   if segment_no == 0
                       unless segment[row_no].length == 1
                           @count = @count+1
                           array[segment_no][row_no][-1] = count        #[[], [], []]
                       end
                   elsif segment_no == (a.length-1)
                        unless segment[row_no].length == 1
                          @count = @count+1
                          array[segment_no][row_no][0] = @count        #[[], [], []]
                        end                       
                  else
                        @count = @count+1
                        array[segment_no][row_no][0] = @count 
                        unless array[segment_no][row_no].length ==1
                            @count = @count+1
                            array[segment_no][row_no][-1] = @count    #[[], [], []]
                        end
                  end
               end
           end
        end
        array
    end
    def fill_window_seats a
        array = a
        @max_rows.times do |row_no|
            a.each_with_index do |segment, segment_no|
                return array if @count == @passenger_no
                if (row_no <= segment.size-1)
                    if segment_no == 0 
                        @count = @count + 1
                        array[segment_no][row_no][0] = @count
                    elsif segment_no == a.size-1
                        @count = @count + 1
                        array[segment_no][row_no][-1] = @count
                    end
                end
            end
        end
        array
    end
    
    def fill_center_seats a
        array = a
        @max_rows.times do |row_no|
            a.each_with_index do |segment, segment_no|
                if (row_no <= segment.size-1 && segment[row_no].size > 2)
                    (1..segment[row_no].size-2).each do |x|
                        return array if @count == @passenger_no
                        @count = @count + 1
                        array[segment_no][row_no][x] = @count
                    end
                end
            end
        end
        array        
    end
end

#Assuming that the input entered are provided correctly and are valid
puts "Enter a valid 2-D Array in given format ([[col,row], .....])"
input_seats = JSON.parse(gets.chomp)
puts "Enter Passenger count"
passenger_no = gets.chomp
obj = SeatAllocation.new({input_seats: input_seats, passenger_no: passenger_no.to_i})
obj.allocate_seats
