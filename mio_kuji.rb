class MioKuji
  def initialize
    @push = 0
    @appear = 0
  end

  def lottery
    @push += 1
    random = rand(200)+1
    case random
      when 1..100
        puts "どうも、counting.rbです。\nこのプログラムは戍井さんの提供でお送りしております。"
      when 101..140
        puts "どうも、counting.rbです。\n無効な入力はしないでね!\n絶対にしないでね！"
      when 136..180
        puts "どうも、counting.rbです。\n1~5のコマンドを押してね！\nそれ以外は押さないでね!\n絶対に押さないでね！"
      when 181..198
        puts "100分の1の確率で激レア演出!?\n絶対に見逃すな！"
        puts "現在の出現回数は#{@push}push中#{@appear}回！！"
      when 199,200
        @appear += 1
        yamane_come_on!
        puts "おめでとう！"
        puts "現在の山根さん遭遇数は#{@appear}回だよ！" 
    end
  end

  alias yamane lottery

  def yamane_come_on!
    sleep 0.3
    puts "や"
    sleep 0.5
    puts "ま"
    sleep 0.5
    puts "ね"
    sleep 0.5
    puts "が"
    sleep 1.0
    puts "キタ━━━━(ﾟ∀ﾟ)━━━━!!"
    sleep 1.5
  end

  # オリジナルアイデア by 三尾さん
end