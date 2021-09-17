class TimeBlock
  def initialize(hour)
    @staying = 0
    @maximum_stay = 0
    @coming = 0
    @leaving = 0
    @leave_count = 0
    @present_hour = hour
    @send = false
    @update = false
  end

  def come_one
    set_max
    @staying += 1
    @coming += 1
    unless @leave_count > 0
      @maximum_stay += 1
      @update = true
    else
      @leave_count -= 1
      @update = false
    end
    puts "こんにちは\n\n"
    result_view
  end
  
  def leave_one
    set_max
    if @staying > 0
      @staying -= 1
      @leaving += 1
      @leave_count += 1
      puts "お疲れ様でした\n\n"
    else
      puts "誰もいない・・・・・・\n\n"
    end
    result_view
  end
  
  def get_staying
    @staying
  end
  
  def set_staying(num)
    @staying = num
  end
  
  def get_maximum_view
    puts "#{@present_hour}時台：#{@maximum_stay}"
  end
  
  def get_maximum_staying
    @maximum_stay
  end
  
  def get_coming
    @coming
  end
  
  def send?
    @send
  end
  
  def sent
    @send = true
  end

  def update?
    @update
  end
  
  private
  def set_max
    if @staying > 0 && @maximum_stay == 0
      @maximum_stay = @staying
    end
  end

  def result_view
    puts "#{@present_hour}時台の最多人数：#{@maximum_stay}人"
    puts "#{@present_hour}時台の来校者：#{@coming}人"
    puts "#{@present_hour}時台の帰宅者：#{@leaving}人"
    puts "現在学習中の受講生：#{@staying}人\n\n"
  end
end